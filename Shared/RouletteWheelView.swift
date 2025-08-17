import SwiftUI

struct RouletteWheelView: View {
    @Binding var isSpinning: Bool
    @Binding var result: RouletteResult?
    
    @State private var wheelRotation: Double = 0
    @State private var ballRotation: Double = 0
    @State private var ballRadius: CGFloat = 80
    @State private var showResult = false
    
    // Roulette numbers in correct American roulette order (clockwise from 0)
    private let wheelNumbers = [0, 28, 9, 26, 30, 11, 7, 20, 32, 17, 5, 22, 34, 15, 3, 24, 36, 13, 1, 37, 27, 10, 25, 29, 12, 8, 19, 31, 18, 6, 21, 33, 16, 4, 23, 35, 14, 2]
    
    var body: some View {
        ZStack {
            // Dark overlay background
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Wheel container
                ZStack {
                    // Single unified roulette wheel
                    UnifiedRouletteWheel(numbers: wheelNumbers)
                        .frame(width: 240, height: 240)
                        .rotationEffect(.degrees(wheelRotation))
                    
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
        
        // Start wheel spinning (slower)
        withAnimation(.linear(duration: 6.0).repeatCount(1, autoreverses: false)) {
            wheelRotation += 1440 // 4 full rotations
        }
        
        // Start ball spinning (opposite direction, slower)
        withAnimation(.linear(duration: 5.5).repeatCount(1, autoreverses: false)) {
            ballRotation -= 2160 // 6 full rotations opposite direction
        }
        
        // Ball radius animation (moves inward as it slows)
        withAnimation(.easeOut(duration: 5.5)) {
            ballRadius = 60
        }
        
        // Show result after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
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
        case 0, 37: return AppTheme.casinoGreen // 0 and 00 (37) are green
        case 1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36:
            return AppTheme.casinoRed
        default:
            return AppTheme.casinoBlack
        }
    }
}

// MARK: - Unified Roulette Wheel
struct UnifiedRouletteWheel: View {
    let numbers: [Int]
    
    var body: some View {
        ZStack {
            // Outer wooden rim (like reference image)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.brown.opacity(0.8), Color.brown.opacity(0.4)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 420, height: 420)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.8), Color.orange.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 8
                        )
                )
            
            // Main wheel with all segments
            Canvas { context, size in
                let center = CGPoint(x: size.width/2, y: size.height/2)
                let radius: CGFloat = min(size.width, size.height) * 0.42 // Even larger inner circle
                let segmentAngle = 360.0 / Double(numbers.count)
            
            // Draw all segments
            for (index, number) in numbers.enumerated() {
                let startAngle = Double(index) * segmentAngle - 90 // Start from top
                let endAngle = startAngle + segmentAngle
                
                // Create segment path
                var path = Path()
                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .degrees(startAngle),
                    endAngle: .degrees(endAngle),
                    clockwise: false
                )
                path.closeSubpath()
                
                // Fill with appropriate color
                context.fill(path, with: .color(getColorForNumber(number)))
                
                // Add clean white border between segments
                context.stroke(path, with: .color(.white), lineWidth: 2)
                
                // Add number text - positioned better for larger wheel
                let textAngle = startAngle + segmentAngle/2
                let textRadius = radius * 0.75 // Closer to edge for better fit
                let textX = center.x + cos(textAngle * .pi / 180) * textRadius
                let textY = center.y + sin(textAngle * .pi / 180) * textRadius
                
                // Calculate optimal font size based on segment size (much larger numbers)
                let segmentWidth = 2 * .pi * textRadius * CGFloat(segmentAngle / 360.0)
                let fontSize = min(segmentWidth * 0.7, 36) // Much larger numbers like reference
                
                context.draw(
                    Text(displayNumber(number))
                        .font(.system(size: fontSize, weight: .bold))
                        .foregroundColor(.white),
                    at: CGPoint(x: textX, y: textY)
                )
            }
            
            // Add outer rim stroke for clean edge
            let outerPath = Path { path in
                path.addEllipse(in: CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                ))
            }
            context.stroke(outerPath, with: .color(.white), lineWidth: 3)
        }
        .frame(width: 380, height: 380) // Much larger canvas for bigger circle
        }
        .frame(width: 420, height: 420) // Overall larger frame
    }
    
    private func displayNumber(_ number: Int) -> String {
        return number == 37 ? "00" : "\(number)"
    }
    
    private func getColorForNumber(_ number: Int) -> Color {
        switch number {
        case 0, 37: return AppTheme.casinoGreen // 0 and 00 (37) are green
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
            Text(displayNumber(result.number))
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
    
    private func displayNumber(_ number: Int) -> String {
        return number == 37 ? "00" : "\(number)"
    }
    
    private func getColorForNumber(_ number: Int) -> Color {
        switch number {
        case 0, 37: return AppTheme.casinoGreen // 0 and 00 (37) are green
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