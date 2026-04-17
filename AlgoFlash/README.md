# AlgoFlash Authentication Redesign

This project has been redesigned from scratch with a simple, classical authentication flow using Firebase.

## Implemented

- Email/password `Login`
- Email/password `Sign Up`
- One-click `Continue with Gmail` (Google Sign-In + FirebaseAuth)
- Firebase initialization on app launch
- Session persistence (if Firebase user is already logged in)
- Logout screen after successful authentication

## Project Structure

- `AlgoFlash/AlgoFlashApp.swift`: Firebase startup configuration
- `AlgoFlash/ContentView.swift`: Auth vs signed-in screen routing
- `AlgoFlash/Services/AuthService.swift`: FirebaseAuth wrapper methods
- `AlgoFlash/ViewModels/AuthViewModel.swift`: Form/auth state management
- `AlgoFlash/Views/AuthView.swift`: Simple login/signup UI + home/logout UI

## Firebase Console Requirements

1. Open Firebase Console -> Authentication -> Sign-in method.
2. Enable `Email/Password` provider.
3. Enable `Google` provider.
4. Keep `GoogleService-Info.plist` in `AlgoFlash/GoogleService-Info.plist`.

## Xcode Requirements (on macOS)

The project file already includes:

- Firebase iOS SDK package
- GoogleSignIn-iOS package
- URL scheme from your current `GoogleService-Info.plist`

If you replace Firebase project/config later, update the URL scheme in target build settings (`CFBundleURLTypes`) to the new `REVERSED_CLIENT_ID`.
