//
//  SilkaDesign.swift
//  silka
//
//  Linear-inspired Design System
//  Created by Rafał Piekara on 08/09/2025.
//

import SwiftUI

// MARK: - Design Tokens

struct SilkaDesign {

    // MARK: - Colors (Linear-inspired)
    struct Colors {
        // Linear-inspired high contrast palette
        static let background = Color(red: 0.98, green: 0.98, blue: 1.0) // Almost white with purple tint
        static let backgroundDark = Color(red: 0.07, green: 0.07, blue: 0.09) // Very dark blue-gray

        // Pure contrast
        static let surface = Color.white
        static let surfaceDark = Color(red: 0.11, green: 0.11, blue: 0.13)

        // Text - High contrast like Linear
        static let textPrimary = Color(red: 0.05, green: 0.05, blue: 0.05) // Almost black
        static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.4) // Medium gray
        static let textTertiary = Color(red: 0.6, green: 0.6, blue: 0.6) // Light gray

        // Linear's signature purple
        static let accent = Color(red: 0.44, green: 0.37, blue: 1.0) // #6F5EFF - Linear purple
        static let accentLight = Color(red: 0.44, green: 0.37, blue: 1.0).opacity(0.1)
        static let accentSecondary = Color(red: 0.0, green: 0.8, blue: 0.4) // Keep for compatibility

        // Semantic colors - more muted like Linear
        static let success = Color(red: 0.0, green: 0.8, blue: 0.4) // Bright green
        static let warning = Color(red: 1.0, green: 0.6, blue: 0.0) // Amber
        static let error = Color(red: 1.0, green: 0.3, blue: 0.3) // Red
        static let info = accent

        // Ultra-subtle borders like Linear
        static let border = Color(red: 0.9, green: 0.9, blue: 0.92)
        static let borderSubtle = Color(red: 0.95, green: 0.95, blue: 0.97)

        // Exercise states
        static let exerciseCompleted = success
        static let exerciseInProgress = warning
        static let exercisePending = textTertiary
    }

    // MARK: - Typography (Linear-inspired - clean, minimal)
    struct Typography {
        // Display - Linear uses lighter weights for large text
        static let displayLarge = Font.system(size: 36, weight: .light, design: .default)
        static let displayMedium = Font.system(size: 28, weight: .regular, design: .default)
        static let displaySmall = Font.system(size: 22, weight: .medium, design: .default)

        // Headlines - Clean and minimal
        static let headlineLarge = Font.system(size: 18, weight: .medium, design: .default)
        static let headlineMedium = Font.system(size: 16, weight: .medium, design: .default)
        static let headlineSmall = Font.system(size: 14, weight: .medium, design: .default)

        // Body - Regular weights like Linear
        static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
        static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
        static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)

        // Labels - Subtle and clean
        static let labelLarge = Font.system(size: 13, weight: .medium, design: .default)
        static let labelMedium = Font.system(size: 12, weight: .regular, design: .default)
        static let labelSmall = Font.system(size: 11, weight: .regular, design: .default)

        // Monospace for numbers/timers - Linear style
        static let monoLarge = Font.system(size: 18, weight: .regular, design: .monospaced)
        static let monoMedium = Font.system(size: 15, weight: .regular, design: .monospaced)
        static let monoSmall = Font.system(size: 13, weight: .regular, design: .monospaced)
    }

    // MARK: - Spacing (Fixed - reasonable whitespace)
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
        static let xxxl: CGFloat = 48
        static let massive: CGFloat = 64
    }

    // MARK: - Corner Radius (Linear-inspired - minimal)
    struct CornerRadius {
        static let xs: CGFloat = 2
        static let sm: CGFloat = 4
        static let md: CGFloat = 6
        static let lg: CGFloat = 8
        static let xl: CGFloat = 12
        static let xxl: CGFloat = 16
        static let round: CGFloat = 50
    }

    // MARK: - Shadows (Ultra-subtle like Linear)
    struct Shadows {
        static let subtle = Shadow(
            color: Color.black.opacity(0.02),
            radius: 1,
            x: 0,
            y: 0.5
        )

        static let medium = Shadow(
            color: Color.black.opacity(0.04),
            radius: 4,
            x: 0,
            y: 1
        )

        static let strong = Shadow(
            color: Color.black.opacity(0.06),
            radius: 8,
            x: 0,
            y: 2
        )
    }
}

// MARK: - Custom Shadow Struct
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions for Design System
extension View {
    func silkaShadow(_ shadow: Shadow = SilkaDesign.Shadows.subtle) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }

    func silkaCard(padding: CGFloat = SilkaDesign.Spacing.md,
                   cornerRadius: CGFloat = SilkaDesign.CornerRadius.md) -> some View {
        self
            .padding(padding)
            .background(SilkaDesign.Colors.surface)
            .cornerRadius(cornerRadius)
            .silkaShadow()
    }

    func silkaButton(_ style: SilkaButtonStyle = .primary) -> some View {
        SilkaButton(style: style) {
            self
        }
    }
}

// MARK: - Button Styles
enum SilkaButtonStyle {
    case primary
    case secondary
    case tertiary
    case destructive
    case success
}

struct SilkaButton<Content: View>: View {
    let style: SilkaButtonStyle
    let content: Content

    init(style: SilkaButtonStyle, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }

    var body: some View {
        content
            .font(SilkaDesign.Typography.labelLarge)
            .padding(.horizontal, SilkaDesign.Spacing.md)
            .padding(.vertical, SilkaDesign.Spacing.sm)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(SilkaDesign.CornerRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: SilkaDesign.CornerRadius.sm)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return SilkaDesign.Colors.accent
        case .secondary:
            return SilkaDesign.Colors.surface
        case .tertiary:
            return Color.clear
        case .destructive:
            return SilkaDesign.Colors.error
        case .success:
            return SilkaDesign.Colors.success
        }
    }

    private var textColor: Color {
        switch style {
        case .primary, .destructive, .success:
            return .white
        case .secondary:
            return SilkaDesign.Colors.textPrimary
        case .tertiary:
            return SilkaDesign.Colors.accent
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary, .destructive, .success:
            return Color.clear
        case .secondary:
            return SilkaDesign.Colors.border
        case .tertiary:
            return SilkaDesign.Colors.accent
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .primary, .destructive, .success:
            return 0
        case .secondary, .tertiary:
            return 1
        }
    }
}

// MARK: - Status Badge Component
struct SilkaStatusBadge: View {
    let text: String
    let status: StatusType

    enum StatusType {
        case completed
        case inProgress
        case pending
        case info

        var color: Color {
            switch self {
            case .completed:
                return SilkaDesign.Colors.success
            case .inProgress:
                return SilkaDesign.Colors.warning
            case .pending:
                return SilkaDesign.Colors.textTertiary
            case .info:
                return SilkaDesign.Colors.info
            }
        }

        var icon: String {
            switch self {
            case .completed:
                return "checkmark.circle.fill"
            case .inProgress:
                return "clock.fill"
            case .pending:
                return "circle"
            case .info:
                return "info.circle.fill"
            }
        }
    }

    var body: some View {
        HStack(spacing: SilkaDesign.Spacing.xs) {
            Image(systemName: status.icon)
                .font(.system(size: 10, weight: .medium))
            Text(text.uppercased())
                .font(SilkaDesign.Typography.labelSmall)
                .fontWeight(.semibold)
        }
        .foregroundColor(status.color)
        .padding(.horizontal, SilkaDesign.Spacing.sm)
        .padding(.vertical, SilkaDesign.Spacing.xs)
        .background(status.color.opacity(0.1))
        .cornerRadius(SilkaDesign.CornerRadius.xs)
    }
}

// MARK: - Progress Bar Component
struct SilkaProgressBar: View {
    let progress: Double
    let total: Double
    let color: Color
    let height: CGFloat

    init(progress: Double,
         total: Double,
         color: Color = SilkaDesign.Colors.accent,
         height: CGFloat = 4) {
        self.progress = progress
        self.total = total
        self.color = color
        self.height = height
    }

    var progressPercentage: Double {
        guard total > 0 else { return 0 }
        return min(progress / total, 1.0)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(SilkaDesign.Colors.borderSubtle)
                    .frame(height: height)
                    .cornerRadius(height / 2)

                Rectangle()
                    .fill(color)
                    .frame(
                        width: geometry.size.width * progressPercentage,
                        height: height
                    )
                    .cornerRadius(height / 2)
                    .animation(.easeInOut(duration: 0.3), value: progressPercentage)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Metric Display Component
struct SilkaMetric: View {
    let title: String
    let value: String
    let subtitle: String?
    let color: Color
    let alignment: HorizontalAlignment

    init(title: String,
         value: String,
         subtitle: String? = nil,
         color: Color = SilkaDesign.Colors.textPrimary,
         alignment: HorizontalAlignment = .leading) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.color = color
        self.alignment = alignment
    }

    var body: some View {
        VStack(alignment: alignment, spacing: SilkaDesign.Spacing.xs) {
            Text(value)
                .font(SilkaDesign.Typography.displaySmall)
                .fontWeight(.bold)
                .foregroundColor(color)
                .monospacedDigit()

            VStack(alignment: alignment, spacing: 2) {
                Text(title)
                    .font(SilkaDesign.Typography.labelMedium)
                    .foregroundColor(SilkaDesign.Colors.textSecondary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(SilkaDesign.Typography.labelSmall)
                        .foregroundColor(SilkaDesign.Colors.textTertiary)
                }
            }
        }
    }
}
