# Firebase Setup For This Project

This project is prepared so Firebase will initialize automatically after two things are added:

1. The Firebase Apple SDK package
2. `GoogleService-Info.plist`

## Correct config file

For iPhone/iPad apps, Firebase uses:

`GoogleService-Info.plist`

Do not use `google-services.json` in this iOS project. That file is for Android.

## Where to put the Firebase file from VS Code

Copy your downloaded Firebase Apple config file to:

`AlgoFlash/GoogleService-Info.plist`

That keeps the file inside the app folder next to the Swift files.

## What is already done

- `AlgoFlash/AlgoFlashApp.swift` now contains Firebase startup code.
- When the app launches, it looks for `GoogleService-Info.plist` in the app bundle and configures Firebase automatically.

## What you can do from Windows and VS Code

1. In Firebase Console, make sure you registered the Apple app using this bundle ID:
   `com.project.AlgoFlash`
2. Download `GoogleService-Info.plist`
3. Put the file in:
   `AlgoFlash/GoogleService-Info.plist`
4. Save and commit your code if you are using git
5. Send the project to your friend's Mac

## Minimum steps on your friend's Mac at night

Because this is an iOS app, the Apple toolchain still has to run on macOS. The smallest Xcode step is:

1. Open `AlgoFlash.xcodeproj`
2. Add the Firebase package:
   `File -> Add Package Dependencies`
3. Use this package URL:
   `https://github.com/firebase/firebase-ios-sdk`
4. Add at least:
   `FirebaseCore`
5. Confirm `GoogleService-Info.plist` appears inside the `AlgoFlash` target
6. Build and run

## If you want more Firebase products

Add the product that matches what you need:

- Auth: `FirebaseAuth`
- Firestore: `FirebaseFirestore`
- Storage: `FirebaseStorage`
- Analytics: `FirebaseAnalytics`
- Messaging: `FirebaseMessaging`

## Important limitation

You can prepare almost everything in VS Code on Windows, but you cannot fully finish native iOS package resolution, signing, and app build without a Mac or macOS CI.

## Alternative if you want true VS Code only

If you want to avoid the native Firebase iOS SDK completely, some Firebase services can be used through REST APIs from Swift `URLSession`, for example:

- Firebase Auth REST API
- Cloud Firestore REST API

That approach works from VS Code only, but you lose the normal Apple SDK integration and features like Analytics, Crashlytics, and easier Auth/Firestore client support.


add pakages via:
https://github.com/firebase/firebase-ios-sdk


needed code:
import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct YourApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
      }
    }
  }
}
