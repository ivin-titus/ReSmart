# **Design: Resmart**

## **Login Screen**

### **1. Welcome Screen** [front-end done]
**Purpose**: The starting point for all users.
- **Elements**:
  - App logo (centered at the top).
  - Welcome message: "Welcome to Resmart".
  - Four buttons:
    1. "Continue with Email" (email icon next to text).
    2. "Continue with Google" (Google logo next to text).
    3. "Continue with GitHub" (GitHub logo next to text).
    4. "Continue without an Account" (Guest user icon next to text).
  - Footer with "Terms and Conditions" link.

---

### **2. Email Flow Screens**

#### a) **Email Input Screen**              [front-end done]
- **Elements**:
  - Header: "Sign in with Email".
  - Input field: "Enter your email".
  - Button: "Next".

#### b) **User OTP Verification**          [front-end done]
- **Elements**:
  - Header: "Enter OTP".
  - OTP input fields (4-6 digits).
  - Button: "Verify".
  - Resend OTP option.

#### c) **New User Registration**           [front-end done]
- **Elements**:
  - Header: "Create Your Account".
  - Input fields:
    1. First Name.
    2. Last Name.
    3. Username.
  - Checkbox: "I agree to the Privacy Policy and Terms and Conditions".
  - Button: "Register".

Here's an enhanced version of the **Nickname Input Screen** with more polished language, better flow, and a more user-friendly approach:

---

### **d) Nickname Input Screen**                [front-end done]

**Elements:**
- **Header:**  
   - "Welcome to Resmart, [User's Name]!"  
     _(Personalized greeting based on user data, if available.)_
- **Input Field:**  
   - **Label:** "Choose your nickname (Optional)"  
     _"A nickname helps personalize your experience."_
     _(Tooltip or info icon for explanation if necessary)_
- **Informational Text:**  
   - "You can always update your nickname, Date of Birth, additional phone numbers, or email addresses later in the settings for added security."  
     _(A softer tone, emphasizing flexibility and security.)_
- **Call-to-Action Text:**  
   - "Why add more? More details means better security and personalization."  
     _(Reinforcing the security aspect with a positive, reassuring tone.)_
- **Action Button:**  
   - **Label:** "Continue"  
     _(Simple and clear, no need for extra verbiage.)_

---

### **3. Google and GitHub Flow Screens**

#### a) **Authentication Screen**
- **Elements**:
  - Header: "Sign in with Google" or "Sign in with GitHub".
  - Button for authentication (handled by respective SDKs).

#### b) **Phone Verification Screen** (for new users) [frontend done]
- **Elements**:
  - Header: "Verify Your Phone".
  - Input field: "Enter your phone number".
  - OTP input fields for verification.
  - Button: "Verify".

#### c) **Nickname Input Screen**
- Same as the Email flow's Nickname Input Screen.

---

### **4. Guest Access Flow**                         [frontend done]

### **a) Guest Warning Screen** 

**Elements:**
- **Header:**  
   - "Proceed as a Guest – Limited Access"  
     _(The addition of "Limited Access" sets clear expectations about functionality.)_

- **Warning Text:**  
   - **Main Text:**  
     "By proceeding as a guest, some features will be unavailable until you create an account."  
     _(This rephrasing ensures clarity and softens the warning tone.)_

   - **Feature List (with bullets for clarity):**  
     "Without an account, the following features will be restricted or unavailable:  
     - Advanced AI Assistant capabilities  
     - Widgets on the Always-On display  
     - Companion device section in the Device tab  
     - Shared notifications across devices  
     - Some tools in the Tools tab"  
     _(Clarifying the restrictions with bullet points makes it easier to read and understand.)_

- **Disclaimer Text (with an emphasis on user control and consent):**  
   - "You can unlock all features by signing up, but if you choose to proceed without an account, you'll still be able to use basic functionality."

- **Checkbox with Agreement:**  
   - **Text:**  
     "I agree to the [Privacy Policy] and [Terms & Conditions]"  
     _(Hyperlinked text buttons for legal agreement, keeping it clean and concise.)_

- **Action Button:**  
   - **Label:**  
     "Continue as Guest"  
     _(A more descriptive action button, indicating the choice to proceed as a guest.)_

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
