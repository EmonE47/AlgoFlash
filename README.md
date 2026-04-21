# AlgoFlash

AlgoFlash is a SwiftUI iOS application for learning algorithms through flashcards, timed quizzes, favourites, profile tracking, and live technology news. The app has two role-based workspaces: a learner workspace for study and practice, and an admin workspace for managing educational content and reviewing quiz results.

This README is based on the project report in [report/mark1.tex](report/mark1.tex) and cross-checked against the current Swift source.

## Objectives

- Build an iOS algorithm learning app with SwiftUI.
- Provide interactive flashcards with category filtering and flip views.
- Support Firebase Authentication and Firestore-backed role-based routing.
- Add timed quiz practice with immediate feedback and persisted scores.
- Include learner/admin profile management, favourites, live news, and admin dashboards.

## Features

### Learner

- Email/password sign up and login.
- Role-based routing into the learner tab bar.
- Algorithm flashcards with category filters, difficulty badges, flip animations, definitions, time complexity, and pseudocode.
- Favourites tab synced with the user's Firestore document.
- Timed multiple-choice quiz flow with 30 seconds per question.
- Immediate answer feedback with correct/incorrect highlighting and explanations.
- Quiz result saving with best score and quizzes-taken stats.
- Live technology news feed powered by NewsAPI and `URLSession`.
- Profile page with name/email editing and logout.

### Admin

- Role-based routing into the admin tab bar.
- Add, edit, view, and delete algorithm flashcards.
- Add, edit, view, and delete quiz questions.
- Review all quiz results with user name, email, score, total, timestamp, and visual progress.
- Admin profile page with account details and logout.

## Tech Stack

- **Language:** Swift
- **UI:** SwiftUI
- **Architecture:** MVVM-style presentation layer with service wrappers
- **Backend:** Firebase Authentication and Cloud Firestore
- **Networking:** `URLSession`
- **External API:** NewsAPI
- **Package manager:** Swift Package Manager through Xcode
- **Target:** iOS 26.4 as configured in the Xcode project

Primary Swift Package dependencies are resolved in [Package.resolved](AlgoFlash.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved), including Firebase iOS SDK `12.12.0`.

## Architecture

AlgoFlash follows a SwiftUI-first MVVM structure:

- **Views:** SwiftUI screens render auth, flashcards, favourites, quizzes, news, profile, and admin management flows.
- **ViewModels:** Observable objects own UI state and coordinate data loading or mutations.
- **Models:** Codable/Identifiable types describe users, algorithms, quiz questions, quiz results, and news articles.
- **Services:** Firebase Auth, Firestore CRUD, local JSON loading, and NewsAPI fetching are isolated behind service-like types.
- **Routing:** `ContentView` checks the authenticated session and resolved Firestore role, then routes to `MainTabView` for learners or `AdminTabView` for admins.

The report describes logical folders such as Models, Views, ViewModels, and Services. In the current repository, the Swift files are stored flat under [AlgoFlash/](AlgoFlash/), while still following those logical responsibilities by filename and type.

## Project Structure

```text
AlgoFlash/
|-- AlgoFlash/
|   |-- AlgoFlashApp.swift
|   |-- ContentView.swift
|   |-- AuthService.swift
|   |-- FirestoreService.swift
|   |-- AuthViewModel.swift
|   |-- FlashcardViewModel.swift
|   |-- QuizViewModel.swift
|   |-- ProfileViewModel.swift
|   |-- AdminFlashcardViewModel.swift
|   |-- AdminQuizViewModel.swift
|   |-- AdminResultsViewModel.swift
|   |-- LoginView.swift
|   |-- SignupView.swift
|   |-- MainTabView.swift
|   |-- AdminTabView.swift
|   |-- FlashcardsView.swift
|   |-- FavouritesView.swift
|   |-- QuizView.swift
|   |-- NewsView.swift
|   |-- ProfileView.swift
|   |-- ManageFlashcardsView.swift
|   |-- ManageQuizView.swift
|   |-- AdminResultsView.swift
|   |-- AdminProfileView.swift
|   |-- DesignSystem.swift
|   |-- GoogleService-Info.plist
|   `-- Assets.xcassets/
|-- AlgoFlash.xcodeproj/
|-- report/
|   |-- mark1.tex
|   |-- mark1.pdf
|   `-- SS/
|-- SS/
`-- README.md
```

## Data Model

| Model | Key fields |
| --- | --- |
| `AppUser` | `id`, `email`, `fullName`, `role`, `score`, `quizzesTaken`, `favourites` |
| `Algorithm` | `id`, `title`, `category`, `definition`, `timeComplexity`, `pseudocode`, `difficulty` |
| `QuizQuestion` | `id`, `documentID`, `algorithmId`, `question`, `options`, `correctIndex`, `explanation` |
| `QuizResult` | `id`, `userId`, `userName`, `userEmail`, `score`, `total`, `date` |
| `NewsArticle` | `title`, `source`, `description`, `content`, `urlToImage`, `publishedAt`, `url` |

## Firestore Collections

- `users`: stores account profile, role, best score, quiz count, and favourite algorithm IDs.
- `algorithms`: stores flashcard content.
- `quiz_questions`: stores multiple-choice quiz questions.
- `quiz_results`: stores completed quiz attempts.

## Role Permissions

| Capability | Admin | Learner |
| --- | --- | --- |
| View flashcards | Yes | Yes |
| Take quizzes | No | Yes |
| Save favourites | No | Yes |
| View own profile stats | No | Yes |
| Add flashcard content | Yes | No |
| Add quiz questions | Yes | No |
| View all quiz results | Yes | No |
| Delete content | Yes | No |

User roles are stored in each `AppUser` Firestore document. The sign-up screen currently allows users to choose either learner or admin, which is useful for lab/demo use but should be restricted before production use.

## Setup

### Requirements

- macOS with Xcode installed.
- iOS Simulator or physical iPhone.
- Firebase project with Authentication and Cloud Firestore enabled.
- NewsAPI key if the news endpoint is changed or secured.

### Firebase

1. Create or open a Firebase project.
2. Add an iOS app using the bundle identifier configured in Xcode: `com.project.AlgoFlash`.
3. Download `GoogleService-Info.plist`.
4. Place it at [AlgoFlash/GoogleService-Info.plist](AlgoFlash/GoogleService-Info.plist).
5. Enable Firebase Authentication with the Email/Password provider.
6. Enable Cloud Firestore.
7. Create the collections used by the app: `users`, `algorithms`, `quiz_questions`, and `quiz_results`.

### Run the App

1. Open [AlgoFlash.xcodeproj](AlgoFlash.xcodeproj/) in Xcode.
2. Let Xcode resolve Swift Package dependencies.
3. Select an iOS simulator or device.
4. Build and run the `AlgoFlash` scheme.
5. Sign up as a learner or admin to open the matching workspace.

## Screenshots

| Authentication | Admin Management | Learner Flashcards |
| --- | --- | --- |
| ![Sign up](SS/1.%20sign_up.png) | ![Manage flashcards](SS/3.%20admin_manage_flashcard.png) | ![User flashcards](SS/10.%20user_flashcard.png) |

| Quiz | News | Profile |
| --- | --- | --- |
| ![Quiz](SS/13.%20user_participating_quiz.png) | ![News details](SS/17.%20user_news_details_view.png) | ![User profile](SS/19.%20user_profile.png) |

Additional diagrams and screenshots are available in [report/SS/](report/SS/).

## Team Contributions

- **MD Ahsanul Islam:** Firebase Auth integration, role-based routing, admin tab navigation, flashcard/quiz management screens, login and sign-up layout.
- **Md. Sabith:** UI enhancement, flashcard flip interaction, category filters, difficulty badges, favourites syncing, interface color combinations.
- **MD. Abu Hasanat Soykot:** Timed quiz flow, profile editing, NewsAPI feed, score saving, admin result analytics, email/name update flows.

## Known Risks and Future Work

- Restrict admin account creation so normal users cannot self-register as admins.
- Move the NewsAPI key out of source code before any public release.
- Add automated tests for authentication, Firestore mapping, quiz scoring, and role routing.
- Consider reorganizing Swift files into physical `Models`, `Views`, `ViewModels`, and `Services` folders to match the report architecture.
- Add Firestore security rules that enforce learner/admin permissions server-side.

## References

- [SwiftUI documentation](https://developer.apple.com/documentation/swiftui)
- [Firebase iOS setup](https://firebase.google.com/docs/ios/setup)
- [Cloud Firestore documentation](https://firebase.google.com/docs/firestore)
- [NewsAPI documentation](https://newsapi.org/docs)
