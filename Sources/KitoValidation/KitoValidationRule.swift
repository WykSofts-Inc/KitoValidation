//
//  KitoValidationRule.swift
//  KitoValidation
//
//  Created by Wycliff on 7/9/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import Foundation

/// A single rule over a `String`. Composable — `KitoFields` (and any custom
/// form) runs an array of these per field and surfaces the first failure.
public struct KitoValidationRule: Sendable {
    public let errorMessage: String
    private let predicate: @Sendable (String) -> Bool

    public init(errorMessage: String, predicate: @escaping @Sendable (String) -> Bool) {
        self.errorMessage = errorMessage
        self.predicate = predicate
    }

    public func validate(_ value: String) -> String? {
        predicate(value) ? nil : errorMessage
    }
}

/// Runs every validator in order, returning the first failure — so a field
/// showing "Required" doesn't simultaneously flash "Invalid email" once it
/// has one character in it.
public func kitoValidate(_ value: String, rules: [KitoValidationRule]) -> String? {
    for rule in rules {
        if let error = rule.validate(value) { return error }
    }
    return nil
}

public extension KitoValidationRule {
    static func required(message: String = "This field is required") -> KitoValidationRule {
        KitoValidationRule(errorMessage: message) { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    static func minLength(_ length: Int, message: String? = nil) -> KitoValidationRule {
        KitoValidationRule(errorMessage: message ?? "Must be at least \(length) characters") { $0.count >= length }
    }

    static func maxLength(_ length: Int, message: String? = nil) -> KitoValidationRule {
        KitoValidationRule(errorMessage: message ?? "Must be \(length) characters or fewer") { $0.count <= length }
    }

    static func email(message: String = "Enter a valid email address") -> KitoValidationRule {
        KitoValidationRule(errorMessage: message) { value in
            let pattern = #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#
            return value.range(of: pattern, options: .regularExpression) != nil
        }
    }

    static func phone(message: String = "Enter a valid phone number") -> KitoValidationRule {
        KitoValidationRule(errorMessage: message) { value in
            let digits = value.filter(\.isNumber)
            return digits.count >= 9 && digits.count <= 15
        }
    }

    static func matches(_ other: @escaping @autoclosure () -> String, message: String = "Values don't match") -> KitoValidationRule {
        KitoValidationRule(errorMessage: message) { $0 == other() }
    }

    static func custom(message: String, _ predicate: @escaping @Sendable (String) -> Bool) -> KitoValidationRule {
        KitoValidationRule(errorMessage: message, predicate: predicate)
    }
}
