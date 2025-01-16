# **Design: Resmart**

## **Login Screen**

### **1. Welcome Screen**
**Purpose**: The starting point for all users.
- **Elements**:
  - App logo (centered at the top).
  - Welcome message: "Welcome to Resmart".
  - Four buttons:
    1. "Continue with Email" (email icon next to text).
    2. "Continue with Google" (Google logo next to text).
    3. "Continue with GitHub" (GitHub logo next to text).
    4. "Continue without an Account".
  - Footer with "Terms and Conditions" link.

---

### **2. Email Flow Screens**

#### a) **Email Input Screen**
- **Elements**:
  - Header: "Sign in with Email".
  - Input field: "Enter your email".
  - Button: "Next".

#### b) **Existing User OTP Verification**
- **Elements**:
  - Header: "Enter OTP".
  - OTP input fields (4-6 digits).
  - Button: "Verify".
  - Resend OTP option.

#### c) **New User Registration**
- **Elements**:
  - Header: "Create Your Account".
  - Input fields:
    1. First Name.
    2. Last Name.
    3. Email.
    4. Username.
    5. Password.
    6. Phone Number (optional, small text: "Can be added later").
  - Checkbox: "I agree to the Terms and Conditions".
  - Button: "Register".

#### d) **Email Verification**
- **Elements**:
  - Header: "Verify Your Email".
  - Instructional text: "Enter the OTP sent to your email".
  - OTP input fields.
  - Button: "Verify".

#### e) **Nickname Input Screen**
- **Elements**:
  - Header: "Welcome to Resmart".
  - Optional input field: "Enter a nickname (optional)".
  - Button: "Continue".

---

### **3. Google and GitHub Flow Screens**

#### a) **Authentication Screen**
- **Elements**:
  - Header: "Sign in with Google" or "Sign in with GitHub".
  - Button for authentication (handled by respective SDKs).

#### b) **Phone Verification Screen** (for new users)
- **Elements**:
  - Header: "Verify Your Phone".
  - Input field: "Enter your phone number".
  - OTP input fields for verification.
  - Button: "Verify".

#### c) **Nickname Input Screen**
- Same as the Email flow's Nickname Input Screen.

---

### **4. Guest Access Flow**

#### a) **Guest Warning Screen**
- **Elements**:
  - Header: "Proceed as Guest".
  - Warning text: "Some features may not be available without an account".
  - Checkbox: "I agree to the Terms and Conditions".
  - Button: "Continue".

---

### **UI Components Consistency**
To ensure consistency across the app:
1. **Buttons**: Use a primary color (e.g., blue) for action buttons and secondary color (e.g., gray) for less prominent actions.
2. **Typography**: Clear and readable fonts (e.g., Open Sans or Roboto).
3. **Spacing**: Adequate padding between elements for touch-friendly interaction.
4. **Icons**: Use standard icons (Material Icons or Font Awesome) for email, Google, GitHub, and other elements.
5. **Feedback**: Show loaders during processing (e.g., "Verifying...").

---

### **Visual Hierarchy Example (Wireframe for Welcome Screen)**

- **Top**: App Logo (centered).
- **Middle**: Welcome text: "Welcome to Resmart".
- **Bottom**: Four equally spaced buttons:
  1. **Email**: Icon + "Continue with Email".
  2. **Google**: Icon + "Continue with Google".
  3. **GitHub**: Icon + "Continue with GitHub".
  4. **Guest**: "Continue without an Account".
- **Footer**: Small text link: "Terms and Conditions".

---

If you’d like, I can create a visual wireframe or mockup for one or more screens! Let me know. 😊