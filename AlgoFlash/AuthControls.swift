//
//  AuthControls.swift
//  AlgoFlash
//
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct AuthCard<Content: View>: View {
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

struct SessionHintRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(AuthPalette.ink)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AuthPalette.cardWash)
                )

            Text(text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AuthPalette.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.68))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AuthPalette.border, lineWidth: 1.2)
        )
    }
}

struct StatusTag: View {
    let background: Color
    let border: Color
    let foreground: Color
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
            Text(text)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(border, lineWidth: 1.2)
        )
    }
}

struct BoxyTextField: View {
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

struct BoxySecureField: View {
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

struct PrimaryAuthButton: View {
    let title: String
    let fill: Color
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    init(
        title: String,
        fill: Color,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.fill = fill
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Text(isLoading ? "Working..." : title)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                Spacer()

                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .black))
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(isDisabled ? fill.opacity(0.6) : fill)
            )
            .shadow(color: fill.opacity(0.22), radius: 14, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

struct GoogleAuthButton: View {
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    init(
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

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

                Text(isLoading ? "Contacting Google..." : "Continue with Google")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(AuthPalette.ink)

                Spacer()

                if isLoading {
                    ProgressView()
                        .tint(AuthPalette.ink)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white.opacity(isDisabled ? 0.75 : 1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(AuthPalette.border, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

struct InlineSwapPrompt: View {
    let prompt: String
    let actionTitle: String
    let isDisabled: Bool
    let action: () -> Void

    init(
        prompt: String,
        actionTitle: String,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.prompt = prompt
        self.actionTitle = actionTitle
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        HStack(spacing: 6) {
            Text(prompt)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AuthPalette.mutedInk)

            Button(actionTitle, action: action)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(AuthPalette.ink)
                .disabled(isDisabled)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct BackToEntryButton: View {
    let isDisabled: Bool
    let action: () -> Void

    init(isDisabled: Bool = false, action: @escaping () -> Void) {
        self.isDisabled = isDisabled
        self.action = action
    }

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
        .disabled(isDisabled)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AuthBackground: View {
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

enum AuthPalette {
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
    static let errorWash = Color(red: 0.99, green: 0.90, blue: 0.88)
    static let errorBorder = Color(red: 0.82, green: 0.43, blue: 0.38).opacity(0.45)
    static let errorInk = Color(red: 0.55, green: 0.20, blue: 0.17)
    static let warningWash = Color(red: 0.99, green: 0.95, blue: 0.84)
    static let warningBorder = Color(red: 0.87, green: 0.72, blue: 0.24).opacity(0.5)
    static let warningInk = Color(red: 0.46, green: 0.35, blue: 0.05)
    static let successWash = Color(red: 0.88, green: 0.96, blue: 0.90)
    static let successBorder = Color(red: 0.27, green: 0.60, blue: 0.35).opacity(0.45)
    static let successInk = Color(red: 0.12, green: 0.36, blue: 0.18)
}
