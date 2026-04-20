# AlgoFlash — UI/UX Enhancement Plan
> Prepared for Codex implementation · iPhone 16 Pro target · iOS 17+ · SwiftUI

---

## 1. Design Philosophy & Direction

AlgoFlash is a CS learning app for students and developers. The redesign targets a **"Dark Academia Tech"** aesthetic — premium, focused, and intellectually serious — while staying clean and fast enough to feel native on iOS.

**Core principles:**
- Every screen earns attention with purposeful visual hierarchy
- Brand identity is consistent across every surface
- Motion is meaningful, never decorative noise
- Dark-mode-first with a polished light-mode counterpart
- Typography does the heavy lifting; color is the accent

---

## 2. Design System (Token Layer)

### 2.1 Color Palette

Define these as SwiftUI `Color` extensions in a `DesignTokens.swift` file:

```swift
extension Color {
    // Brand
    static let brand      = Color("BrandIndigo")   // #4F46E5  – deep electric indigo
    static let brandLight = Color("BrandLight")    // #818CF8  – soft lavender-indigo
    static let brandDark  = Color("BrandDark")     // #3730A3  – darker indigo for depth

    // Surface (semantic)
    static let surface0   = Color("Surface0")      // systemBackground
    static let surface1   = Color("Surface1")      // secondarySystemBackground
    static let surface2   = Color("Surface2")      // tertiarySystemBackground

    // Accent semantic
    static let success    = Color("Success")       // #10B981  – emerald
    static let warning    = Color("Warning")       // #F59E0B  – amber
    static let danger     = Color("Danger")        // #EF4444  – red
    static let info       = Color("Info")          // #3B82F6  – blue

    // Difficulty badge colours
    static let diffEasy   = Color("DiffEasy")      // #10B981 emerald
    static let diffMedium = Color("DiffMedium")    // #F59E0B amber
    static let diffHard   = Color("DiffHard")      // #EF4444 red

    // Category gradient stops (one pair per category)
    static let catSearching = (Color(#colorLiteral(red:0.31,green:0.28,blue:0.90,alpha:1)),
                               Color(#colorLiteral(red:0.51,green:0.48,blue:1.00,alpha:1)))
    static let catSorting   = (Color(#colorLiteral(red:0.06,green:0.73,blue:0.51,alpha:1)),
                               Color(#colorLiteral(red:0.20,green:0.88,blue:0.67,alpha:1)))
    static let catGraph     = (Color(#colorLiteral(red:0.96,green:0.62,blue:0.07,alpha:1)),
                               Color(#colorLiteral(red:1.00,green:0.78,blue:0.20,alpha:1)))
    static let catDP        = (Color(#colorLiteral(red:0.94,green:0.27,blue:0.27,alpha:1)),
                               Color(#colorLiteral(red:1.00,green:0.50,blue:0.50,alpha:1)))
    static let catAll       = (Color.brand, Color.brandLight)
}
```

Add these named colors to `Assets.xcassets` with both light and dark appearances.

### 2.2 Typography Scale

All fonts are **SF Pro** (native iOS) — no third-party fonts needed. Define as ViewModifier:

```swift
// Usage: Text("Hello").textStyle(.displayTitle)

enum TextStyle {
    case displayTitle   // .largeTitle  bold  34pt
    case screenTitle    // .title       bold  28pt
    case sectionTitle   // .title2      bold  22pt
    case cardTitle      // .title3      semibold 20pt
    case bodyPrimary    // .body        regular 17pt
    case bodySecondary  // .callout     regular 16pt
    case caption        // .footnote    regular 13pt
    case badge          // .caption2    semibold 11pt
    case mono           // .system 13   monospaced
}
```

### 2.3 Spacing & Radius Scale

```
XS   = 4
S    = 8
M    = 12
L    = 16
XL   = 20
2XL  = 24
3XL  = 32
4XL  = 48

cornerRadius.card     = 24 (continuous style)
cornerRadius.pill     = 100 (capsule)
cornerRadius.button   = 14
cornerRadius.field    = 12
cornerRadius.badge    = 8
```

### 2.4 Shadow System

```swift
// Card shadow — default
.shadow(color: .black.opacity(0.10), radius: 16, x: 0, y: 8)

// Elevated card (hover / drag)
.shadow(color: .brand.opacity(0.18), radius: 28, x: 0, y: 14)

// Subtle — stat cards
.shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
```

### 2.5 Motion Constants

```swift
enum Motion {
    static let spring     = Animation.spring(response: 0.38, dampingFraction: 0.72)
    static let springFast = Animation.spring(response: 0.25, dampingFraction: 0.80)
    static let easeOut    = Animation.easeOut(duration: 0.22)
    static let flip       = Animation.spring(response: 0.48, dampingFraction: 0.70)
}
```

---

## 3. Global Components

### 3.1 `AlgoButton` — Primary CTA

Replace every plain `Button { … } label: { Text(…) .frame(maxWidth: .infinity) .padding() .background(Color.blue) … }` with:

```swift
struct AlgoButton: View {
    enum Style { case primary, secondary, ghost, danger }
    let title: String
    var icon: String? = nil
    var style: Style = .primary
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(style == .primary ? .white : .brand)
                        .scaleEffect(0.85)
                } else {
                    if let icon { Image(systemName: icon).font(.body.weight(.semibold)) }
                    Text(title).font(.body.weight(.semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(backgroundFor(style))
            .foregroundColor(foregroundFor(style))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(overlayFor(style))
        }
        .buttonStyle(ScaleButtonStyle())   // see below
        .disabled(isLoading)
    }

    // fill helpers omitted for brevity — primary = brand gradient,
    // secondary = brand.opacity(0.12) + brand text,
    // ghost = clear + border,
    // danger = danger gradient
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(Motion.springFast, value: configuration.isPressed)
    }
}
```

### 3.2 `AlgoTextField` — Styled Input Field

Replace every raw `TextField` + `.background(Color(.systemGray6))` with:

```swift
struct AlgoTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 10) {
            if let icon {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(width: 20)
            }
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocorrectionDisabled()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(text.isEmpty ? Color.clear : Color.brand.opacity(0.45), lineWidth: 1.5)
        )
        .animation(Motion.easeOut, value: text.isEmpty)
    }
}
```

### 3.3 `CategoryPill` — Filter Chip

The current `Button(cat) { … } .clipShape(Capsule())` is close but needs refinement:

```swift
struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var gradient: (Color, Color)? = nil

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(pillBackground)
                .foregroundColor(isSelected ? .white : .secondary)
                .clipShape(Capsule())
                .shadow(color: isSelected ? (gradient?.0 ?? .brand).opacity(0.30) : .clear,
                        radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(Motion.spring, value: isSelected)
    }

    @ViewBuilder var pillBackground: some View {
        if isSelected, let (c1, c2) = gradient {
            LinearGradient(colors: [c1, c2], startPoint: .leading, endPoint: .trailing)
        } else if isSelected {
            LinearGradient(colors: [.brand, .brandLight], startPoint: .leading, endPoint: .trailing)
        } else {
            Color(.tertiarySystemBackground)
        }
    }
}
```

### 3.4 Loading State — `ShimmerView`

Replace all plain `ProgressView()` screen-level loaders with shimmer skeleton cards:

```swift
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1
    func body(content: Content) -> some View {
        content.overlay(
            LinearGradient(
                stops: [
                    .init(color: .clear, location: phase - 0.3),
                    .init(color: .white.opacity(0.45), location: phase),
                    .init(color: .clear, location: phase + 0.3),
                ],
                startPoint: .leading, endPoint: .trailing
            )
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1.3
                }
            }
        )
        .clipped()
    }
}
extension View {
    func shimmer() -> some View { modifier(ShimmerModifier()) }
}
```

---

## 4. Screen-by-Screen Redesign

---

### 4.1 Login Screen (`LoginView.swift`)

**Current problems:** Plain VStack, `bolt.fill` placeholder icon, no visual identity, no gradient hero.

**Redesign:**

```
┌──────────────────────────────┐
│  [full-bleed gradient hero]  │
│                              │
│   ⚡ AlgoFlash               │  ← logo mark (indigo capsule + lightning)
│   "Learn Algorithms Fast"   │  ← tagline, white
│                              │
│  ┌──────────────────────┐   │
│  │ [frosted glass card] │   │  ← .ultraThinMaterial
│  │  Email field         │   │
│  │  Password field      │   │
│  │  [Sign In button]    │   │
│  │  ─────── or ───────  │   │
│  │  [Continue w/ Google]│   │
│  │  Don't have account? │   │
│  └──────────────────────┘   │
└──────────────────────────────┘
```

**Implementation notes:**
- Hero background: `MeshGradient` (iOS 18) or `LinearGradient` animating between `[.brand, .brandDark, Color(#colorLiteral(r:0.06,g:0.07,b:0.20,a:1))]`  
- Place a `ZStack` with the gradient full-bleed behind a `VStack` that has the logo at top and the frosted card toward the bottom
- Logo: `HStack { Image(systemName:"bolt.fill").foregroundStyle(.white) Text("AlgoFlash").font(.largeTitle.bold()).foregroundStyle(.white) }` inside a `Capsule().fill(.white.opacity(0.18))` 
- Tagline: `.font(.headline)`, `.foregroundStyle(.white.opacity(0.80))`
- Form card: `.background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius:28,style:.continuous))`
- Use `AlgoTextField` for all fields with icons: `"envelope"` for email, `"lock"` for password
- Primary button: `AlgoButton(title:"Sign In", style:.primary)` — white text on brand gradient
- Google button: HStack with `Image("google_logo")` + Text, `.background(.white).foregroundColor(.black)` outlined secondary style
- Sign Up link at very bottom with animated underline on tap

---

### 4.2 Sign Up Screen (`SignupView.swift`)

**Redesign:** Match the login hero style. Replace the plain VStack with the same frosted card pattern.

**Additional changes:**
- The role picker (`Picker(.segmented)`) → custom toggle: two tappable cards side-by-side
  - User card: person.fill icon + "Learner" label
  - Admin card: star.fill icon + "Admin" label  
  - Selected state: brand gradient background, elevated shadow
- All fields get `AlgoTextField` with matching icons
- Button label adapts to role via `.animation` not a static string swap

---

### 4.3 Main Tab Bar (`MainTabView.swift`)

**Current problems:** Default iOS blue tint, no personality.

**Redesign:**
```swift
TabView { … }
    .tint(.brand)
    // On iOS 16+ apply custom tab bar appearance:
    .onAppear {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        // Subtle top separator line
        appearance.shadowColor = UIColor.separator
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
```

Tab icons with SF Symbols that feel more intentional:
- Flashcards → `"square.stack.3d.up.fill"`
- Favourites → `"heart.fill"`
- Quiz → `"brain.head.profile"` (iOS 16+) or `"checkmark.seal.fill"`
- News → `"newspaper.fill"`
- Profile → `"person.crop.circle.fill"`

---

### 4.4 Flashcards Screen (`FlashcardsView.swift`)

**Current problems:** White card with shadow is fine but generic; navigation arrows are bare; background is plain white; no sense of depth or immersion.

**Redesign layout:**

```
NavigationStack {
    ZStack {
        ── animated background: subtle radial gradient that shifts slowly ──

        VStack(spacing: 0) {
            ── category picker (CategoryPill, each with its gradient pair) ──

            ── progress indicator: custom "X of N" with dots or lozenge ──

            Spacer()

            ── card stack (current + ghost behind) ──

            ── hint text ──

            Spacer()

            ── bottom: swipe arrows with haptic on tap ──
        }
    }
    .navigationTitle("Flashcards")
    .navigationBarTitleDisplayMode(.large)
}
```

**FlashCard front face redesign:**
- Replace white background with a **category-tinted gradient** background:
  ```swift
  RoundedRectangle(cornerRadius: 24, style: .continuous)
      .fill(LinearGradient(colors: [categoryColor.opacity(0.92), categoryColorDark],
                           startPoint: .topLeading, endPoint: .bottomTrailing))
  ```
- Algorithm title: `.font(.title.bold()).foregroundColor(.white)`
- Category chip: `.background(.white.opacity(0.20)).foregroundColor(.white)`
- Difficulty badge: white text on semi-transparent pill, colored glow
- Bottom: "Tap to flip" caption in `.white.opacity(0.65)`
- Favourite heart: white, overlaid top-right

**FlashCard back face redesign:**
- Background: `.ultraThinMaterial` over the same gradient (creates a glass effect)
- Section labels (`Time Complexity`, `Definition`, `Pseudocode`) styled as all-caps tracking `.caption.weight(.semibold).tracking(0.8).foregroundColor(.white.opacity(0.65))`
- Pseudocode block: dark monospace area — `Color.black.opacity(0.35)` background + `.white` text
- Time complexity: bold white text with `clock` icon in `brandLight`

**Navigation arrows:**
- Replace `arrow.left.circle.fill` with a custom `HStack` of pill-shaped buttons:
  ```swift
  // Back button
  Label("Prev", systemImage: "chevron.left")
      .labelStyle(.iconOnly)
      .padding(16)
      .background(.ultraThinMaterial)
      .clipShape(Circle())
  ```
- Add `UIImpactFeedbackGenerator(style: .light).impactOccurred()` on each tap

**Progress indicator:**
Replace `Text("1 / 20")` with a dot lozenge:
```swift
HStack(spacing: 6) {
    ForEach(0..<min(cards.count, 7), id:\.self) { i in
        Capsule()
            .fill(i == currentIndex ? Color.brand : Color.secondary.opacity(0.3))
            .frame(width: i == currentIndex ? 20 : 6, height: 6)
            .animation(Motion.spring, value: currentIndex)
    }
    if cards.count > 7 { Text("…").font(.caption2).foregroundColor(.secondary) }
}
```

---

### 4.5 Favourites Screen (`FavouritesView.swift`)

**Changes:**
- **Empty state:** Make it visually beautiful — large hero illustration using SF Symbol `heart.slash.fill` with a subtle gradient overlay, headline "Nothing Saved Yet", subtext, and a `AlgoButton` linking to Flashcards tab
- **Filled state:** Identical card treatment to FlashcardsView — reuses the same `FlashCard` component (which already matches after the redesign above)
- Add a subtle header showing `"\(cards.count) saved algorithms"` in secondary text

---

### 4.6 Quiz Screen (`QuizView.swift`)

#### Quiz Start Screen

**Current:** Plain icon + text + button.

**Redesign:**
```
ZStack {
    ── brand gradient background ──
    VStack(spacing: 32) {
        Spacer()
        ── large animated brain/quiz icon ──
            Image(systemName: "brain.head.profile")
                .font(.system(size:90))
                .symbolEffect(.pulse, isActive: true)   // iOS 17+
                .foregroundStyle(.white)
        ── title + description ──
        ── three stat pills in HStack ──
            "10 Questions" | "30s / Q" | "Scored"
        Spacer()
        ── AlgoButton "Start Quiz" ──
    }
}
```
The stats pills: white `.ultraThinMaterial` capsules with SF Symbol icon + text.

#### Question Screen

**Redesign:**
- **Header area:** question number as a tinted capsule + timer as circular ring:
  ```swift
  // Timer ring — replace plain Text("30s")
  ZStack {
      Circle().stroke(Color.white.opacity(0.2), lineWidth: 4)
      Circle()
          .trim(from: 0, to: CGFloat(timeRemaining)/CGFloat(totalTime))
          .stroke(timeRemaining < 10 ? Color.danger : Color.success,
                  style: StrokeStyle(lineWidth: 4, lineCap: .round))
          .rotationEffect(.degrees(-90))
          .animation(Motion.easeOut, value: timeRemaining)
      Text("\(timeRemaining)")
          .font(.caption.weight(.bold))
          .foregroundColor(.white)
  }
  .frame(width: 44, height: 44)
  ```
- **Progress bar:** Taller (6pt height), rounded, brand gradient fill
- **Question card:** White card with `RoundedRectangle(cornerRadius:20)`, question text `.font(.title3.weight(.semibold))`, padding 24

- **Option buttons:** Redesign from plain gray to premium interactive:
  ```swift
  // Default state
  HStack {
      Text(optionLetter).frame(width:32,height:32)
          .background(Color.brand.opacity(0.12))
          .clipShape(Circle())
          .font(.headline.weight(.bold)).foregroundColor(.brand)
      Text(text).font(.body)
      Spacer()
  }
  .padding(16)
  .background(Color(.secondarySystemBackground))
  .clipShape(RoundedRectangle(cornerRadius:14, style:.continuous))
  .overlay(
      RoundedRectangle(cornerRadius:14, style:.continuous)
          .stroke(Color.brand.opacity(0.0), lineWidth:2)
  )
  
  // Selected state: brand border + brand.opacity(0.08) fill
  // Correct state: success border + success.opacity(0.08) fill + checkmark
  // Wrong state: danger border + danger.opacity(0.08) fill + xmark
  // All transitions: .animation(Motion.springFast, value: isAnswered)
  ```

- **Explanation card (post-answer):**
  - Correct: emerald left-border accent bar (`Rectangle().fill(.success).frame(width:4)`)
  - Wrong: red left-border accent bar
  - Explanation text in `.body` with `.foregroundColor(.primary)`

#### Quiz Result Screen

**Current:** Very plain icon + score + retry button.

**Redesign:**
```
VStack(spacing: 0) {
    ── gradient hero panel (top ~45% of screen) ──
        ZStack {
            brand gradient bg
            VStack {
                Large circular score ring (animated on appear)
                "8 / 10"  .font(.system(size:52, weight:.bold))
                "80%"  brand-tinted
                performance label: "Excellent!" / "Good!" / "Keep Practicing"
            }
        }
    
    ── white/surface card panel (bottom ~55%) ──
        VStack(spacing: 20) {
            HStack of 3 stat cells:
                "Correct" | "Wrong" | "Time"
            
            ── performance bar: correct % filled with brand gradient ──
            
            AlgoButton("Retake Quiz")
            AlgoButton("Back to Home", style: .ghost)
        }
        .padding(24)
}
```

**Animated ring:**
```swift
Circle()
    .trim(from: 0, to: animatedProgress)
    .stroke(
        AngularGradient(colors:[.brand, .brandLight, .brand], center:.center),
        style: StrokeStyle(lineWidth:14, lineCap:.round)
    )
    .rotationEffect(.degrees(-90))
    .onAppear {
        withAnimation(.easeOut(duration:1.1).delay(0.3)) {
            animatedProgress = Double(score)/Double(total)
        }
    }
```

---

### 4.7 News Screen (`NewsView.swift`)

**Current:** Already the best-looking screen. Mostly refinements needed.

**Changes:**
- Navigation title: large display "Tech News" with a secondary subtitle "Powered by NewsAPI" in `.caption.foregroundColor(.secondary)` below
- NewsCard: increase corner radius to `26`, add `categoryTag` based on source name
- Add a horizontal "pinned featured" card at the top (first article, full-width, taller image `240pt`) before the regular list
- Regular cards below: thumbnail image on the LEFT (60×60 pt), title + source + date on the right — compact list style for faster scanning
- Detail view: parallax header image using `GeometryReader` offset trick

---

### 4.8 Profile Screen (`ProfileView.swift`)

**Current:** Avatar with gradient initials is nice; stat cards are bland; manage account looks like a raw settings form.

**Redesign layout:**

```
ScrollView {
    ── hero header ──
        ZStack(alignment: .bottom) {
            brand gradient (height ~200pt, extended under nav bar with .ignoresSafeArea)
            VStack {
                avatar circle (larger: 96pt, white ring border 3pt)
                name (.title2.bold, .white)
                email (.subheadline, .white.opacity(0.75))
                "Student" badge pill
            }
            .padding(.bottom, 24)
        }

    ── stats row ──  (scrolled just below hero)
        HStack(spacing: 12) {
            StatCard(…)   ← elevated white cards with colored top accent bar
        }
        .padding(.horizontal, 20)
        .offset(y: -28)   // overlaps hero for visual connection

    ── account section ──
        Section header "Account Settings"
        list-style rows with SF Symbol icon + label + chevron
        "Edit Name" row → inline editing
        "Update Email" row → inline editing
        "Change Password" row → sheet

    ── danger zone ──
        "Sign Out" button with danger style
}
```

**StatCard redesign:**
```swift
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Colored top accent bar
            Rectangle()
                .fill(color)
                .frame(height: 3)
                .clipShape(Capsule())

            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.title.bold())

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 4)
    }
}
```

---

### 4.9 Admin Screens

Admin screens should share the same design system but use an **amber/orange accent** to distinguish the admin context visually (preventing accidental confusion with user mode).

**AdminTabView:** `.tint(.warning)` + adjust icon set as above

**AdminProfileView:**
- Same hero header pattern as user ProfileView
- Admin badge: amber capsule with `star.fill` icon
- Role indicator clearly displayed

**ManageFlashcardsView / ManageQuizView:**
- List rows: use iOS `List` with `listRowBackground(Color(.secondarySystemBackground))` for consistent card look
- Add/Edit sheets: use the same `AlgoTextField` components
- Delete swipe action: `.destructive` tint properly

**AdminResultsView:**
- Show a simple bar chart using SwiftUI `Chart` (Charts framework, iOS 16+)
- Each bar = a user, colored by score percentile

---

## 5. Navigation Bar Styling

Apply consistently across all screens:

```swift
// Large title screens (Flashcards, Quiz, News, Profile)
.navigationBarTitleDisplayMode(.large)

// Modal / drill-down screens
.navigationBarTitleDisplayMode(.inline)

// Custom title color — brand for key screens
// In onAppear:
let nav = UINavigationBarAppearance()
nav.configureWithTransparentBackground()
nav.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.brand)]
UINavigationBar.appearance().standardAppearance = nav
```

---

## 6. Empty States — Consistent Pattern

Every empty state must follow this template:

```swift
struct EmptyStateView: View {
    let icon: String       // SF Symbol name
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.brand.opacity(0.08))
                    .frame(width: 100, height: 100)
                Image(systemName: icon)
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(colors:[.brand,.brandLight],
                                       startPoint:.top, endPoint:.bottom)
                    )
            }
            VStack(spacing: 8) {
                Text(title).font(.title2.bold())
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            if let actionTitle, let action {
                AlgoButton(title: actionTitle, action: action)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
```

Apply to: FavouritesView (empty), QuizView (no questions), FlashcardsView (empty category).

---

## 7. Micro-interactions & Haptics

Add a `HapticManager.swift`:

```swift
enum HapticManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
```

**Where to use:**
| Interaction | Haptic |
|---|---|
| Flashcard swipe (navigate) | `.impact(.light)` |
| Flashcard flip | `.impact(.medium)` |
| Quiz answer selected | `.impact(.light)` |
| Quiz correct answer | `.notification(.success)` |
| Quiz wrong answer | `.notification(.error)` |
| Tab switch | `.selection()` |
| Favourite toggled ON | `.impact(.medium)` |
| Button press (CTA) | `.impact(.light)` |

---

## 8. Accessibility

- All `Image(systemName:)` icons that convey meaning must have `.accessibilityLabel(…)`
- `AlgoButton` automatically sets `accessibilityRole(.button)`
- Color is never the **only** differentiator — difficulty is shown as text + color
- Minimum tap target: 44×44pt enforced via `.frame(minWidth:44, minHeight:44)`
- Dynamic Type: test with XXL text size; avoid fixed `frame(width:)` on text containers

---

## 9. Dark Mode Specifics

All named colors in `Assets.xcassets` need both light and dark appearances:
- `BrandIndigo`: same (#4F46E5) in both — brand stays consistent
- `Surface0` / `Surface1` / `Surface2`: use `systemBackground` / `secondarySystemBackground` / `tertiarySystemBackground` semantic colors (automatic)
- Card backgrounds: `.systemBackground` (white → near-black in dark)
- Gradient cards: the category gradients look excellent in dark mode as-is

Flashcard gradient fronts look especially good in dark mode — no extra work needed.

---

## 10. File Organization Recommendations

Codex should organize the new components as:

```
AlgoFlash/
├── DesignSystem/
│   ├── DesignTokens.swift       ← colors, spacing, radius constants
│   ├── Typography.swift         ← TextStyle enum + ViewModifier
│   ├── AlgoButton.swift
│   ├── AlgoTextField.swift
│   ├── CategoryPill.swift
│   ├── EmptyStateView.swift
│   ├── ShimmerView.swift
│   └── HapticManager.swift
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   └── SignupView.swift
│   ├── Flashcards/
│   │   ├── FlashcardsView.swift
│   │   ├── FlashCard.swift      ← extracted component
│   │   └── FavouritesView.swift
│   ├── Quiz/
│   │   ├── QuizView.swift
│   │   ├── QuizQuestionView.swift
│   │   ├── QuizResultView.swift
│   │   └── OptionButton.swift
│   ├── News/
│   │   ├── NewsView.swift
│   │   ├── NewsCard.swift
│   │   └── NewsDetailView.swift
│   ├── Profile/
│   │   ├── ProfileView.swift
│   │   └── StatCard.swift
│   └── Admin/
│       ├── AdminTabView.swift
│       ├── AdminProfileView.swift
│       ├── ManageFlashcardsView.swift
│       ├── ManageQuizView.swift
│       └── AdminResultsView.swift
└── …
```

---

## 11. Implementation Priority for Codex

Implement in this order (highest impact first):

1. **`DesignTokens.swift`** — colors, spacing, corner radius constants
2. **`AlgoButton.swift`** + **`AlgoTextField.swift`** — replace all buttons/fields everywhere
3. **`LoginView.swift`** + **`SignupView.swift`** — first impression, most critical
4. **`FlashCard.swift`** — gradient front face, glass back face
5. **`FlashcardsView.swift`** — background, pill indicator, navigation arrows
6. **`QuizView.swift`** — start screen hero, option buttons, timer ring, result screen
7. **`ProfileView.swift`** — hero header, StatCard redesign
8. **`EmptyStateView.swift`** — consistent across app
9. **`HapticManager.swift`** — wire up all interactions
10. **`AdminProfileView.swift`** + admin screens — amber accent, consistent components

---

*End of AlgoFlash UI/UX Enhancement Plan*
