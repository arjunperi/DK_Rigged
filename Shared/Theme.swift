import SwiftUI

// MARK: - App Theme Colors
struct AppTheme {
    // Primary colors
    static let primary = Color.blue
    static let accent = Color.orange
    static let background = Color.black
    static let surfaceBackground = Color.gray.opacity(0.1)
    static let text = Color.white
    static let secondaryText = Color.gray

    // Casino-specific colors - Updated to match DraftKings exactly
    static let casinoGreen = Color(red: 0.2, green: 0.8, blue: 0.2) // Brighter green like DK
    static let casinoRed = Color(red: 0.9, green: 0.1, blue: 0.1) // Vibrant red like DK
    static let casinoBlack = Color(red: 0.15, green: 0.15, blue: 0.15) // Dark gray-black like DK
    static let casinoGold = Color(red: 1.0, green: 0.8, blue: 0.0)
    static let casinoBlue = Color(red: 0.2, green: 0.3, blue: 0.7) // DraftKings blue from screenshot
    static let velvetGreen = Color(red: 0.0, green: 0.39, blue: 0.0) // Rich velvet green

    // Border colors
    static let border = Color.white.opacity(0.8) // Stronger white borders like DK
    static let selectedBorder = Color.blue

    // Gradients - Updated to match DK background
    static let primaryGradient = LinearGradient(
        colors: [Color.blue, Color.purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [Color.black, Color.gray.opacity(0.3)],
        startPoint: .top,
        endPoint: .bottom
    )

    // DraftKings-style background gradient
    static let draftKingsBackground = RadialGradient(
        colors: [
            Color(red: 0.25, green: 0.3, blue: 0.6), // Lighter blue center
            Color(red: 0.15, green: 0.2, blue: 0.45), // Medium blue
            Color(red: 0.1, green: 0.15, blue: 0.35)  // Dark blue edges
        ],
        center: .center,
        startRadius: 100,
        endRadius: 500
    )

    static let velvetGreenGradient = RadialGradient(
        colors: [
            Color(red: 0.1, green: 0.6, blue: 0.1), // Brighter center
            Color(red: 0.05, green: 0.5, blue: 0.05), // Medium green
            Color(red: 0.02, green: 0.4, blue: 0.02)  // Darker edges
        ],
        center: .center,
        startRadius: 100,
        endRadius: 500
    )
}

// MARK: - Typography - Updated for DraftKings style
struct AppTypography {
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title = Font.title.weight(.bold) // Bolder like DK
    static let title2 = Font.title2.weight(.semibold)
    static let headline = Font.headline.weight(.bold) // Bolder like DK
    static let subheadline = Font.subheadline.weight(.semibold)
    static let body = Font.body.weight(.medium) // Slightly bolder
    static let caption = Font.caption.weight(.bold) // Bolder for table text
    static let caption2 = Font.caption2.weight(.medium)
}

// MARK: - Spacing
struct AppSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
struct AppCornerRadius {
    static let small: CGFloat = 4
    static let medium: CGFloat = 8
    static let large: CGFloat = 12
    static let xlarge: CGFloat = 16
}

// MARK: - Custom Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .fill(AppTheme.primary)
            )
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .foregroundColor(AppTheme.text)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct CasinoButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.small)
                    .fill(isSelected ? AppTheme.casinoGold : AppTheme.surfaceBackground)
            )
            .foregroundColor(isSelected ? .black : AppTheme.text)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Custom Shapes
struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: CGPoint(x: center.x, y: center.y - radius))
        path.addLine(to: CGPoint(x: center.x + radius, y: center.y))
        path.addLine(to: CGPoint(x: center.x, y: center.y + radius))
        path.addLine(to: CGPoint(x: center.x - radius, y: center.y))
        path.closeSubpath()

        return path
    }
}
