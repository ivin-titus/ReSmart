# **UI Flowchart - Resmart**


## **Login Process**

```mermaid
flowchart TD
    %% Main App Entry
    Start[Open App] --> LogoScreen[App Logo and Welcome Screen]
    LogoScreen --> LoginOptionsScreen[Login Options Screen]

    %% Login Options Screen
    LoginOptionsScreen --> EmailOption[Button: Continue with Email]
    LoginOptionsScreen --> GoogleOption[Button: Continue with Google]
    LoginOptionsScreen --> GitHubOption[Button: Continue with GitHub]
    LoginOptionsScreen --> GuestOption[Button: Continue without an Account]

    %% Email Flow
    EmailOption --> EmailCheckScreen[Screen: Enter Email Address]
    EmailCheckScreen -->|Existing User| OTPInputScreen[Screen: Enter OTP]
    OTPInputScreen --> EmailLoginSuccess[Screen: Welcome Back, {username or user_nickname}]
    EmailCheckScreen -->|New User| EmailRegistrationScreen[Screen: Registration Form]
    EmailRegistrationScreen --> EmailVerifyScreen[Screen: Enter OTP for Email Verification]
    EmailVerifyScreen --> TCAgreeScreen1[Screen: Agree to Terms & Conditions]
    TCAgreeScreen1 --> OptionalNickScreen1[Screen: Enter Optional Nickname]
    OptionalNickScreen1 --> EmailRegistrationSuccess[Screen: Welcome to Resmart]

    %% Google Flow
    GoogleOption --> GoogleAuthScreen[Screen: Authenticate with Google]
    GoogleAuthScreen -->|New User| GoogleWelcomeScreen[Screen: Welcome Screen for New User]
    GoogleWelcomeScreen --> GooglePhoneScreen[Screen: Enter Phone Number for OTP Verification]
    GooglePhoneScreen --> TCAgreeScreen2[Screen: Agree to Terms & Conditions]
    TCAgreeScreen2 --> OptionalNickScreen2[Screen: Enter Optional Nickname]
    OptionalNickScreen2 --> GoogleLoginSuccess[Screen: Login Successful]
    GoogleAuthScreen -->|Existing User| GoogleLoginSuccess[Screen: Welcome Back, {username or user_nickname}]

    %% GitHub Flow
    GitHubOption --> GitHubAuthScreen[Screen: Authenticate with GitHub]
    GitHubAuthScreen -->|New User| GitHubWelcomeScreen[Screen: Welcome Screen for New User]
    GitHubWelcomeScreen --> GitHubPhoneScreen[Screen: Enter Phone Number for OTP Verification]
    GitHubPhoneScreen --> TCAgreeScreen3[Screen: Agree to Terms & Conditions]
    TCAgreeScreen3 --> OptionalNickScreen3[Screen: Enter Optional Nickname]
    OptionalNickScreen3 --> GitHubLoginSuccess[Screen: Login Successful]
    GitHubAuthScreen -->|Existing User| GitHubLoginSuccess[Screen: Welcome Back, {username or user_nickname}]

    %% Guest Flow
    GuestOption --> GuestWarningScreen[Screen: Warning - Limited Features Available]
    GuestWarningScreen --> TCAgreeScreen4[Screen: Agree to Terms & Conditions]
    TCAgreeScreen4 --> GuestAccessScreen[Screen: Proceed as Guest]
```

