//
//  KitoValidator+More.swift
//  KitoValidation
//
//  Created by Wycliff on 9/23/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import Foundation

public extension KitoValidator {
    static func exactLength(_ length: Int, message: String? = nil) -> KitoValidator {
        KitoValidator(errorMessage: message ?? "Must be exactly \(length) characters") { $0.count == length }
    }

    /// An http or https address with a host.
    static func url(message: String = "Enter a valid web address") -> KitoValidator {
        KitoValidator(errorMessage: message) { value in
            guard let url = URL(string: value.trimmingCharacters(in: .whitespaces)), let scheme = url.scheme?.lowercased() else { return false }
            return (scheme == "http" || scheme == "https") && (url.host?.contains(".") ?? false)
        }
    }

    static func numeric(message: String = "Digits only") -> KitoValidator {
        KitoValidator(errorMessage: message) { !$0.isEmpty && $0.allSatisfy(\.isNumber) }
    }

    static func alphanumeric(message: String = "Letters and numbers only") -> KitoValidator {
        KitoValidator(errorMessage: message) { !$0.isEmpty && $0.allSatisfy { $0.isLetter || $0.isNumber } }
    }

    static func containsUppercase(message: String = "At least one uppercase letter") -> KitoValidator {
        KitoValidator(errorMessage: message) { $0.contains(where: \.isUppercase) }
    }

    static func containsLowercase(message: String = "At least one lowercase letter") -> KitoValidator {
        KitoValidator(errorMessage: message) { $0.contains(where: \.isLowercase) }
    }

    static func containsDigit(message: String = "At least one number") -> KitoValidator {
        KitoValidator(errorMessage: message) { $0.contains(where: \.isNumber) }
    }

    static func containsSymbol(message: String = "At least one symbol") -> KitoValidator {
        KitoValidator(errorMessage: message) { $0.contains { !$0.isLetter && !$0.isNumber && !$0.isWhitespace } }
    }

    static func noWhitespace(message: String = "No spaces") -> KitoValidator {
        KitoValidator(errorMessage: message) { !$0.contains(where: \.isWhitespace) }
    }

    static func regex(_ pattern: String, message: String) -> KitoValidator {
        KitoValidator(errorMessage: message) { $0.range(of: pattern, options: .regularExpression) != nil }
    }

    /// A number between `range`'s bounds, inclusive. Accepts "1,200.50" style grouping.
    static func number(in range: ClosedRange<Double>, message: String? = nil) -> KitoValidator {
        KitoValidator(errorMessage: message ?? "Enter a number from \(Self.format(range.lowerBound)) to \(Self.format(range.upperBound))") { value in
            guard let number = Double(value.replacingOccurrences(of: ",", with: "").trimmingCharacters(in: .whitespaces)) else { return false }
            return range.contains(number)
        }
    }

    /// The Luhn checksum every payment card number passes. Spaces and dashes are ignored.
    static func luhn(message: String = "Check the card number") -> KitoValidator {
        KitoValidator(errorMessage: message) { kitoPassesLuhn($0) }
    }

    /// Rejects values in `blocked`, ignoring case: reserved usernames, taken handles.
    static func notOneOf(_ blocked: [String], message: String = "That one isn't available") -> KitoValidator {
        let lowered = Set(blocked.map { $0.lowercased() })
        return KitoValidator(errorMessage: message) { !lowered.contains($0.lowercased()) }
    }

    /// Accepts only values in `allowed`, ignoring case: promo codes, country codes.
    static func oneOf(_ allowed: [String], message: String = "Not a recognised value") -> KitoValidator {
        let lowered = Set(allowed.map { $0.lowercased() })
        return KitoValidator(errorMessage: message) { lowered.contains($0.lowercased()) }
    }

    /// A strong password: length plus each character class.
    static func strongPassword(minLength: Int = 8) -> [KitoValidator] {
        [.minLength(minLength, message: "At least \(minLength) characters"), .containsUppercase(), .containsLowercase(), .containsDigit(), .containsSymbol()]
    }

    private static func format(_ value: Double) -> String {
        value.rounded() == value ? String(Int(value)) : String(value)
    }
}

/// True when `number` (spaces and dashes ignored) has 12–19 digits and a valid Luhn checksum.
public func kitoPassesLuhn(_ number: String) -> Bool {
    let digits = number.filter { $0 != " " && $0 != "-" }
    guard (12...19).contains(digits.count), digits.allSatisfy(\.isNumber) else { return false }
    var sum = 0
    for (offset, character) in digits.reversed().enumerated() {
        guard var digit = character.wholeNumberValue else { return false }
        if offset % 2 == 1 {
            digit *= 2
            if digit > 9 { digit -= 9 }
        }
        sum += digit
    }
    return sum % 10 == 0
}

// MARK: - Reports

/// One rule's outcome, for checklists that show every rule rather than the first failure.
public struct KitoRuleResult: Equatable, Sendable, Identifiable {
    public var id: Int
    public var message: String
    public var passed: Bool
}

/// Every rule's outcome, in order.
public func kitoEvaluate(_ value: String, rules: [KitoValidator]) -> [KitoRuleResult] {
    rules.enumerated().map { index, rule in
        KitoRuleResult(id: index, message: rule.errorMessage, passed: rule.validate(value) == nil)
    }
}

/// Every failure message, in order: for an error summary rather than a single line.
public func kitoValidateAll(_ value: String, rules: [KitoValidator]) -> [String] {
    rules.compactMap { $0.validate(value) }
}

// MARK: - Password feedback

public extension KitoPasswordStrength {
    /// What would make `password` stronger, most useful first. Empty once it's very strong.
    static func suggestions(for password: String) -> [String] {
        var tips: [String] = []
        if password.count < 8 { tips.append("Use at least 8 characters") } else if password.count < 12 { tips.append("Longer is stronger: try 12 or more") }
        if password.rangeOfCharacter(from: .uppercaseLetters) == nil { tips.append("Add an uppercase letter") }
        if password.rangeOfCharacter(from: .decimalDigits) == nil { tips.append("Add a number") }
        if password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()-_=+[]{};:,.<>?/")) == nil { tips.append("Add a symbol like ! or #") }
        return tips
    }

    /// 0...1, for a meter.
    var fraction: Double { Double(rawValue + 1) / 5 }
}

// MARK: - Forms

/// Validates a whole form: register each field's value and rules, then ask for errors, the first
/// error, or whether it's all valid. Values are read when you ask, so it stays current.
public struct KitoFormValidator {
    public struct Field {
        public let name: String
        public let value: () -> String
        public let rules: [KitoValidator]
    }

    public private(set) var fields: [Field] = []

    public init() {}

    public mutating func add(_ name: String, value: @escaping () -> String, rules: [KitoValidator]) {
        fields.append(Field(name: name, value: value, rules: rules))
    }

    /// The first failure per field, keyed by field name. Valid fields are absent.
    public var errors: [String: String] {
        fields.reduce(into: [:]) { result, field in
            if let error = kitoValidate(field.value(), rules: field.rules) { result[field.name] = error }
        }
    }

    /// The first failing field in registration order, for scrolling to it.
    public var firstInvalidField: String? {
        fields.first { kitoValidate($0.value(), rules: $0.rules) != nil }?.name
    }

    public var isValid: Bool { firstInvalidField == nil }

    /// How many fields pass, for a "3 of 5 complete" progress line.
    public var validCount: Int {
        fields.filter { kitoValidate($0.value(), rules: $0.rules) == nil }.count
    }
}
