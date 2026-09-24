//
//  KitoValidatorMoreTests.swift
//  KitoValidation
//
//  Created by Wycliff on 9/23/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import XCTest
@testable import KitoValidation

final class KitoValidatorMoreTests: XCTestCase {
    func testURLs() {
        XCTAssertNil(KitoValidationRule.url().validate("https://wyksoftsinc.com"))
        XCTAssertNil(KitoValidationRule.url().validate("http://a.io/path?q=1"))
        XCTAssertNotNil(KitoValidationRule.url().validate("wyksoftsinc.com"), "needs a scheme")
        XCTAssertNotNil(KitoValidationRule.url().validate("ftp://files.example.com"))
        XCTAssertNotNil(KitoValidationRule.url().validate("https://localhost"), "needs a real host")
    }

    func testCharacterClasses() {
        XCTAssertNil(KitoValidationRule.numeric().validate("0712345678"))
        XCTAssertNotNil(KitoValidationRule.numeric().validate("07123 45678"))
        XCTAssertNotNil(KitoValidationRule.numeric().validate(""))
        XCTAssertNil(KitoValidationRule.alphanumeric().validate("Kito2026"))
        XCTAssertNotNil(KitoValidationRule.alphanumeric().validate("kito_2026"))
        XCTAssertNil(KitoValidationRule.containsUppercase().validate("abC"))
        XCTAssertNil(KitoValidationRule.containsLowercase().validate("ABc"))
        XCTAssertNil(KitoValidationRule.containsDigit().validate("ab1"))
        XCTAssertNil(KitoValidationRule.containsSymbol().validate("ab!"))
        XCTAssertNotNil(KitoValidationRule.containsSymbol().validate("ab 1"), "a space isn't a symbol")
        XCTAssertNotNil(KitoValidationRule.noWhitespace().validate("a b"))
    }

    func testLengthsAndRanges() {
        XCTAssertNil(KitoValidationRule.exactLength(6).validate("123456"))
        XCTAssertNotNil(KitoValidationRule.exactLength(6).validate("12345"))
        XCTAssertNil(KitoValidationRule.number(in: 1...100).validate("42"))
        XCTAssertNil(KitoValidationRule.number(in: 0...5_000).validate("1,200.50"))
        XCTAssertNotNil(KitoValidationRule.number(in: 1...100).validate("101"))
        XCTAssertNotNil(KitoValidationRule.number(in: 1...100).validate("abc"))
        XCTAssertEqual(KitoValidationRule.number(in: 1...100).errorMessage, "Enter a number from 1 to 100")
    }

    func testLuhn() {
        XCTAssertTrue(kitoPassesLuhn("4111 1111 1111 1111"))
        XCTAssertTrue(kitoPassesLuhn("3782-822463-10005"))
        XCTAssertFalse(kitoPassesLuhn("4111 1111 1111 1112"))
        XCTAssertFalse(kitoPassesLuhn("4111"), "too short")
        XCTAssertFalse(kitoPassesLuhn("4111 1111 1111 111a"))
    }

    func testAllowAndBlockLists() {
        XCTAssertNotNil(KitoValidationRule.notOneOf(["admin", "root"]).validate("Admin"))
        XCTAssertNil(KitoValidationRule.notOneOf(["admin", "root"]).validate("wycliff"))
        XCTAssertNil(KitoValidationRule.oneOf(["SAVE20"]).validate("save20"))
        XCTAssertNotNil(KitoValidationRule.oneOf(["SAVE20"]).validate("SAVE30"))
    }

    func testStrongPasswordRules() {
        XCTAssertTrue(kitoValidateAll("Kito#2026", rules: KitoValidationRule.strongPassword()).isEmpty)
        XCTAssertEqual(kitoValidateAll("kito", rules: KitoValidationRule.strongPassword()).count, 4)
    }

    func testEvaluateReportsEveryRule() {
        let results = kitoEvaluate("abc", rules: [.minLength(8), .containsDigit(), .containsLowercase()])
        XCTAssertEqual(results.map(\.passed), [false, false, true])
        XCTAssertEqual(results.map(\.id), [0, 1, 2])
    }

    func testSuggestionsShrinkAsThePasswordImproves() {
        XCTAssertEqual(KitoPasswordScore.suggestions(for: "abc").count, 4)
        XCTAssertTrue(KitoPasswordScore.suggestions(for: "Kito#2026-strong").isEmpty)
        XCTAssertEqual(KitoPasswordScore.veryStrong.fraction, 1)
    }

    func testTheFormValidatorReadsLiveValues() {
        var email = ""
        var name = "Amina"
        var form = KitoFormValidator()
        form.add("name", value: { name }, rules: [.required()])
        form.add("email", value: { email }, rules: [.required(), .email()])

        XCTAssertFalse(form.isValid)
        XCTAssertEqual(form.firstInvalidField, "email")
        XCTAssertEqual(form.validCount, 1)

        email = "amina@example.com"
        XCTAssertTrue(form.isValid)
        XCTAssertTrue(form.errors.isEmpty)

        name = ""
        XCTAssertEqual(form.errors, ["name": "This field is required"])
    }
}
