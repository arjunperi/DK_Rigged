import SwiftUI

// MARK: - Color Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

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

    // Border colors - Following Apple's semantic color approach
    static let border = Color.white.opacity(0.8) // Stronger white borders like DK
    static let selectedBorder = Color.blue
    static let subtleBorder = Color.white.opacity(0.3) // Subtle borders for transparent areas
    static let focusBorder = Color.blue.opacity(0.6) // Focus state borders

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
            Color(hex: "#006400"), // Dark green center
            Color(hex: "#004d00"), // Even darker green
            Color(hex: "#003300")  // Darkest green edges
        ],
        center: .center,
        startRadius: 100,
        endRadius: 500
    )
}

// MARK: - Apple-style Shadows
struct AppShadows {
    static let subtle = Color.black.opacity(0.1)
    static let medium = Color.black.opacity(0.2)
    static let strong = Color.black.opacity(0.3)
    static let focus = Color.blue.opacity(0.2)
    
    // Apple-style shadow configurations
    static let cardShadow = ShadowConfig(color: subtle, radius: 8, x: 0, y: 2)
    static let buttonShadow = ShadowConfig(color: medium, radius: 4, x: 0, y: 1)
    static let focusShadow = ShadowConfig(color: focus, radius: 12, x: 0, y: 4)
}

struct ShadowConfig {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
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

// MARK: - Spacing - Following Apple's 8pt grid system
struct AppSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
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
            .shadow(color: AppShadows.buttonShadow.color, radius: AppShadows.buttonShadow.radius, x: AppShadows.buttonShadow.x, y: AppShadows.buttonShadow.y)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
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
            .shadow(color: isSelected ? AppShadows.focusShadow.color : AppShadows.subtle, 
                   radius: isSelected ? AppShadows.focusShadow.radius : AppShadows.buttonShadow.radius, 
                   x: 0, y: isSelected ? AppShadows.focusShadow.y : AppShadows.buttonShadow.y)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
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
