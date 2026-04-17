Here’s your content cleaned up into **well-structured Markdown** (ready for GitHub / submission / docs):

---

# 📱 AlgoFlash – Algorithm Flashcard Trainer (Detailed Design)

## 🔷 1. Core Idea

AlgoFlash is a **learning + practice app** where users:

- Study algorithms using **flashcards**
- Test themselves via **quiz mode**
- Track progress using **Firebase**

It combines:

- 📚 Learning (Flashcards)
- 🧠 Practice (Quiz)
- 📊 Progress Tracking (Cloud)

---

## 🧩 2. System Overview (Architecture)

We follow **MVVM (Model–View–ViewModel):**

```
View (SwiftUI)
   ↓
ViewModel (Logic + Wrapper Functions)
   ↓
Model (Data Structures)
   ↓
Data Source
   ├── JSON (Remote Data)
   └── Firebase Firestore (User Progress)
```

---

## 📦 3. Data Design (JSON + Firestore)

### 🔹 3.1 JSON (via API)

We store algorithm data locally using JSON:

```json
[
  {
    "id": 1,
    "title": "Binary Search",
    "category": "Searching",
    "definition": "Searches sorted array by dividing interval in half.",
    "timeComplexity": "O(log n)",
    "pseudocode": "while(low <= high)...",
    "difficulty": "Easy"
  }
]
```

---

### 🔹 3.2 Firebase Firestore (Dynamic Data)

We store user-specific data:

```
Collection: users
userId
 ├── email
 ├── progress
 ├── score

Collection: quiz_results
resultId
 ├── userId
 ├── score
 ├── date
```

---

## 🔐 4. Firebase Authentication

Use **Email/Password login**

**Features:**

- Sign Up
- Login
- Logout
- Session persistence

---

## 🧠 5. Main Features (Moderate Complexity)

### 🔹 5.1 Flashcard Mode

- Swipe left/right
- Flip card animation

**Shows:**

- Definition
- Time Complexity
- Pseudocode

👉 Concepts used:

- SwiftUI gestures
- Animation

---

### 🔹 5.2 Quiz Mode

- MCQ-based questions from JSON
- Timer (optional)
- Score calculation

**Example:**

```
Q: Time complexity of Binary Search?
A. O(n)
B. O(log n) ✅
```

---

### 📊 5.3 Progress Tracking (Firebase)

- Store user score
- Track completed topics

**Stats shown:**

- Total quizzes taken
- Best score

---

### 🔎 5.4 Category Filtering

- Searching
- Sorting
- Graph
- Dynamic Programming

---

### ❤️ 5.5 Favorite Algorithms

- Mark important topics
- Stored in Firestore

---

## 🧱 6. Wrapper Functions (VERY IMPORTANT FOR LAB)

Instead of direct Firebase calls, we use wrapper classes.

---

### 🔹 6.1 Auth Wrapper

```swift
class AuthService {

    static let shared = AuthService()

    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            completion(error == nil)
        }
    }
}
```

---

### 🔹 6.2 Firestore Wrapper

```swift
class FirestoreService {

    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    func saveScore(userId: String, score: Int) {
        db.collection("quiz_results").addDocument(data: [
            "userId": userId,
            "score": score,
            "date": Date()
        ])
    }
}
```

---

### 🔹 6.3 JSON Loader Wrapper

```swift
class JSONLoader {

    static func loadAlgorithms() -> [Algorithm] {
        let url = Bundle.main.url(forResource: "algorithms", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        return try! JSONDecoder().decode([Algorithm].self, from: data)
    }
}
```

---

## 🎨 7. UI Screens (SwiftUI)

### 🔹 1. Authentication Screen

- Email + Password
- Login / Signup

### 🔹 2. Home Screen

- Categories
- Start Flashcards
- Start Quiz

### 🔹 3. Flashcard Screen

- Swipe cards
- Flip animation

### 🔹 4. Quiz Screen

- Questions + options
- Score at end

### 🔹 5. Progress Screen

- Chart / stats
- Firebase data

---

## ⚙️ 8. Technologies Used

- SwiftUI (UI)
- JSON (Local Data)
- Firebase Auth (Login)
- Firestore DB (Cloud Data)
- MVVM Architecture
- AsyncImage / Animations

---

## 🎯 9. Why This is PERFECT for Your Lab

| Requirement         | Covered |
| ------------------- | ------- |
| SwiftUI             | ✅      |
| JSON                | ✅      |
| Firebase Auth       | ✅      |
| Firestore           | ✅      |
| Wrapper Functions   | ✅      |
| Moderate Complexity | ✅      |

---

## 🚀 10. Possible Extensions (Optional)

If teacher asks “future work”:

- AI recommendation system
- Leaderboard
- Dark mode
- Offline quiz caching

---

## 💡 Viva Explanation (Short)

> “AlgoFlash is a SwiftUI-based learning app where algorithm data is loaded from JSON, user authentication is handled using FirebaseAuth, and progress is stored in Firestore. We used wrapper classes to abstract Firebase operations and followed MVVM architecture for clean design.”

---

## 🔐 11. ROLE-BASED AUTHENTICATION PLAN

================================================================================
ALGOFLASH - ROLE BASED AUTHENTICATION PLAN
================================================================================

ROLES
- admin : manages content (flashcards, quiz questions)
- user  : studies content (flashcards, quizzes)

--------------------------------------------------------------------------------
HOW ROLES WORK
--------------------------------------------------------------------------------

- Role is stored in Firestore under users/{uid}/role
- Role is set to "user" by default on signup
- Admin role is set manually in Firestore by the developer
- App reads role on login and stores it in AuthViewModel
- Every protected screen checks the role before showing content

--------------------------------------------------------------------------------
FIRESTORE SCHEMA
--------------------------------------------------------------------------------

Collection: users
  Document ID = Firebase UID
  Fields:
    id: String
    email: String
    fullName: String
    role: String          ("admin" or "user")
    score: Int
    quizzesTaken: Int
    favourites: [Int]

Collection: algorithms
  Document ID = auto or custom slug
  Fields:
    id: Int
    title: String
    category: String
    definition: String
    timeComplexity: String
    pseudocode: String
    difficulty: String

Collection: quiz_questions
  Document ID = auto
  Fields:
    id: Int
    algorithmId: Int
    question: String
    options: [String]
    correctIndex: Int
    explanation: String

Collection: quiz_results
  Document ID = auto
  Fields:
    userId: String
    score: Int
    total: Int
    date: Timestamp

--------------------------------------------------------------------------------
FIRESTORE SECURITY RULES
--------------------------------------------------------------------------------

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can read/write their own document
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }

    // Algorithms: anyone logged in can read, only admin can write
    match /algorithms/{docId} {
      allow read: if request.auth != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin";
    }

    // Quiz questions: anyone logged in can read, only admin can write
    match /quiz_questions/{docId} {
      allow read: if request.auth != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin";
    }

    // Quiz results: user can write their own, admin can read all
    match /quiz_results/{docId} {
      allow create: if request.auth != null;
      allow read: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin";
    }
  }
}

--------------------------------------------------------------------------------
AUTH FLOW
--------------------------------------------------------------------------------

SIGNUP
1. User fills name, email, password
2. Firebase creates auth account
3. Firestore document created with role = "user"
4. App reads role and routes to UserTabView

LOGIN
1. User enters email, password
2. Firebase signs in
3. App fetches user document from Firestore
4. App reads role field
5. If role == "admin"  -> show AdminTabView
6. If role == "user"   -> show UserTabView

LOGOUT
1. Firebase signs out
2. userSession set to nil
3. App shows LoginView

--------------------------------------------------------------------------------
NAVIGATION ROUTING
--------------------------------------------------------------------------------

ContentView
  if not logged in        -> LoginView
  if logged in + user     -> UserTabView
  if logged in + admin    -> AdminTabView

UserTabView (4 tabs)
  Flashcards   (read only)
  Favourites   (read only)
  Quiz         (take quiz, see score)
  Profile      (own stats)

AdminTabView (4 tabs)
  Manage Cards  (add, edit, delete flashcards)
  Manage Quiz   (add, edit, delete quiz questions)
  Results       (view all quiz results)
  Profile       (admin profile)

--------------------------------------------------------------------------------
VIEWMODELS
--------------------------------------------------------------------------------

AuthViewModel
  Published: userSession, currentRole, appUser, errorMessage, isLoading
  Methods:
    login(email, password)       -> fetches user doc, sets role
    register(email, password, fullName) -> creates user with role = "user"
    logOut()
    fetchCurrentUser()           -> loads AppUser from Firestore

FlashcardViewModel (user only)
  Published: algorithms, favouriteIDs, selectedCategory
  Methods:
    loadAlgorithms()             -> reads from Firestore algorithms collection
    toggleFavourite(algorithm)
    isFavourite(algorithm)

QuizViewModel (user only)
  Published: questions, currentIndex, selectedOption, isAnswered, score, isFinished, timeRemaining
  Methods:
    setup(questions, count)
    selectOption(index)
    nextQuestion()
    saveScore()                  -> writes to quiz_results

AdminFlashcardViewModel (admin only)
  Published: algorithms, isLoading, errorMessage
  Methods:
    fetchAll()                   -> reads all from Firestore
    add(algorithm)               -> writes to Firestore
    update(algorithm)            -> updates document in Firestore
    delete(algorithmId)          -> deletes document from Firestore

AdminQuizViewModel (admin only)
  Published: questions, isLoading, errorMessage
  Methods:
    fetchAll()
    add(question)
    update(question)
    delete(questionId)

AdminResultsViewModel (admin only)
  Published: results, isLoading
  Methods:
    fetchAll()                   -> reads all quiz_results from Firestore

--------------------------------------------------------------------------------
SCREENS - USER SIDE
--------------------------------------------------------------------------------

LoginView
  - Email, password, login button
  - Link to SignupView

SignupView
  - Name, email, password, signup button
  - Role is auto-set to "user"

UserTabView
  - 4 tabs: Flashcards, Favourites, Quiz, Profile

FlashcardsView
  - Read-only swipeable flashcards
  - Data loaded from Firestore

FavouritesView
  - Cards the user has hearted

QuizView
  - Landing, question, result screens
  - Timer, MCQ options, score save

ProfileView
  - Shows user stats from Firestore

--------------------------------------------------------------------------------
SCREENS - ADMIN SIDE
--------------------------------------------------------------------------------

AdminTabView
  - 4 tabs: Manage Cards, Manage Quiz, Results, Profile

ManageFlashcardsView
  - List of all algorithm cards
  - Add button opens AddAlgorithmSheet
  - Tap card opens EditAlgorithmSheet
  - Swipe to delete with confirmation

AddAlgorithmSheet
  - Form: title, category, definition, timeComplexity, pseudocode, difficulty
  - Save button calls AdminFlashcardViewModel.add()

EditAlgorithmSheet
  - Same form pre-filled with existing data
  - Save button calls AdminFlashcardViewModel.update()

ManageQuizView
  - List of all quiz questions
  - Add button opens AddQuestionSheet
  - Tap question opens EditQuestionSheet
  - Swipe to delete with confirmation

AddQuestionSheet
  - Form: question text, 4 options, correct option picker, explanation, linked algorithm
  - Save button calls AdminQuizViewModel.add()

EditQuestionSheet
  - Same form pre-filled
  - Save button calls AdminQuizViewModel.update()

AdminResultsView
  - List of all quiz results
  - Shows: user email, score, total, date
  - Sorted by date descending

AdminProfileView
  - Shows admin name and email
  - Log out button

--------------------------------------------------------------------------------
SERVICES
--------------------------------------------------------------------------------

AuthService
  - signIn(email, password, completion)
  - signUp(email, password, completion)
  - signOut()
  - getCurrentUser()

FirestoreService
  User methods:
    saveUser(id, email, fullName, role, completion)
    fetchUser(userId, completion)
    updateFavourites(userId, ids, completion)

  Algorithm methods:
    fetchAlgorithms(completion)
    addAlgorithm(data, completion)
    updateAlgorithm(id, data, completion)
    deleteAlgorithm(id, completion)

  Quiz question methods:
    fetchQuizQuestions(completion)
    addQuizQuestion(data, completion)
    updateQuizQuestion(id, data, completion)
    deleteQuizQuestion(id, completion)

  Quiz result methods:
    saveResult(userId, score, total, completion)
    fetchAllResults(completion)         -> admin only

--------------------------------------------------------------------------------
APP USER MODEL
--------------------------------------------------------------------------------

struct AppUser: Codable {
  id: String
  email: String
  fullName: String
  role: String
  score: Int
  quizzesTaken: Int
  favourites: [Int]
}

enum UserRole: String {
  case admin = "admin"
  case user  = "user"
}

--------------------------------------------------------------------------------
HOW TO SET ADMIN
--------------------------------------------------------------------------------

1. User signs up normally (gets role = "user")
2. Developer opens Firebase console
3. Goes to Firestore -> users -> find the user document
4. Changes role field from "user" to "admin"
5. User logs out and logs back in
6. App now shows AdminTabView

Note: No admin signup screen in the app on purpose.
Admin accounts are only assigned by the developer.

--------------------------------------------------------------------------------
CONTENT VIEW ROUTING LOGIC
--------------------------------------------------------------------------------

ContentView watches authViewModel.userSession and authViewModel.currentRole

if userSession == nil
  show LoginView

if userSession != nil and currentRole == "user"
  show UserTabView

if userSession != nil and currentRole == "admin"
  show AdminTabView

if userSession != nil and currentRole == nil (still loading)
  show ProgressView (loading spinner)

--------------------------------------------------------------------------------
BUILD ORDER FOR AI AGENTS
--------------------------------------------------------------------------------

1.  Update AppUser model — add role field
2.  Add UserRole enum
3.  Update FirestoreService — add role to saveUser, add all CRUD methods
4.  Update AuthViewModel — add currentRole, appUser, fetchCurrentUser
5.  Update ContentView — add role-based routing
6.  Build UserTabView with existing user screens
7.  Build AdminTabView skeleton
8.  Build AdminFlashcardViewModel
9.  Build ManageFlashcardsView + AddAlgorithmSheet + EditAlgorithmSheet
10. Build AdminQuizViewModel
11. Build ManageQuizView + AddQuestionSheet + EditQuestionSheet
12. Build AdminResultsViewModel
13. Build AdminResultsView
14. Build AdminProfileView
15. Update FlashcardViewModel to load from Firestore instead of local JSON
16. Add Firestore security rules
17. Test as user: login, flashcards, quiz, favourites, logout
18. Test as admin: login, add card, edit card, delete card, add question, view results, logout

================================================================================
END OF ROLE BASED AUTHENTICATION PLAN
================================================================================

---

If you want next, I can:

- Turn this into a **PDF report**
- Add **diagrams (architecture + database ERD)**
- Generate a **full SwiftUI starter project**
- Or make a **presentation (PPT slides)**
