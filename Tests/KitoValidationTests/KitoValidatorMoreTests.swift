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
        XCTAssertNil(KitoValidator.url().validate("https://wyksoftsinc.com"))
        XCTAssertNil(KitoValidator.url().validate("http://a.io/path?q=1"))
        XCTAssertNotNil(KitoValidator.url().validate("wyksoftsinc.com"), "needs a scheme")
        XCTAssertNotNil(KitoValidator.url().validate("ftp://files.example.com"))
        XCTAssertNotNil(KitoValidator.url().validate("https://localhost"), "needs a real host")
    }

    func testCharacterClasses() {
        XCTAssertNil(KitoValidator.numeric().validate("0712345678"))
        XCTAssertNotNil(KitoValidator.numeric().validate("07123 45678"))
        XCTAssertNotNil(KitoValidator.numeric().validate(""))
        XCTAssertNil(KitoValidator.alphanumeric().validate("Kito2026"))
        XCTAssertNotNil(KitoValidator.alphanumeric().validate("kito_2026"))
        XCTAssertNil(KitoValidator.containsUppercase().validate("abC"))
        XCTAssertNil(KitoValidator.containsLowercase().validate("ABc"))
        XCTAssertNil(KitoValidator.containsDigit().validate("ab1"))
        XCTAssertNil(KitoValidator.containsSymbol().validate("ab!"))
        XCTAssertNotNil(KitoValidator.containsSymbol().validate("ab 1"), "a space isn't a symbol")
        XCTAssertNotNil(KitoValidator.noWhitespace().validate("a b"))
    }

    func testLengthsAndRanges() {
        XCTAssertNil(KitoValidator.exactLength(6).validate("123456"))
        XCTAssertNotNil(KitoValidator.exactLength(6).validate("12345"))
        XCTAssertNil(KitoValidator.number(in: 1...100).validate("42"))
        XCTAssertNil(KitoValidator.number(in: 0...5_000).validate("1,200.50"))
        XCTAssertNotNil(KitoValidator.number(in: 1...100).validate("101"))
        XCTAssertNotNil(KitoValidator.number(in: 1...100).validate("abc"))
        XCTAssertEqual(KitoValidator.number(in: 1...100).errorMessage, "Enter a number from 1 to 100")
    }

    func testLuhn() {
        XCTAssertTrue(kitoPassesLuhn("4111 1111 1111 1111"))
        XCTAssertTrue(kitoPassesLuhn("3782-822463-10005"))
        XCTAssertFalse(kitoPassesLuhn("4111 1111 1111 1112"))
        XCTAssertFalse(kitoPassesLuhn("4111"), "too short")
        XCTAssertFalse(kitoPassesLuhn("4111 1111 1111 111a"))
    }

    func testAllowAndBlockLists() {
        XCTAssertNotNil(KitoValidator.notOneOf(["admin", "root"]).validate("Admin"))
        XCTAssertNil(KitoValidator.notOneOf(["admin", "root"]).validate("wycliff"))
        XCTAssertNil(KitoValidator.oneOf(["SAVE20"]).validate("save20"))
        XCTAssertNotNil(KitoValidator.oneOf(["SAVE20"]).validate("SAVE30"))
    }

    func testStrongPasswordRules() {
        XCTAssertTrue(kitoValidateAll("Kito#2026", rules: KitoValidator.strongPassword()).isEmpty)
        XCTAssertEqual(kitoValidateAll("kito", rules: KitoValidator.strongPassword()).count, 4)
    }

    func testEvaluateReportsEveryRule() {
        let results = kitoEvaluate("abc", rules: [.minLength(8), .containsDigit(), .containsLowercase()])
        XCTAssertEqual(results.map(\.passed), [false, false, true])
        XCTAssertEqual(results.map(\.id), [0, 1, 2])
    }

    func testSuggestionsShrinkAsThePasswordImproves() {
        XCTAssertEqual(KitoPasswordStrength.suggestions(for: "abc").count, 4)
        XCTAssertTrue(KitoPasswordStrength.suggestions(for: "Kito#2026-strong").isEmpty)
        XCTAssertEqual(KitoPasswordStrength.veryStrong.fraction, 1)
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
