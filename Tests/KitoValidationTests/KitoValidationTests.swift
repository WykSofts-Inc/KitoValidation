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
        XCTAssertNotNil(KitoValidator.required().validate("   "))
        XCTAssertNil(KitoValidator.required().validate("hi"))
    }

    func testEmailValidator() {
        XCTAssertNil(KitoValidator.email().validate("a@b.com"))
        XCTAssertNotNil(KitoValidator.email().validate("not-an-email"))
    }

    func testFirstFailureWins() {
        let rules: [KitoValidator] = [.required(), .minLength(5)]
        XCTAssertEqual(kitoValidate("", rules: rules), KitoValidator.required().errorMessage)
    }

    func testMatchesValidator() {
        let password = "hunter22"
        let rule = KitoValidator.matches(password)
        XCTAssertNil(rule.validate("hunter22"))
        XCTAssertNotNil(rule.validate("hunter23"))
    }

    func testPasswordStrengthOrdering() {
        XCTAssertLessThan(KitoPasswordStrength.evaluate("abc"), KitoPasswordStrength.evaluate("Abc12345!"))
    }
}
