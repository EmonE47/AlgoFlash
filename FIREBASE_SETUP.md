# Firebase Setup For This Project

This project is now wired for:

1. Firebase Core initialization
2. Email/password sign in
3. Email/password account creation
4. Google sign-in
5. Firestore user profile sync to `users/{uid}`

## Correct config file

For Apple platforms, Firebase uses:

`GoogleService-Info.plist`

Do not use `google-services.json` in this iOS project. That file is for Android.

## Where the config file goes

Place the file here:

`AlgoFlash/GoogleService-Info.plist`

That is the app folder beside the Swift files.

## What is already done in the repo

- `AlgoFlash/AlgoFlashApp.swift` configures Firebase on launch.
- `AlgoFlash/AuthenticationViewModel.swift` contains the real authentication logic.
- `AlgoFlash/AuthFlowView.swift` and the auth UI files call the real login/register/Google actions.
- `AlgoFlash/Info.plist` contains the Google callback URL scheme for the current Firebase app.
- `AlgoFlash.xcodeproj/project.pbxproj` now includes Swift Package references for:
  - `FirebaseCore`
  - `FirebaseAuth`
  - `FirebaseFirestore`
  - `GoogleSignIn`

## Important note about the Google URL scheme

`AlgoFlash/Info.plist` currently contains the reversed client ID from the current `GoogleService-Info.plist`.

If you ever replace `GoogleService-Info.plist` with a new Firebase app config, make sure the URL scheme inside `AlgoFlash/Info.plist` matches the new `REVERSED_CLIENT_ID`.

## Minimum steps on the Mac

1. Open `AlgoFlash.xcodeproj`
2. Let Xcode resolve the Swift packages
3. Confirm `GoogleService-Info.plist` is included in the `AlgoFlash` target
4. Build and run

## If package resolution fails

Open the project in Xcode and check:

1. `File -> Packages -> Resolve Package Versions`
2. The package URLs are:
   - `https://github.com/firebase/firebase-ios-sdk.git`
   - `https://github.com/google/GoogleSignIn-iOS.git`

## Expected Firebase Console setup

Make sure these are enabled in Firebase Console:

- Authentication -> Email/Password
- Authentication -> Google
- Firestore Database if you want profile documents synced

## What should work after Xcode resolves packages

- Login with email/password
- Register with email/password
- Google sign-in
- Persistent signed-in session
- Sign out
- Firestore user profile merge for authenticated users

## Remaining limitation

The codebase is prepared from Windows, but the final native build and actual iOS runtime test still require Xcode/macOS.
