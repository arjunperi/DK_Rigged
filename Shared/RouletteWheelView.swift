import SwiftUI

struct RouletteWheelView: View {
    @Binding var isSpinning: Bool
    @Binding var result: RouletteResult?
    
    @State private var wheelRotation: Double = 0
    @State private var ballRotation: Double = 0
    @State private var ballRadius: CGFloat = 80
    @State private var showResult = false
    
    // Roulette numbers in standard European order
    private let wheelNumbers = [0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10, 5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26]
    
    var body: some View {
        ZStack {
            // Dark overlay background
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Wheel container
                ZStack {
                    // Outer rim
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.brown, Color.brown.opacity(0.6)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                    
                    // Wheel segments
                    ForEach(Array(wheelNumbers.enumerated()), id: \.offset) { index, number in
                        WheelSegment(
                            number: number,
                            angle: Double(index) * (360.0 / Double(wheelNumbers.count)),
                            segmentAngle: 360.0 / Double(wheelNumbers.count)
                        )
                        .rotationEffect(.degrees(wheelRotation))
                    }
                    
                    // Center hub
                    Circle()
                        .fill(AppTheme.casinoGold)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                    
                    // Ball
                    if isSpinning && !showResult {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 12, height: 12)
                            .offset(x: ballRadius)
                            .rotationEffect(.degrees(ballRotation))
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                    }
                    
                    // Result display
                    if showResult, let result = result {
                        ResultDisplayView(result: result)
                    }
                }
                .frame(width: 250, height: 250)
                
                Spacer()
                
                // Spinning indicator
                if isSpinning && !showResult {
                    VStack(spacing: AppSpacing.sm) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.casinoGold))
                        
                        Text("Spinning...")
                            .font(AppTypography.headline)
                            .foregroundColor(AppTheme.text)
                    }
                    .padding(.bottom, AppSpacing.xl)
                }
            }
        }
        .onAppear {
            if isSpinning {
                startSpinAnimation()
            }
        }
        .onChange(of: isSpinning) { spinning in
            if spinning {
                startSpinAnimation()
            } else {
                resetAnimation()
            }
        }
    }
    
    private func startSpinAnimation() {
        showResult = false
        
        // Start wheel spinning
        withAnimation(.linear(duration: 4.0).repeatCount(1, autoreverses: false)) {
            wheelRotation += 1440 // 4 full rotations
        }
        
        // Start ball spinning (opposite direction, faster)
        withAnimation(.linear(duration: 3.5).repeatCount(1, autoreverses: false)) {
            ballRotation -= 2160 // 6 full rotations opposite direction
        }
        
        // Ball radius animation (moves inward as it slows)
        withAnimation(.easeOut(duration: 3.5)) {
            ballRadius = 60
        }
        
        // Show result after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            showResult = true
            
            // Auto-exit after showing result
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isSpinning = false
                }
            }
        }
    }
    
    private func resetAnimation() {
        wheelRotation = 0
        ballRotation = 0
        ballRadius = 80
        showResult = false
    }
    
    private func getAngleForNumber(_ number: Int) -> Double {
        guard let index = wheelNumbers.firstIndex(of: number) else { return 0 }
        return Double(index) * (360.0 / Double(wheelNumbers.count))
    }
    
    private func getColorForNumber(_ number: Int) -> Color {
        switch number {
        case 0: return AppTheme.casinoGreen
        case 1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36:
            return AppTheme.casinoRed
        default:
            return AppTheme.casinoBlack
        }
    }
}

// MARK: - Wheel Segment
struct WheelSegment: View {
    let number: Int
    let angle: Double
    let segmentAngle: Double
    
    var body: some View {
        ZStack {
            // Segment background
            Path { path in
                let center = CGPoint(x: 0, y: 0)
                let radius: CGFloat = 100
                let startAngle = Angle.degrees(angle - segmentAngle/2)
                let endAngle = Angle.degrees(angle + segmentAngle/2)
                
                path.move(to: center)
                path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                path.closeSubpath()
            }
            .fill(getColorForNumber(number))
            .overlay(
                Path { path in
                    let center = CGPoint(x: 0, y: 0)
                    let radius: CGFloat = 100
                    let startAngle = Angle.degrees(angle - segmentAngle/2)
                    let endAngle = Angle.degrees(angle + segmentAngle/2)
                    
                    path.move(to: center)
                    path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                    path.closeSubpath()
                }
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            
            // Number text
            Text("\(number)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .offset(y: -70)
                .rotationEffect(.degrees(angle))
        }
    }
    
    private func getColorForNumber(_ number: Int) -> Color {
        switch number {
        case 0: return AppTheme.casinoGreen
        case 1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36:
            return AppTheme.casinoRed
        default:
            return AppTheme.casinoBlack
        }
    }
}

// MARK: - Result Display
struct ResultDisplayView: View {
    let result: RouletteResult
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            // Winning number
            Text("\(result.number)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
                .padding()
                .background(
                    Circle()
                        .fill(getColorForNumber(result.number))
                        .overlay(
                            Circle()
                                .stroke(AppTheme.casinoGold, lineWidth: 4)
                        )
                )
            
            // Color indicator
            Text(result.color.rawValue.uppercased())
                .font(AppTypography.headline)
                .foregroundColor(AppTheme.text)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                        .fill(getColorForNumber(result.number).opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .stroke(getColorForNumber(result.number), lineWidth: 2)
                        )
                )
        }
        .scaleEffect(0.1)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                // This will be applied by the parent view
            }
        }
    }
    
    private func getColorForNumber(_ number: Int) -> Color {
        switch number {
        case 0: return AppTheme.casinoGreen
        case 1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36:
            return AppTheme.casinoRed
        default:
            return AppTheme.casinoBlack
        }
    }
}

// MARK: - Preview Provider
struct RouletteWheelView_Previews: PreviewProvider {
    static var previews: some View {
        RouletteWheelView(
            isSpinning: .constant(true),
            result: .constant(RouletteResult(number: 17, color: .red, timestamp: Date()))
        )
    }
} 