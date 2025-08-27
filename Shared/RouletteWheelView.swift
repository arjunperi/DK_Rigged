import SwiftUI

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
    
    // Roulette numbers in correct American roulette order (clockwise from 0)
    // Fixed to match the actual visual layout of the wheel
    // Updated to match wheelSequence exactly - both arrays now use the same number sequence
    // This ensures wheel rotation and ball landing use identical coordinates
    private let wheelNumbers = [0, 28, 9, 26, 30, 11, 7, 20, 32, 17, 5, 22, 34, 15, 3, 24, 36, 13, 1, 37, 27, 10, 25, 29, 12, 8, 19, 31, 18, 6, 21, 33, 16, 4, 23, 35, 14, 2]
    
    var body: some View {
        ZStack {
            // Dark overlay background
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
                        ZStack {
                // Wheel container - positioned in center of screen
                ZStack {
                    // Single unified roulette wheel
                    UnifiedRouletteWheel(numbers: wheelNumbers)
                        .frame(width: 360, height: 360)
                        .rotationEffect(.degrees(wheelRotation))
                        .animation(wheelAnimationComplete ? nil : .linear(duration: 6.0).repeatCount(1, autoreverses: false), value: wheelRotation)
                    
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
        
        // Calculate final wheel position based on the result
        let finalWheelRotation: Double
        let targetNumber: Int
        
        if let riggedNumber = riggedNumber {
            // Use the rigged number for both wheel and ball
            targetNumber = riggedNumber
        } else if let result = result {
            // Use the result number if no rigged number
            targetNumber = result.number
        } else {
            // Fallback if no result
            targetNumber = 0
        }
        
        // REMOVED: Old wheel rotation logic - replaced with new American wheel system below
        
        // NEW LOGIC: American Roulette Wheel (38 slots including "0" and "00")
        // Define the American wheel sequence in exact clockwise order
        let wheelSequence = ["0", "28", "9", "26", "30", "11", "7", "20", "32", "17",
                             "5", "22", "34", "15", "3", "24", "36", "13", "1", "00",
                             "27", "10", "25", "29", "12", "8", "19", "31", "18", "6",
                             "21", "33", "16", "4", "23", "35", "14", "2"]
        
        // Each slot has equal angle size (American = 38 slots)
        let pocketAngle = 360.0 / Double(wheelSequence.count) // 360° / 38 = 9.47°
        
        // Convert target number to string for comparison (handles both "00" and regular numbers)
        let targetString = String(targetNumber)
        
        // Find the target number's index in the wheel array
        guard let targetIndex = wheelSequence.firstIndex(of: targetString) else {
            print("❌ Target number \(targetString) not found in American wheel sequence")
            return
        }
        
        // Compute the target's angle position
        let targetAngle = Double(targetIndex) * pocketAngle
        
        // Keep track of wheel's current rotation and normalize to 0-360
        let currentRotation = wheelRotation.truncatingRemainder(dividingBy: 360)
        
        // NATURAL WHEEL SPIN: Let wheel spin to random position
        // No artificial targeting - wheel spins naturally
        
        // Add several full spins to make it look real (8-16 full rotations)
        let extraSpins = Double.random(in: 8...16) * 360
        
        // Final rotation = current + extra spins (natural random position)
        let calculatedWheelRotation = currentRotation + extraSpins
        
        print("🎯 NATURAL WHEEL SPIN:")
        print("   • Target Number: \(targetNumber) at Index: \(targetIndex)")
        print("   • Pocket Angle: \(pocketAngle)°")
        print("   • Target Angle: \(targetAngle)°")
        print("   • Current Rotation: \(currentRotation)°")
        print("   • Extra Spins: \(extraSpins)°")
        print("   • Wheel Final Position: \(calculatedWheelRotation)° (random)")
        
        // Update wheel rotation to final position
        wheelRotation = calculatedWheelRotation
        
        // Set wheel animation complete after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            wheelAnimationComplete = true
        }
        
        // SYNCHRONIZED BALL & WHEEL: Ball rotates with the wheel
        // No complex calculations needed - ball and wheel move together!
        
        if let riggedNumber = riggedNumber {
            // RIGGED MODE: Ball lands on specific target number
            // Find where the target number is positioned on the wheel
            let targetPhysicalIndex = wheelNumbers.firstIndex(of: targetNumber) ?? 0
            let targetPhysicalAngle = Double(targetPhysicalIndex) * (360.0 / Double(wheelNumbers.count))
            
            // Ball rotates with wheel + lands on target position
            let ballFinalRotation = calculatedWheelRotation + targetPhysicalAngle
            
            print("⚽ SYNCHRONIZED BALL & WHEEL (RIGGED):")
            print("   • Target Number: \(targetString)")
            print("   • Target Physical Index: \(targetPhysicalIndex)")
            print("   • Target Physical Angle: \(targetPhysicalAngle)°")
            print("   • Wheel Final Position: \(calculatedWheelRotation)°")
            print("   • Ball Final Rotation: \(ballFinalRotation)°")
            print("   • Ball rotates with wheel and lands on \(targetString)")
            
            ballRotation = ballFinalRotation
        } else {
            // NON-RIGGED MODE: Ball lands randomly
            let randomBallRotation = Double.random(in: 3600...7200) // Spin 10-20 full rotations
            ballRotation = randomBallRotation
        }
        
        // Ball radius animation (moves inward as it slows)
        ballRadius = 85
        
        // Show result after ALL animations complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            // All animations are complete - wheel and ball are now still
            showResult = true
            showWheelResults = true // Keep wheel visible
            
            // CALCULATE ACTUAL RESULT based on where ball landed
            let actualLandingIndex = calculateBallLandingIndex()
            
            // Use the same wheel sequence for consistency
            let wheelSequence = wheelNumbers.map { String($0) }
            
            let actualLandingNumberString = wheelSequence[actualLandingIndex]
            let actualLandingNumber = Int(actualLandingNumberString) ?? 0
            let actualLandingColor = getRouletteColorForNumber(actualLandingNumber)
            
            // Update the result to match where ball actually landed
            result = RouletteResult(number: actualLandingNumber, color: actualLandingColor, timestamp: Date())
            
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
    
    private func getAngleForNumber(_ number: Int) -> Double {
        guard let index = wheelNumbers.firstIndex(of: number) else { 
            print("❌ Number \(number) not found in wheel numbers array")
            return 0 
        }
        
        // The wheel starts from the top (-90 degrees) and goes clockwise
        // Each segment is positioned based on its index, starting from the top
        let segmentAngle = 360.0 / Double(wheelNumbers.count)
        let startAngle = Double(index) * segmentAngle - 90 // Start from top (-90 degrees)
        let centerAngle = startAngle + segmentAngle / 2
        
        print("🔢 Number: \(number), Index: \(index)")
        print("📏 Segment Angle: \(segmentAngle)°, Start Angle: \(startAngle)°, Center Angle: \(centerAngle)°")
        
        return centerAngle
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
    
    // Calculate where the ball actually landed based on final rotation
    private func calculateBallLandingIndex() -> Int {
        // DEBUG: Log the current values
        print("🔍 BALL LANDING CALCULATION DEBUG:")
        print("   • Ball Rotation: \(ballRotation)°")
        print("   • Wheel Rotation: \(wheelRotation)°")
        print("   • Ball Size: 12x12 (was 16x16)")
        
        // Use the same array that draws the wheel for consistency
        let wheelSequence = wheelNumbers.map { String($0) }
        
        print("   • Using wheelNumbers array (38 slots) - same as visual wheel")
        print("   • Wheel Sequence: \(wheelSequence)")
        
        // Find the visual landing position by looking at the wheel's final rotation
        let normalizedWheelAngle = wheelRotation.truncatingRemainder(dividingBy: 360)
        let segmentAngle = 360.0 / Double(wheelSequence.count)
        
        // The wheel stops with a specific segment at the top
        let topSegmentIndex = Int(round(normalizedWheelAngle / segmentAngle)) % wheelSequence.count
        let topSegmentNumber = wheelSequence[topSegmentIndex]
        
        print("   • Normalized Wheel Angle: \(normalizedWheelAngle)°")
        print("   • Top Segment Index: \(topSegmentIndex)")
        print("   • Top Segment Number: \(topSegmentNumber)")
        
        // APPROACH G: WHEEL-REFERENCED BALL LANDING
        // Use wheel's top segment as reference point for accurate ball landing
        let wheelTopPosition = wheelRotation.truncatingRemainder(dividingBy: 360)
        let wheelTopIndex = Int(round(wheelTopPosition / segmentAngle)) % wheelSequence.count
        let wheelTopNumber = wheelSequence[wheelTopIndex]
        
        print("   • APPROACH G - WHEEL-REFERENCED LANDING:")
        print("   • Wheel Top Position: \(wheelTopPosition)°")
        print("   • Wheel Top Index: \(wheelTopIndex)")
        print("   • Wheel Top Number: \(wheelTopNumber)")
        
        // Since ball and wheel rotate together, the ball lands on the wheel's top segment
        // This is the most reliable way to determine the result
        let landingNumber = wheelTopNumber
        
        print("   • ✅ WHEEL-REFERENCED: Ball lands on \(landingNumber) - matches wheel top!")
        
        return wheelTopIndex
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
