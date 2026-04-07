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

If you want next, I can:

- Turn this into a **PDF report**
- Add **diagrams (architecture + database ERD)**
- Generate a **full SwiftUI starter project**
- Or make a **presentation (PPT slides)**
