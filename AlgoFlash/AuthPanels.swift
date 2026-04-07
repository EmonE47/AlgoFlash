//
//  AuthPanels.swift
//  AlgoFlash
//
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct AuthHeaderView: View {
    let isSignedIn: Bool

    var body: some View {
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

            Text(isSignedIn ? "You are inside AlgoFlash." : "A calmer way to enter the market.")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundStyle(AuthPalette.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text(
                isSignedIn
                    ? "Firebase is holding the session for you now. You can keep building from the signed-in state."
                    : "Sign in with email/password or Google, and keep the first-use experience warm, boxy, and easy to trust."
            )
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundStyle(AuthPalette.mutedInk)
            .fixedSize(horizontal: false, vertical: true)

            ViewThatFits {
                HStack(spacing: 14) {
                    heroChip(icon: "rectangle.stack.fill.badge.person.crop", text: "Boxy UI")
                    heroChip(icon: "lock.shield.fill", text: "Email + Google")
                    heroChip(icon: "externaldrive.badge.icloud", text: "Firestore sync")
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 14) {
                        heroChip(icon: "rectangle.stack.fill.badge.person.crop", text: "Boxy UI")
                        heroChip(icon: "lock.shield.fill", text: "Email + Google")
                    }

                    heroChip(icon: "externaldrive.badge.icloud", text: "Firestore sync")
                }
            }
        }
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
}

struct EntryPanel: View {
    let onLoginTap: () -> Void
    let onRegisterTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top, spacing: 14) {
                entryStat(value: "2 flows", label: "email + Google")
                entryStat(value: "Live", label: "Firebase auth hooks")
            }

            Text("Choose how you want to enter AlgoFlash.")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(AuthPalette.ink)

            Text("Login returns existing users, register creates new Firebase accounts, and Google uses the Apple callback URL scheme already placed in the app plist.")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(AuthPalette.mutedInk)

            VStack(spacing: 14) {
                PrimaryAuthButton(title: "Go to Login", fill: AuthPalette.ink, action: onLoginTap)
                PrimaryAuthButton(title: "Create New Account", fill: AuthPalette.coral, action: onRegisterTap)
            }

            ViewThatFits {
                HStack(spacing: 12) {
                    smallFeature(icon: "envelope.badge", text: "Email sign in")
                    smallFeature(icon: "g.circle.fill", text: "Google sign in")
                    smallFeature(icon: "externaldrive", text: "Profile sync")
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 12) {
                        smallFeature(icon: "envelope.badge", text: "Email sign in")
                        smallFeature(icon: "g.circle.fill", text: "Google sign in")
                    }

                    smallFeature(icon: "externaldrive", text: "Profile sync")
                }
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

struct LoginPanel: View {
    @Binding var email: String
    @Binding var password: String
    let isBusy: Bool
    let onLogin: () -> Void
    let onGoogle: () -> Void
    let onSwap: () -> Void
    let onBack: () -> Void

    var body: some View {
        AuthCard(
            title: "Welcome back",
            subtitle: "Email/password and Google now route through the Firebase authentication controller.",
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

                SessionHintRow(
                    icon: "checkmark.shield",
                    text: "Firebase restores signed-in users automatically until they choose to sign out."
                )

                PrimaryAuthButton(
                    title: "Log In",
                    fill: AuthPalette.ink,
                    isLoading: isBusy,
                    isDisabled: isBusy,
                    action: onLogin
                )

                GoogleAuthButton(
                    isLoading: isBusy,
                    isDisabled: isBusy,
                    action: onGoogle
                )

                InlineSwapPrompt(
                    prompt: "New here?",
                    actionTitle: "Create account",
                    isDisabled: isBusy,
                    action: onSwap
                )

                BackToEntryButton(isDisabled: isBusy, action: onBack)
            }
            .disabled(isBusy)
        }
    }
}

struct RegisterPanel: View {
    @Binding var fullName: String
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String
    let isBusy: Bool
    let onRegister: () -> Void
    let onGoogle: () -> Void
    let onSwap: () -> Void
    let onBack: () -> Void

    var body: some View {
        AuthCard(
            title: "Create your space",
            subtitle: "New accounts are created in Firebase Auth, then a profile document is synced to Firestore when available.",
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

                SessionHintRow(
                    icon: "paperplane",
                    text: "Registration requests an email verification after the Firebase account is created."
                )

                PrimaryAuthButton(
                    title: "Create Account",
                    fill: AuthPalette.coral,
                    isLoading: isBusy,
                    isDisabled: isBusy,
                    action: onRegister
                )

                GoogleAuthButton(
                    isLoading: isBusy,
                    isDisabled: isBusy,
                    action: onGoogle
                )

                InlineSwapPrompt(
                    prompt: "Already have an account?",
                    actionTitle: "Log in",
                    isDisabled: isBusy,
                    action: onSwap
                )

                BackToEntryButton(isDisabled: isBusy, action: onBack)
            }
            .disabled(isBusy)
        }
    }
}

struct SignedInPanel: View {
    let session: AuthenticatedSession
    let onSignOut: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top, spacing: 16) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(AuthPalette.highlight)
                    .frame(width: 72, height: 72)
                    .overlay(
                        Text(session.initials)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(AuthPalette.ink)
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Text("Signed in successfully")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(AuthPalette.mutedInk)
                        .textCase(.uppercase)

                    Text(session.fullName)
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundStyle(AuthPalette.ink)

                    Text(session.email)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(AuthPalette.mutedInk)
                }
            }

            ViewThatFits {
                HStack(spacing: 12) {
                    detailCard(title: "Provider", value: session.providerLabel)
                    detailCard(title: "UID", value: shortIdentifier(session.id))
                }

                VStack(spacing: 12) {
                    detailCard(title: "Provider", value: session.providerLabel)
                    detailCard(title: "UID", value: shortIdentifier(session.id))
                }
            }

            Text("This state appears when Firebase Auth has a live user session. If Firestore is available, the user profile is also merged into the `users` collection.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AuthPalette.mutedInk)
                .fixedSize(horizontal: false, vertical: true)

            PrimaryAuthButton(title: "Sign Out", fill: AuthPalette.ink, action: onSignOut)
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

    private func shortIdentifier(_ value: String) -> String {
        guard value.count > 12 else { return value }
        return "\(value.prefix(6))...\(value.suffix(4))"
    }

    private func detailCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(AuthPalette.mutedInk)
                .textCase(.uppercase)

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(AuthPalette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AuthPalette.cardWash)
        )
    }
}

struct ConnectionStatusCard: View {
    let statusMessage: String
    let errorMessage: String?
    let isFirebaseReady: Bool
    let isBusy: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Connection status")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(AuthPalette.ink)
                .textCase(.uppercase)

            Text(statusMessage)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AuthPalette.mutedInk)
                .fixedSize(horizontal: false, vertical: true)

            if let errorMessage {
                StatusTag(
                    background: AuthPalette.errorWash,
                    border: AuthPalette.errorBorder,
                    foreground: AuthPalette.errorInk,
                    icon: "exclamationmark.triangle.fill",
                    text: errorMessage
                )
            } else if isFirebaseReady {
                StatusTag(
                    background: AuthPalette.successWash,
                    border: AuthPalette.successBorder,
                    foreground: AuthPalette.successInk,
                    icon: "checkmark.seal.fill",
                    text: "Firebase is configured and ready to authenticate on iOS."
                )
            } else {
                StatusTag(
                    background: AuthPalette.warningWash,
                    border: AuthPalette.warningBorder,
                    foreground: AuthPalette.warningInk,
                    icon: "hammer.fill",
                    text: "The code is ready, but Xcode still has to resolve the native Firebase packages on the Mac."
                )
            }

            if isBusy {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(AuthPalette.ink)
                    Text("Talking to Firebase...")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(AuthPalette.ink)
                }
            }
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
}
