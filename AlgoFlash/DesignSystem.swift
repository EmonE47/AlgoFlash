import SwiftUI
import UIKit

extension Color {
    static let brand = Color(red: 0.31, green: 0.27, blue: 0.90)
    static let brandLight = Color(red: 0.51, green: 0.55, blue: 0.97)
    static let brandDark = Color(red: 0.22, green: 0.19, blue: 0.64)

    static let surface0 = Color(.systemBackground)
    static let surface1 = Color(.secondarySystemBackground)
    static let surface2 = Color(.tertiarySystemBackground)

    static let success = Color(red: 0.06, green: 0.73, blue: 0.51)
    static let warning = Color(red: 0.96, green: 0.62, blue: 0.07)
    static let danger = Color(red: 0.94, green: 0.27, blue: 0.27)
    static let info = Color(red: 0.23, green: 0.51, blue: 0.96)

    static let diffEasy = Color.success
    static let diffMedium = Color.warning
    static let diffHard = Color.danger
}

enum Motion {
    static let spring = Animation.spring(response: 0.38, dampingFraction: 0.72)
    static let springFast = Animation.spring(response: 0.25, dampingFraction: 0.80)
    static let easeOut = Animation.easeOut(duration: 0.22)
    static let flip = Animation.spring(response: 0.48, dampingFraction: 0.70)
}

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

struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.brand.opacity(0.13),
                Color.surface0,
                Color.warning.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct BrandGradient: View {
    var colors: [Color] = [Color.brand, Color.brandLight]

    var body: some View {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(Motion.springFast, value: configuration.isPressed)
    }
}

struct AlgoButton: View {
    enum Style {
        case primary
        case secondary
        case ghost
        case danger
    }

    let title: String
    var icon: String? = nil
    var style: Style = .primary
    var isLoading = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(style == .primary || style == .danger ? Color.white : Color.brand)
                        .scaleEffect(0.85)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.body.weight(.semibold))
                    }
                    Text(title)
                        .font(.body.weight(.semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundStyle(foregroundColor)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(border)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isLoading)
        .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder private var background: some View {
        switch style {
        case .primary:
            BrandGradient()
        case .secondary:
            Color.brand.opacity(0.12)
        case .ghost:
            Color.clear
        case .danger:
            LinearGradient(colors: [Color.danger, Color.danger.opacity(0.75)], startPoint: .leading, endPoint: .trailing)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary, .danger:
            return .white
        case .secondary, .ghost:
            return Color.brand
        }
    }

    @ViewBuilder private var border: some View {
        if style == .ghost {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.brand.opacity(0.35), lineWidth: 1)
        }
    }
}

struct AlgoTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 10) {
            if let icon {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                    .accessibilityHidden(true)
            }

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .sentences)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.surface1)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(text.isEmpty ? Color.clear : Color.brand.opacity(0.45), lineWidth: 1.5)
        )
        .animation(Motion.easeOut, value: text.isEmpty)
    }
}

struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.selection()
            action()
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundStyle(isSelected ? Color.white : Color.secondary)
                .background(pillBackground)
                .clipShape(Capsule())
                .shadow(color: isSelected ? categoryGradient(title).0.opacity(0.30) : .clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(Motion.spring, value: isSelected)
    }

    @ViewBuilder private var pillBackground: some View {
        if isSelected {
            let gradient = categoryGradient(title)
            LinearGradient(colors: [gradient.0, gradient.1], startPoint: .leading, endPoint: .trailing)
        } else {
            Color.surface2
        }
    }
}

struct EmptyStateView: View {
    let icon: String
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
                    .foregroundStyle(LinearGradient(colors: [Color.brand, Color.brandLight], startPoint: .top, endPoint: .bottom))
                    .accessibilityHidden(true)
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.title2.bold())
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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
        .padding(24)
    }
}

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MetricPill: View {
    let title: String
    let icon: String

    var body: some View {
        Label(title, systemImage: icon)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundStyle(.white)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
    }
}

func categoryGradient(_ category: String) -> (Color, Color) {
    switch category {
    case "Searching":
        return (Color.brand, Color.brandLight)
    case "Sorting":
        return (Color.success, Color(red: 0.20, green: 0.88, blue: 0.67))
    case "Graph":
        return (Color.warning, Color(red: 1.0, green: 0.78, blue: 0.20))
    case "Dynamic Programming":
        return (Color.danger, Color(red: 1.0, green: 0.50, blue: 0.50))
    case "String":
        return (Color.info, Color(red: 0.31, green: 0.80, blue: 0.95))
    default:
        return (Color.brand, Color.brandLight)
    }
}

func difficultyColor(_ difficulty: String) -> Color {
    switch difficulty {
    case "Easy":
        return Color.diffEasy
    case "Medium":
        return Color.diffMedium
    case "Hard":
        return Color.diffHard
    default:
        return .secondary
    }
}
