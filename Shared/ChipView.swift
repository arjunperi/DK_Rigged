import SwiftUI

// MARK: - Individual Chip View
struct ChipView: View {
    let value: Double
    let size: CGFloat
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Main chip body with realistic gradient
            Circle()
                .fill(
                    RadialGradient(
                        colors: [chipColor.opacity(0.9), chipColor, chipColor.opacity(0.7)],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: size/2
                    )
                )
                .frame(width: size, height: size)

            // Outer edge highlight (like real casino chips)
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.6), Color.white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: size, height: size)

            // Inner colored stripes (like DK chips)
            ForEach(0..<8) { index in
                let angle = Double(index) * 45
                Rectangle()
                    .fill(chipAccentColor)
                    .frame(width: 2, height: size * 0.3)
                    .offset(y: -size * 0.25)
                    .rotationEffect(.degrees(angle))
            }

            // Center circle with value
            Circle()
                .fill(
                    RadialGradient(
                        colors: [chipColor.opacity(0.9), chipColor],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.25
                    )
                )
                .frame(width: size * 0.5, height: size * 0.5)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.8), lineWidth: 1)
                        .frame(width: size * 0.5, height: size * 0.5)
                )

            // Chip value text
            Text(chipValueText)
                .font(.system(size: min(size * 0.2, 12), weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.8), radius: 1, x: 0, y: 1)
        }
        .scaleEffect(isAnimating ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAnimating)
        .onAppear {
            isAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = false
            }
        }
    }

    private var chipColor: Color {
        switch value {
        case 1: return Color.white
        case 5: return AppTheme.casinoRed
        case 10: return Color.blue
        case 25: return AppTheme.casinoGreen
        case 50: return Color.orange
        case 100: return Color.black
        default: return Color.gray
        }
    }

    private var chipAccentColor: Color {
        switch value {
        case 1: return Color.gray
        case 5: return Color.white
        case 10: return Color.white
        case 25: return Color.white
        case 50: return Color.white
        case 100: return AppTheme.casinoGold
        default: return Color.white
        }
    }

    private var chipValueText: String {
        if value >= 1000 {
            return "\(Int(value/1000))K"
        } else if value == floor(value) {
            return "\(Int(value))"
        } else {
            return String(format: "%.1f", value)
        }
    }
}

// MARK: - Chip Stack for Multiple Chips
struct ChipStack: View {
    let values: [Double]
    let size: CGFloat

    var body: some View {
        ZStack {
            ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                ChipView(value: value, size: size)
                    .offset(x: CGFloat(index) * 2, y: CGFloat(-index) * 3)
            }
        }
    }
}

// MARK: - Chip Selector Bar
struct ChipSelectorView: View {
    @Binding var selectedChipValue: Double
    let availableChips: [Double] = [1, 5, 10, 25, 50, 100]

    var body: some View {
        VStack(spacing: AppSpacing.xxs) {
            Text("Select Chip")
                .font(AppTypography.caption)
                .foregroundColor(AppTheme.secondaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(availableChips, id: \.self) { chipValue in
                        ChipSelectorButton(
                            value: chipValue,
                            isSelected: selectedChipValue == chipValue
                        ) {
                            selectedChipValue = chipValue
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.sm)
                .frame(maxWidth: .infinity) // Center the chips
            }
        }
        .padding(.vertical, AppSpacing.xxs)
    }
}

// MARK: - Individual Chip Selector Button
struct ChipSelectorButton: View {
    let value: Double
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            ChipView(value: value, size: 40)
                .overlay(
                    Circle()
                        .stroke(
                            isSelected ? AppTheme.casinoGold : Color.clear,
                            lineWidth: 2
                        )
                        .frame(width: 44, height: 44)
                )
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            isPressed = true
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }
    }
}

// MARK: - Chip Stack Indicator (for betting areas)
struct ChipStackIndicator: View {
    let totalAmount: Double
    let chipSize: CGFloat

    var body: some View {
        if totalAmount > 0 {
            ZStack {
                // Show appropriate chip based on total amount
                ChipView(value: getChipValueForStack(totalAmount), size: chipSize)

                // Show stack count if more than one chip worth
                if totalAmount > getChipValueForStack(totalAmount) {
                    Text("\(Int(totalAmount))")
                        .font(.system(size: chipSize * 0.2, weight: .bold))
                        .foregroundColor(.white)
                        .padding(2)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.7))
                        )
                        .offset(x: chipSize * 0.3, y: -chipSize * 0.3)
                }
            }
        }
    }

    private func getChipValueForStack(_ amount: Double) -> Double {
        let availableChips: [Double] = [500, 250, 100, 50, 25, 10, 5, 1]

        for chipValue in availableChips {
            if amount >= chipValue {
                return chipValue
            }
        }

        return 1
    }
}

// MARK: - Preview Provider
struct ChipView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Individual chips
            HStack {
                ForEach([1.0, 5.0, 10.0, 25.0, 50.0], id: \.self) { value in
                    ChipView(value: value, size: 40)
                }
            }

            // Chip stack
            ChipStack(values: [100, 25, 5], size: 40)

            // Chip selector
            ChipSelectorView(selectedChipValue: .constant(25))

            // Stack indicator
            ChipStackIndicator(totalAmount: 75, chipSize: 50)
        }
        .padding()
        .background(AppTheme.background)
    }
}
