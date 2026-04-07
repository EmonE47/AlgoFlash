//
//  AuthFlowView.swift
//  AlgoFlash
//
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

private enum AuthScreen {
    case entry
    case login
    case register
}

struct AuthFlowView: View {
    @State private var screen: AuthScreen = .entry
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var keepMeSignedIn = true
    @State private var statusMessage = "Firebase-ready forms. Connect actions when the SDK is added on macOS."

    var body: some View {
        ZStack {
            AuthBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    activePanel
                    footerNote
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 28)
            }
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: screen)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                Text("ALGO")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(AuthPalette.ink)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AuthPalette.highlight)
                    )

                Text("FLASH")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AuthPalette.ink)
                    )
            }

            Text("A calmer way to enter the market.")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundStyle(AuthPalette.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text("Create a smooth first step for your users with bold, boxy panels and clear actions for sign in or sign up.")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(AuthPalette.mutedInk)
                .fixedSize(horizontal: false, vertical: true)

            ViewThatFits {
                HStack(spacing: 14) {
                    heroChip(icon: "rectangle.stack.fill.badge.person.crop", text: "Boxy UI")
                    heroChip(icon: "sparkles.rectangle.stack", text: "Humanized")
                    heroChip(icon: "lock.shield.fill", text: "Firebase ready")
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 14) {
                        heroChip(icon: "rectangle.stack.fill.badge.person.crop", text: "Boxy UI")
                        heroChip(icon: "sparkles.rectangle.stack", text: "Humanized")
                    }

                    heroChip(icon: "lock.shield.fill", text: "Firebase ready")
                }
            }
        }
    }

    @ViewBuilder
    private var activePanel: some View {
        switch screen {
        case .entry:
            EntryPanel(
                onLoginTap: {
                    statusMessage = "Welcome back flow opened."
                    screen = .login
                },
                onRegisterTap: {
                    statusMessage = "Create account flow opened."
                    screen = .register
                }
            )
            .transition(panelTransition)

        case .login:
            AuthCard(
                title: "Welcome back",
                subtitle: "Use email sign in or hand off to Google when you wire the Firebase package on the Mac.",
                accent: AuthPalette.coral
            ) {
                VStack(spacing: 16) {
                    BoxyTextField(
                        label: "Email",
                        placeholder: "you@example.com",
                        icon: "at",
                        keyboardType: .emailAddress,
                        autocapitalization: .never,
                        text: $email
                    )

                    BoxySecureField(
                        label: "Password",
                        placeholder: "Enter your password",
                        icon: "lock",
                        text: $password
                    )

                    Toggle(isOn: $keepMeSignedIn) {
                        Text("Keep me signed in")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(AuthPalette.ink)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: AuthPalette.ink))
                    .padding(.top, 4)

                    PrimaryAuthButton(title: "Log In", fill: AuthPalette.ink, action: login)
                    GoogleAuthButton(action: googleLogin)
                    InlineSwapPrompt(
                        prompt: "New here?",
                        actionTitle: "Create account",
                        action: {
                            statusMessage = "Switching to registration."
                            screen = .register
                        }
                    )
                    BackToEntryButton {
                        statusMessage = "Back on the entry page."
                        screen = .entry
                    }
                }
            }
            .transition(panelTransition)

        case .register:
            AuthCard(
                title: "Create your space",
                subtitle: "Start with a warm onboarding moment, then connect email/password and Google Auth to FirebaseAuth.",
                accent: AuthPalette.highlight
            ) {
                VStack(spacing: 16) {
                    BoxyTextField(
                        label: "Full name",
                        placeholder: "Your name",
                        icon: "person",
                        text: $fullName
                    )

                    BoxyTextField(
                        label: "Email",
                        placeholder: "name@example.com",
                        icon: "envelope",
                        keyboardType: .emailAddress,
                        autocapitalization: .never,
                        text: $email
                    )

                    BoxySecureField(
                        label: "Password",
                        placeholder: "Create a password",
                        icon: "key",
                        text: $password
                    )

                    BoxySecureField(
                        label: "Confirm password",
                        placeholder: "Repeat the password",
                        icon: "checkmark.shield",
                        text: $confirmPassword
                    )

                    PrimaryAuthButton(title: "Create Account", fill: AuthPalette.coral, action: register)
                    GoogleAuthButton(action: googleRegister)
                    InlineSwapPrompt(
                        prompt: "Already have an account?",
                        actionTitle: "Log in",
                        action: {
                            statusMessage = "Switching to login."
                            screen = .login
                        }
                    )
                    BackToEntryButton {
                        statusMessage = "Back on the entry page."
                        screen = .entry
                    }
                }
            }
            .transition(panelTransition)
        }
    }

    private var footerNote: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Prototype status")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(AuthPalette.ink)
                .textCase(.uppercase)

            Text(statusMessage)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AuthPalette.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.78))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AuthPalette.border, lineWidth: 1.5)
        )
    }

    private var panelTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    private func heroChip(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
            Text(text)
                .font(.system(size: 13, weight: .bold, design: .rounded))
        }
        .foregroundStyle(AuthPalette.ink)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AuthPalette.border, lineWidth: 1.2)
        )
    }

    private func login() {
        if email.isEmpty || password.isEmpty {
            statusMessage = "Enter both email and password before you connect the Firebase login action."
        } else {
            statusMessage = "Login form looks ready. Next step is connecting FirebaseAuth signIn on the Mac."
        }
    }

    private func register() {
        if fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            statusMessage = "Fill in every register field first so the Firebase create-user action has all required values."
        } else if password != confirmPassword {
            statusMessage = "Passwords do not match yet. Make them equal before wiring the register action."
        } else {
            statusMessage = "Registration form is ready for FirebaseAuth account creation."
        }
    }

    private func googleLogin() {
        statusMessage = "Google sign-in button is designed and ready. Wire GoogleSignIn plus FirebaseAuth when you open the project in Xcode."
    }

    private func googleRegister() {
        statusMessage = "Google account creation can use the same Google sign-in flow once the iOS packages are added."
    }
}

private struct EntryPanel: View {
    let onLoginTap: () -> Void
    let onRegisterTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top, spacing: 14) {
                entryStat(value: "3 taps", label: "from entry to account")
                entryStat(value: "Warm", label: "first impression")
            }

            Text("Choose how you want to enter AlgoFlash.")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(AuthPalette.ink)

            Text("The entry page gives users a clean fork: come back fast, or start fresh with a guided account setup.")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(AuthPalette.mutedInk)

            VStack(spacing: 14) {
                PrimaryAuthButton(title: "Go to Login", fill: AuthPalette.ink, action: onLoginTap)
                PrimaryAuthButton(title: "Create New Account", fill: AuthPalette.coral, action: onRegisterTap)
            }

            HStack(spacing: 12) {
                smallFeature(icon: "envelope.badge", text: "Email sign in")
                smallFeature(icon: "g.circle.fill", text: "Google sign in")
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.white.opacity(0.88))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(AuthPalette.border, lineWidth: 1.5)
        )
        .shadow(color: AuthPalette.shadow, radius: 24, x: 0, y: 14)
    }

    private func entryStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(AuthPalette.ink)
            Text(label)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(AuthPalette.mutedInk)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AuthPalette.cardWash)
        )
    }

    private func smallFeature(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
            Text(text)
                .font(.system(size: 13, weight: .bold, design: .rounded))
        }
        .foregroundStyle(AuthPalette.ink)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AuthPalette.cardWash)
        )
    }
}

private struct AuthCard<Content: View>: View {
    let title: String
    let subtitle: String
    let accent: Color
    let content: Content

    init(
        title: String,
        subtitle: String,
        accent: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.accent = accent
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 29, weight: .heavy, design: .rounded))
                        .foregroundStyle(AuthPalette.ink)

                    Text(subtitle)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(AuthPalette.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(accent)
                    .frame(width: 54, height: 54)
                    .overlay(
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 18, weight: .black))
                            .foregroundStyle(AuthPalette.ink)
                    )
            }

            Divider()
                .overlay(AuthPalette.border)

            content
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.white.opacity(0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(AuthPalette.border, lineWidth: 1.5)
        )
        .shadow(color: AuthPalette.shadow, radius: 24, x: 0, y: 14)
    }
}

private struct BoxyTextField: View {
    let label: String
    let placeholder: String
    let icon: String
    let keyboardType: UIKeyboardType
    let autocapitalization: TextInputAutocapitalization
    @Binding var text: String

    init(
        label: String,
        placeholder: String,
        icon: String,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .sentences,
        text: Binding<String>
    ) {
        self.label = label
        self.placeholder = placeholder
        self.icon = icon
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
        self._text = text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(AuthPalette.ink)
                .textCase(.uppercase)

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(AuthPalette.mutedInk)

                TextField(placeholder, text: $text)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(AuthPalette.ink)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(autocapitalization)
                    .keyboardType(keyboardType)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AuthPalette.cardWash)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AuthPalette.border, lineWidth: 1.2)
            )
        }
    }
}

private struct BoxySecureField: View {
    let label: String
    let placeholder: String
    let icon: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(AuthPalette.ink)
                .textCase(.uppercase)

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(AuthPalette.mutedInk)

                SecureField(placeholder, text: $text)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(AuthPalette.ink)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AuthPalette.cardWash)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AuthPalette.border, lineWidth: 1.2)
            )
        }
    }
}

private struct PrimaryAuthButton: View {
    let title: String
    let fill: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .black))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(fill)
            )
            .shadow(color: fill.opacity(0.22), radius: 14, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }
}

private struct GoogleAuthButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AuthPalette.cardWash)
                        .frame(width: 34, height: 34)

                    Text("G")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(AuthPalette.ink)
                }

                Text("Continue with Google")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(AuthPalette.ink)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(AuthPalette.border, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct InlineSwapPrompt: View {
    let prompt: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(prompt)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AuthPalette.mutedInk)

            Button(actionTitle, action: action)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(AuthPalette.ink)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

private struct BackToEntryButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                Text("Back to entry")
            }
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundStyle(AuthPalette.mutedInk)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct AuthBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AuthPalette.paper,
                    AuthPalette.softPeach,
                    AuthPalette.skyTint
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                HStack {
                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                        .fill(AuthPalette.highlight.opacity(0.9))
                        .frame(width: 170, height: 170)
                        .rotationEffect(.degrees(-18))
                        .offset(x: -40, y: -40)

                    Spacer()

                    RoundedRectangle(cornerRadius: 42, style: .continuous)
                        .fill(AuthPalette.coral.opacity(0.72))
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(16))
                        .offset(x: 24, y: -10)
                }

                Spacer()

                HStack {
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(Color.white.opacity(0.45))
                        .frame(width: 110, height: 110)
                        .rotationEffect(.degrees(12))
                        .offset(x: -12, y: 18)

                    Spacer()

                    RoundedRectangle(cornerRadius: 50, style: .continuous)
                        .fill(AuthPalette.ink.opacity(0.14))
                        .frame(width: 190, height: 190)
                        .rotationEffect(.degrees(-10))
                        .offset(x: 36, y: 34)
                }
            }
            .ignoresSafeArea()
        }
    }
}

private enum AuthPalette {
    static let paper = Color(red: 0.97, green: 0.93, blue: 0.89)
    static let softPeach = Color(red: 0.95, green: 0.82, blue: 0.70)
    static let skyTint = Color(red: 0.80, green: 0.88, blue: 0.93)
    static let coral = Color(red: 0.91, green: 0.41, blue: 0.34)
    static let highlight = Color(red: 0.98, green: 0.78, blue: 0.29)
    static let ink = Color(red: 0.11, green: 0.16, blue: 0.24)
    static let mutedInk = Color(red: 0.33, green: 0.38, blue: 0.47)
    static let border = Color(red: 0.22, green: 0.27, blue: 0.33).opacity(0.16)
    static let cardWash = Color.white.opacity(0.72)
    static let shadow = Color.black.opacity(0.12)
}

#Preview {
    AuthFlowView()
}
