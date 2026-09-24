//
//  KitoValidationTests.swift
//  KitoValidation
//
//  Created by Wycliff on 7/10/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import XCTest
@testable import KitoValidation

final class KitoValidationTests: XCTestCase {
    func testRequiredRejectsBlank() {
        XCTAssertNotNil(KitoValidationRule.required().validate("   "))
        XCTAssertNil(KitoValidationRule.required().validate("hi"))
    }

    func testEmailValidator() {
        XCTAssertNil(KitoValidationRule.email().validate("a@b.com"))
        XCTAssertNotNil(KitoValidationRule.email().validate("not-an-email"))
    }

    func testFirstFailureWins() {
        let rules: [KitoValidationRule] = [.required(), .minLength(5)]
        XCTAssertEqual(kitoValidate("", rules: rules), KitoValidationRule.required().errorMessage)
    }

    func testMatchesValidator() {
        let password = "hunter22"
        let rule = KitoValidationRule.matches(password)
        XCTAssertNil(rule.validate("hunter22"))
        XCTAssertNotNil(rule.validate("hunter23"))
    }

    func testPasswordStrengthOrdering() {
        XCTAssertLessThan(KitoPasswordScore.evaluate("abc"), KitoPasswordScore.evaluate("Abc12345!"))
    }
}
