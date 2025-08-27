import SwiftUI

// MARK: - SIMPLE ROULETTE HELPER (Embedded)
// Clean, well-structured helper that implements the dead-simple logic with proper calibration
private final class SimpleRoulette {
    // American wheel order (clockwise)
    static let wheel: [String] = [
        "0","28","9","26","30","11","7","20","32","17",
        "5","22","34","15","3","24","36","13","1","00",
        "27","10","25","29","12","8","19","31","18","6",
        "21","33","16","4","23","35","14","2"
    ]

    let pocketDeg = 360.0 / 38.0
    var artOffsetDeg: Double      // calibrate once for your artwork
    var direction: Double         // +1 if positive spin is CW on screen, else -1

    init(artOffsetDeg: Double = 0, direction: Double = 1) {
        self.artOffsetDeg = artOffsetDeg
        self.direction    = direction
    }

    // Normalize angle to [0, 360)
    @inline(__always) func norm(_ a: Double) -> Double {
        let x = a.truncatingRemainder(dividingBy: 360.0)
        return x < 0 ? x + 360.0 : x
    }

    // Core: compute final angles for wheel and ball
    struct SpinPlan {
        let targetIndex: Int
        let landingWorldDeg: Double
        let finalWheelDeg: Double
        let finalBallDeg: Double
        let resultNumber: String
    }

    func planSpin(
        riggedNumber: String?,                // nil = random
        currentWheelDeg: Double,              // current wheel world angle
        extraTurnsWheel: Int = 10,            // 8–16 looks nice
        extraTurnsBall: Int  = 14,            // ball can spin more
        landingWorldDeg: Double? = nil        // nil = random [0, 360)
    ) -> SpinPlan {
        // 1) choose target index
        let idx: Int = {
            if let n = riggedNumber, let i = Self.wheel.firstIndex(of: n) {
                return i
            } else {
                return Int.random(in: 0..<Self.wheel.count)
            }
        }()

        // 2) choose landing angle in world space (where the ball will visually stop)
        let land = landingWorldDeg.map(norm) ?? Double.random(in: 0..<360)

        // 3) pocket local angle in wheel space
        let targetLocal = artOffsetDeg + Double(idx) * pocketDeg

        // 4) solve for base wheel angle so target pocket lands at `land`
        // world(target) = direction * wheelFinal + targetLocal ≡ land (mod 360)
        var base = (direction > 0) ? (land - targetLocal) : (targetLocal - land)
        base = norm(base)

        // 5) choose final wheel angle: from current → base + full spins, minimal positive delta in spin direction
        let curDirected = norm(direction * currentWheelDeg)
        let baseDirected = norm(base)
        let deltaToBase = norm(baseDirected - curDirected)
        let finalDirected = curDirected + Double(max(0, extraTurnsWheel)) * 360.0 + deltaToBase
        let finalWheel = finalDirected / direction

        // 6) ball final angle: same world landing angle, but allow its own extra spins during animation
        let finalBall = land + Double(max(0, extraTurnsBall)) * 360.0 * direction

        return SpinPlan(
            targetIndex: idx,
            landingWorldDeg: norm(land),
            finalWheelDeg: finalWheel,
            finalBallDeg: finalBall,
            resultNumber: Self.wheel[idx]
        )
    }
}

// MARK: - DEBUG HELPER FUNCTIONS
// Helper to test segment mapping without spinning
private func debugSegmentMapping(for riggedNumber: Int) {
    let targetString = riggedNumber == 37 ? "00" : String(riggedNumber)
    if let index = SimpleRoulette.wheel.firstIndex(of: targetString) {
        print("🔍 DEBUG MAPPING FOR \(riggedNumber):")
        print("   • Target: '\(targetString)'")
        print("   • Found at Index: \(index)")
        print("   • Number at Index \(index): '\(SimpleRoulette.wheel[index])'")
        print("   • Match: \(targetString == SimpleRoulette.wheel[index] ? "✅" : "❌")")
        
        // Show surrounding context
        let startIdx = max(0, index - 2)
        let endIdx = min(SimpleRoulette.wheel.count - 1, index + 2)
        print("   • Context [\(startIdx)-\(endIdx)]: \(Array(SimpleRoulette.wheel[startIdx...endIdx]))")
    } else {
        print("❌ Number \(riggedNumber) not found in wheel array!")
    }
}

// MARK: - SIMPLE ROULETTE HELPER INSTANCE
// Clean, well-structured helper that implements the dead-simple logic with proper calibration
private let simpleRoulette = SimpleRoulette(artOffsetDeg: 272.3685, direction: 1) // Adjusted for artwork offset (+9 segments)

struct RouletteWheelView: View {
    @Binding var isSpinning: Bool
    @Binding var result: RouletteResult?
    var onAnimationComplete: (() -> Void)? = nil
    var riggedNumber: Int? = nil // Add rigged number parameter
    
    @State private var wheelRotation: Double = 0
    @State private var ballRotation: Double = 0
    @State private var ballRadius: CGFloat = 120
    @State private var showResult = false
    @State private var wheelAnimationComplete = false
    @State private var showWheelResults = false // Keep wheel visible after spin
    @State private var currentSpinPlan: SimpleRoulette.SpinPlan? // Store current spin plan for result calculation
    

    
    var body: some View {
        ZStack {
            // Dark overlay background
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
                        ZStack {
                // Wheel container - positioned in center of screen
                ZStack {
                    // Single unified roulette wheel
                    UnifiedRouletteWheel(numbers: SimpleRoulette.wheel.map { Int($0) ?? 0 })
                        .frame(width: 360, height: 360)
                        .rotationEffect(.degrees(wheelRotation))
                        .animation(wheelAnimationComplete ? nil : .linear(duration: 6.0).repeatCount(1, autoreverses: false), value: wheelRotation)
                    
                    // DEBUG: Show target segment indicator (temporary)
                    if let spinPlan = currentSpinPlan {
                        Circle()
                            .stroke(Color.red, lineWidth: 3)
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(-wheelRotation + Double(spinPlan.targetIndex) * (360.0 / 38.0) + simpleRoulette.artOffsetDeg))
                            .opacity(showResult ? 1.0 : 0.0)
                    }
                    
                    // Center hub with realistic metallic appearance
                    ZStack {
                        // Main hub circle
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: "FFD700"),
                                        Color(hex: "D4AF37"),
                                        Color(hex: "B8860B")
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 27.5
                                )
                            )
                            .frame(width: 55, height: 55)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "FFD700"),
                                                Color(hex: "B8860B")
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.4), radius: 3, x: 2, y: 2)
                        
                        // Metallic spokes extending outward
                        ForEach(0..<4, id: \.self) { index in
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "FFD700"),
                                            Color(hex: "D4AF37"),
                                            Color(hex: "B8860B")
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 3, height: 25)
                                .rotationEffect(.degrees(Double(index) * 90))
                                .offset(y: -12.5)
                                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 1)
                        }
                        
                        // Inner center cap
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: "FFD700"),
                                        Color(hex: "D4AF37")
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 15
                                )
                            )
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "B8860B"), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.4), radius: 2, x: 1, y: 1)
                    }
                    
                    // Ball with realistic appearance
                    if isSpinning {
                        ZStack {
                            // Main ball with metallic shine
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color.white,
                                            Color(hex: "F0F0F0"),
                                            Color(hex: "E0E0E0")
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 8
                                    )
                                )
                                .frame(width: 16, height: 16)
                                .overlay(
                                    // Highlight reflection
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [
                                                    Color.white.opacity(0.8),
                                                    Color.clear
                                                ],
                                                center: .center,
                                                startRadius: 0,
                                                endRadius: 6
                                            )
                                        )
                                        .frame(width: 12, height: 12)
                                        .offset(x: -2, y: -2)
                                )
                                .overlay(
                                    // Subtle border
                                    Circle()
                                        .stroke(Color(hex: "C0C0C0"), lineWidth: 0.5)
                                )
                                .offset(x: ballRadius)
                                .rotationEffect(.degrees(ballRotation))
                                .animation(wheelAnimationComplete ? nil : .easeOut(duration: 6.0), value: ballRotation)
                                .shadow(color: .black.opacity(0.6), radius: 3, x: 2, y: 2)
                                .animation(wheelAnimationComplete ? nil : .easeOut(duration: 6.0), value: ballRadius)
                        }
                    }
                    
                    // Result display
                    if showResult, let result = result {
                        ResultDisplayView(result: result)
                    }
                    
                    // X button to dismiss wheel results
                    if showWheelResults {
                        VStack {
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation(.easeOut(duration: 0.5)) {
                                        isSpinning = false
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.7))
                                        .clipShape(Circle())
                                }
                                .padding(.trailing, 20)
                            }
                            Spacer()
                        }
                    }
                }
                .frame(width: 400, height: 400)
                
                // Spinning indicator - positioned at bottom
                VStack {
                    Spacer()
                    
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
        }
        .onAppear {
            if isSpinning {
                startSpinAnimation()
            }
        }
        .onChange(of: isSpinning) { spinning in
            if spinning {
                startSpinAnimation()
            }
            // Don't reset animation when spinning stops - keep wheel in final position
        }
    }
    
    private func startSpinAnimation() {
        showResult = false
        
        // Reset wheel to starting position for new spin
        wheelRotation = 0
        
        // Use the SimpleRoulette helper for clean, reliable spins
        let spinPlan = simpleRoulette.planSpin(
            riggedNumber: riggedNumber.map { $0 == 37 ? "00" : String($0) }, // convert 37→"00"
            currentWheelDeg: wheelRotation,
            extraTurnsWheel: Int.random(in: 8...16),
            extraTurnsBall: Int.random(in: 12...18),
            landingWorldDeg: nil // random landing angle so it's not always 12 o'clock
        )
        
        // Store the spin plan for result calculation
        currentSpinPlan = spinPlan
        
        print("🎯 SIMPLE ROULETTE SPIN PLAN:")
        print("   • Target Index: \(spinPlan.targetIndex)")
        print("   • Landing World Angle: \(spinPlan.landingWorldDeg)°")
        print("   • Final Wheel Angle: \(spinPlan.finalWheelDeg)°")
        print("   • Final Ball Angle: \(spinPlan.finalBallDeg)°")
        print("   • Result Number: '\(spinPlan.resultNumber)'")
        print("   • ✅ INVARIANT: ball and wheel end at same world angle")
        
        // DEBUG: Show the segment mapping issue
        print("🔍 DEBUG SEGMENT MAPPING:")
        print("   • Rigged Number: \(riggedNumber?.description ?? "nil")")
        print("   • Target String: \(riggedNumber.map { $0 == 37 ? "00" : String($0) } ?? "nil")")
        print("   • Found at Index: \(spinPlan.targetIndex)")
        print("   • Number at that Index: '\(SimpleRoulette.wheel[spinPlan.targetIndex])'")
        print("   • Expected: Should match rigged number")
        print("   • Actual: \(SimpleRoulette.wheel[spinPlan.targetIndex])")
        
        // Show a few surrounding segments for context
        let startIdx = max(0, spinPlan.targetIndex - 2)
        let endIdx = min(SimpleRoulette.wheel.count - 1, spinPlan.targetIndex + 2)
        print("   • Surrounding segments: \(startIdx)-\(endIdx): \(Array(SimpleRoulette.wheel[startIdx...endIdx]))")
        
        // DEBUG: Test mapping for this specific number
        if let riggedNum = riggedNumber {
            debugSegmentMapping(for: riggedNum)
        }
        
        // Update wheel and ball rotations
        wheelRotation = spinPlan.finalWheelDeg
        ballRotation = spinPlan.finalBallDeg
        
        // Set wheel animation complete after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            wheelAnimationComplete = true
        }
        
        // Ball radius animation (moves inward as it slows)
        ballRadius = 85
        
        // Show result after ALL animations complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            // All animations are complete - wheel and ball are now still
            showResult = true
            showWheelResults = true // Keep wheel visible
            
            // After animations complete:
            guard let spinPlan = currentSpinPlan else { return }

            // Map "00" → 37 for the Int-based model
            let resultNumberInt = (spinPlan.resultNumber == "00") ? 37 : Int(spinPlan.resultNumber) ?? 0
            let resultColor = getRouletteColorForNumber(resultNumberInt)

            print("🎯 SIMPLE ROULETTE RESULT:")
            print("   • Helper Result: '\(spinPlan.resultNumber)'")
            print("   • Result Number: \(resultNumberInt)")
            print("   • ✅ Result guaranteed to match visual landing")

            result = RouletteResult(number: resultNumberInt, color: resultColor, timestamp: Date())
            
            // Notify that animation is complete
            onAnimationComplete?()
        }
    }
    
    private func resetAnimation() {
        // Don't reset wheel rotation - keep it in final position
        // Only reset ball and result state
        ballRotation = 0
        ballRadius = 120
        showResult = false
        showWheelResults = false
        wheelAnimationComplete = false
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
    

    
    // Convert Color to RouletteColor for result creation
    private func getRouletteColorForNumber(_ number: Int) -> RouletteColor {
        switch number {
        case 0, 37: return .green // 0 and 00 (37) are green
        case 1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36:
            return .red
        default:
            return .black
        }
    }
}

// MARK: - Unified Roulette Wheel
struct UnifiedRouletteWheel: View {
    let numbers: [Int]
    
    var body: some View {
        ZStack {
            // Outer wooden rim with realistic wood grain texture
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "8B5A2B"),
                            Color(hex: "A0522D"),
                            Color(hex: "8B5A2B"),
                            Color(hex: "654321"),
                            Color(hex: "8B5A2B")
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .overlay(
                    // Wood grain texture overlay
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "654321").opacity(0.3),
                                    Color.clear,
                                    Color(hex: "A0522D").opacity(0.4),
                                    Color.clear,
                                    Color(hex: "8B5A2B").opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    // Metallic golden band with realistic shine
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FFD700"),
                                    Color(hex: "D4AF37"),
                                    Color(hex: "FFD700"),
                                    Color(hex: "B8860B")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 8
                        )
                        .shadow(color: Color(hex: "B8860B").opacity(0.6), radius: 2, x: 1, y: 1)
                )
            
            // Main wheel with all segments
            Canvas { context, size in
                let center = CGPoint(x: size.width/2, y: size.height/2)
                let radius: CGFloat = min(size.width, size.height) * 0.42 // Slightly larger inner circle
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
                
                // Fill with appropriate color and add depth
                let baseColor = getColorForNumber(number)
                let darkerColor = baseColor.opacity(0.7)
                let lighterColor = baseColor.opacity(1.2)
                
                // Fill with base color
                context.fill(path, with: .color(baseColor))
                
                // Add subtle inner shadow for depth
                var innerPath = Path()
                innerPath.move(to: center)
                innerPath.addArc(
                    center: center,
                    radius: radius * 0.95,
                    startAngle: .degrees(startAngle),
                    endAngle: .degrees(endAngle),
                    clockwise: false
                )
                innerPath.closeSubpath()
                context.fill(innerPath, with: .color(darkerColor.opacity(0.3)))
                
                // Add 3D golden dividers between segments
                let dividerAngle = startAngle + segmentAngle
                let dividerStartRadius = radius * 0.98
                let dividerEndRadius = radius * 1.02
                
                var dividerPath = Path()
                dividerPath.move(to: CGPoint(
                    x: center.x + cos(dividerAngle * .pi / 180) * dividerStartRadius,
                    y: center.y + sin(dividerAngle * .pi / 180) * dividerStartRadius
                ))
                dividerPath.addLine(to: CGPoint(
                    x: center.x + cos(dividerAngle * .pi / 180) * dividerEndRadius,
                    y: center.y + sin(dividerAngle * .pi / 180) * dividerEndRadius
                ))
                
                // Metallic golden divider with shine
                context.stroke(dividerPath, with: .color(Color(hex: "FFD700")), lineWidth: 2.5)
                context.stroke(dividerPath, with: .color(Color(hex: "D4AF37").opacity(0.8)), lineWidth: 1.5)
                
                // Add subtle shadow for 3D effect
                var shadowPath = Path()
                shadowPath.move(to: CGPoint(
                    x: center.x + cos(dividerAngle * .pi / 180) * (dividerStartRadius + 1),
                    y: center.y + sin(dividerAngle * .pi / 180) * (dividerStartRadius + 1)
                ))
                shadowPath.addLine(to: CGPoint(
                    x: center.x + cos(dividerAngle * .pi / 180) * (dividerEndRadius + 1),
                    y: center.y + sin(dividerAngle * .pi / 180) * (dividerEndRadius + 1)
                ))
                context.stroke(shadowPath, with: .color(Color.black.opacity(0.3)), lineWidth: 1.5)
                
                // Add number text - properly centered and oriented toward center
                let textAngle = startAngle + segmentAngle/2
                let textRadius = radius * 0.82 // Moved slightly down (closer to center)
                let textX = center.x + cos(textAngle * .pi / 180) * textRadius
                let textY = center.y + sin(textAngle * .pi / 180) * textRadius
                
                // Calculate optimal font size based on segment size
                let segmentWidth = 2 * .pi * textRadius * CGFloat(segmentAngle / 360.0)
                let fontSize = min(segmentWidth * 0.56, 22) // 80% of previous size (0.7 * 0.8 = 0.56, 28 * 0.8 = 22.4)
                
                // Create rotated text that points toward center
                let text = Text(displayNumber(number))
                    .font(.system(size: fontSize, weight: .bold))
                    .foregroundColor(.white)
                
                // Calculate the rotation angle so text base points toward center
                // The text needs to be rotated so its base points toward the center
                let textRotationAngle = textAngle + 90 // +90 to make base point toward center
                
                // For SwiftUI Canvas, we need to use the context's transform property
                let transform = CGAffineTransform(translationX: textX, y: textY)
                    .rotated(by: textRotationAngle * .pi / 180)
                context.transform = transform
                context.draw(text, at: .zero)
                // Reset transform to avoid affecting other elements
                context.transform = .identity
            }
            
            // Add outer rim stroke for clean edge with realistic metallic appearance
            let outerPath = Path { path in
                path.addEllipse(in: CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                ))
            }
            
            // Main metallic stroke
            context.stroke(outerPath, with: .color(Color(hex: "D4AF37")), lineWidth: 2)
            
            // Inner highlight for 3D effect
            let innerPath = Path { path in
                path.addEllipse(in: CGRect(
                    x: center.x - radius + 1,
                    y: center.y - radius + 1,
                    width: radius * 2 - 2,
                    height: radius * 2 - 2
                ))
            }
            context.stroke(innerPath, with: .color(Color(hex: "FFD700").opacity(0.6)), lineWidth: 1)
        }
        .frame(width: 360, height: 360) // Proper canvas size
        }
        .frame(width: 360, height: 360) // Overall frame matches container
    }
    
    private func displayNumber(_ number: Int) -> String {
        // Simple display - show the actual number from wheelNumbers array
        // No mapping - what you see is what you get
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
