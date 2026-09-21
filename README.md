# KitoValidation

Composable field validators and a password-strength scorer. The canonical
place `KitoFields`-based forms (and any custom form) put validation logic —
so it lives in one testable, reusable spot instead of scattered `if` chains.

## Install

```swift
.package(url: "https://github.com/WykSofts-Inc/KitoValidation.git", from: "1.0.0"),
```

## Samples

**Single field:**
```swift
let error = KitoValidator.email().validate(emailText)
```

**Compose rules, first failure wins:**
```swift
let passwordRules: [KitoValidator] = [
    .required(),
    .minLength(8),
    .custom(message: "Needs a number") { $0.contains { $0.isNumber } },
]
let error = kitoValidate(passwordText, rules: passwordRules)
```

**Confirm-password matching:**
```swift
let confirmRules: [KitoValidator] = [.required(), .matches(passwordText)]
```

**Sign-up ViewModel wiring it all together:**
```swift
@Observable final class SignUpViewModel {
    var email = ""
    var password = ""
    var confirmPassword = ""
    var emailError: String?
    var passwordError: String?

    var passwordStrength: KitoPasswordStrength { .evaluate(password) }

    func validate() -> Bool {
        emailError = kitoValidate(email, rules: [.required(), .email()])
        passwordError = kitoValidate(password, rules: [.required(), .minLength(8)])
        return emailError == nil && passwordError == nil
    }
}
```

**Strength meter:**
```swift
ProgressView(value: Double(viewModel.passwordStrength.rawValue), total: 4)
Text(viewModel.passwordStrength.label)
```

## License

MIT
