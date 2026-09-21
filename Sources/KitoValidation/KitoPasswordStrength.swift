//
//  KitoPasswordStrength.swift
//  KitoValidation
//
//  Created by Wycliff on 7/8/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import Foundation

/// A simple, explainable strength score — not a substitute for a real
/// breach-database check, but enough to drive a strength meter UI.
public enum KitoPasswordStrength: Int, Comparable, Sendable {
    case veryWeak = 0, weak, medium, strong, veryStrong

    public static func < (lhs: KitoPasswordStrength, rhs: KitoPasswordStrength) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var label: String {
        switch self {
        case .veryWeak: return "Very weak"
        case .weak: return "Weak"
        case .medium: return "Medium"
        case .strong: return "Strong"
        case .veryStrong: return "Very strong"
        }
    }

    public static func evaluate(_ password: String) -> KitoPasswordStrength {
        var score = 0
        if password.count >= 8 { score += 1 }
        if password.count >= 12 { score += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        if password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()-_=+[]{};:,.<>?/")) != nil { score += 1 }
        return KitoPasswordStrength(rawValue: min(score, 4)) ?? .veryWeak
    }
}
