# ``KitoValidation``

Composable field validators, form-level validation, and a password-strength scorer.

## Overview

KitoValidation gives forms one testable, reusable place for validation logic
instead of scattered `if` chains. It is the canonical validation layer for
`KitoFields`-based forms, and it works just as well with any custom form.

A ``KitoValidator`` is a single rule over a `String` that returns an error
message when the value fails. Rules compose as arrays: `kitoValidate(_:rules:)`
returns the first failure, `kitoValidateAll(_:rules:)` returns every failure,
and `kitoEvaluate(_:rules:)` reports each rule as a ``KitoRuleResult`` for
checklist-style UIs.

```swift
let passwordRules: [KitoValidator] = [
    .required(),
    .minLength(8),
    .custom(message: "Needs a number") { $0.contains { $0.isNumber } },
]
let error = kitoValidate(passwordText, rules: passwordRules)
```

To validate a whole screen, register each field with a ``KitoFormValidator``
and read `isValid`, `errors`, `validCount`, or `firstInvalidField`.
``KitoPasswordStrength`` scores a password from very weak to very strong and
suggests improvements, which is enough to drive a strength meter.

## Topics

### Rules

- ``KitoValidator``
- ``KitoRuleResult``

### Forms

- ``KitoFormValidator``

### Passwords

- ``KitoPasswordStrength``
