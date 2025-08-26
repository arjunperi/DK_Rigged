import SwiftUI

struct CasinoView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedGame: String = "Roulette"

    let casinoGames = ["Roulette", "Slots", "Blackjack", "Poker"]

    var body: some View {
        VStack(spacing: 0) {
            // Compact header
            HStack {
                Text("Casino")
                    .font(AppTypography.title2)
                    .foregroundColor(AppTheme.text)

                Spacer()
                


                Text("Balance: $\(Int(appState.currentUser.balance))")
                    .font(AppTypography.headline)
                    .foregroundColor(AppTheme.casinoGold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xs)
            .background(AppTheme.surfaceBackground)

            // Game content - roulette only for now
            if selectedGame == "Roulette" {
                RouletteGameView()
            } else {
                ComingSoonView(gameName: selectedGame)
            }
        }
        .background(AppTheme.velvetGreenGradient)
    }
}

// MARK: - Main Roulette Game View
struct RouletteGameView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingWheelAnimation = false
    @State private var showingResult = false
    @State private var lastResult: RouletteResult? = nil
    @State private var showingRiggedControls = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Main roulette table
                RouletteTableView()

                // Controls section
                RouletteControlsView(onSpin: spinWheel)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppTheme.surfaceBackground)
            }

            // Spinning wheel overlay
            if showingWheelAnimation {
                RouletteWheelView(
                    isSpinning: $showingWheelAnimation,
                    result: $lastResult,
                    onAnimationComplete: {
                        // Clear rigged mode after wheel animation completes
                        appState.clearRiggedModeAfterAnimation()
                    },
                    riggedNumber: appState.selectedRiggedNumber // Pass the rigged number
                )
                .transition(.opacity)
            }

            // Result display overlay
            if showingResult, let result = lastResult {
                ResultOverlayView(result: result, bets: appState.bets, isShowing: $showingResult)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private func spinWheel() {
        // Clear previous results
        appState.clearBetResults()

        // Start wheel animation
        withAnimation(.easeInOut(duration: 0.5)) {
            showingWheelAnimation = true
        }

        // Perform the actual spin after a short delay (but don't process bets yet)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // If we have a rigged number, create a result with that number
            if let riggedNumber = appState.selectedRiggedNumber {
                let riggedColor = appState.getColorForNumber(riggedNumber)
                self.lastResult = RouletteResult(number: riggedNumber, color: riggedColor, timestamp: Date())
            } else {
                // Otherwise, use the normal random spin
                self.lastResult = appState.spinRouletteWithoutProcessingBets()
            }
        }

        // Show result and process bets after wheel animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 9.5) {
            // Process the bets and update balance only now
            if let result = self.lastResult {
                appState.processRouletteBetsForResult(result)
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                self.showingResult = true
            }
        }
    }
}

// MARK: - Roulette Controls
struct RouletteControlsView: View {
    @EnvironmentObject var appState: AppState
    let onSpin: () -> Void

    @State private var showingRiggedControls = false

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            // Top row: Total bet and balance
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Bet")
                        .font(AppTypography.caption)
                        .foregroundColor(AppTheme.secondaryText)
                    Text("$\(Int(totalBetAmount))")
                        .font(AppTypography.headline)
                        .foregroundColor(AppTheme.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Balance")
                        .font(AppTypography.caption)
                        .foregroundColor(AppTheme.secondaryText)
                    Text("$\(Int(appState.currentUser.balance))")
                        .font(AppTypography.headline)
                        .foregroundColor(AppTheme.casinoGold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            }

            // Main control buttons
            HStack(spacing: AppSpacing.sm) {
                // Double bet button
                Button(action: doubleBets) {
                    Text("x2")
                        .font(AppTypography.headline)
                        .foregroundColor(.white)
                        .frame(minWidth: 60, minHeight: 44)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .fill(totalBetAmount > 0 ? AppTheme.primary : Color.gray)
                        )
                }
                .disabled(totalBetAmount == 0 || totalBetAmount * 2 > appState.currentUser.balance)

                // Clear bets button
                Button(action: clearAllBets) {
                    Text("CLEAR")
                        .font(AppTypography.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(minWidth: 60, minHeight: 44)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .fill(totalBetAmount > 0 ? AppTheme.casinoRed : Color.gray)
                        )
                }
                .disabled(totalBetAmount == 0)

                // Spin button
                Button(action: onSpin) {
                    Text("SPIN")
                        .font(AppTypography.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .fill(
                                    totalBetAmount > 0 ?
                                    AppTheme.casinoGold : Color.gray
                                )
                        )
                }
                .disabled(totalBetAmount == 0)
            }

            // Hidden rigged controls toggle (discrete arrow)
            Button(action: { showingRiggedControls.toggle() }) {
                Image(systemName: showingRiggedControls ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.secondaryText.opacity(0.6))
            }

            // Rigged controls (collapsible)
            if showingRiggedControls {
                RiggedControlsView()
                    .transition(.slide)
            }
        }
    }

    private var totalBetAmount: Double {
        return appState.bets
            .filter { bet in
                if case .roulette(_) = bet.type {
                    return bet.outcome == .pending
                }
                return false
            }
            .reduce(0) { $0 + $1.amount }
    }

    private func doubleBets() {
        let currentBets = appState.bets.filter { bet in
            if case .roulette(_) = bet.type {
                return bet.outcome == .pending
            }
            return false
        }

        for bet in currentBets {
            if appState.currentUser.balance >= bet.amount {
                appState.placeRouletteBet(betType: bet.type, amount: bet.amount)
            }
        }
    }

    private func clearAllBets() {
        // Return bet amounts to balance
        let pendingBets = appState.bets.filter { bet in
            if case .roulette(_) = bet.type {
                return bet.outcome == .pending
            }
            return false
        }

        let totalRefund = pendingBets.reduce(0) { $0 + $1.amount }
        appState.currentUser.balance += totalRefund

        // Remove pending bets
        appState.bets.removeAll { bet in
            if case .roulette(_) = bet.type {
                return bet.outcome == .pending
            }
            return false
        }

        // Clear visual results
        appState.clearBetResults()
    }
}

// MARK: - Rigged Controls
struct RiggedControlsView: View {
    @EnvironmentObject var appState: AppState
    @State private var riggedNumber: String = ""
    @State private var selectedRiggedColor: RouletteColor? = nil

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.sm) {
                // Rigged number input
                VStack(alignment: .leading, spacing: 4) {
                    Text("Number")
                        .font(AppTypography.caption2)
                        .foregroundColor(AppTheme.secondaryText)

                    TextField("0-36", text: $riggedNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 60)
                }

                // Rigged color selection
                VStack(alignment: .leading, spacing: 4) {
                    Text("Color")
                        .font(AppTypography.caption2)
                        .foregroundColor(AppTheme.secondaryText)

                    HStack(spacing: 4) {
                        ForEach([RouletteColor.red, RouletteColor.black], id: \.self) { color in
                            Button(action: { selectedRiggedColor = color }) {
                                Circle()
                                    .fill(getColorForRouletteColor(color))
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                selectedRiggedColor == color ? AppTheme.casinoGold : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            }
                        }
                    }
                }

                Spacer()

                // Set/Clear buttons
                VStack(spacing: 4) {
                    Button("Set") {
                        setRiggedMode()
                    }
                    .buttonStyle(CasinoButtonStyle(isSelected: false))
                    .disabled(riggedNumber.isEmpty && selectedRiggedColor == nil)

                    Button("Clear") {
                        clearRiggedMode()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }

            // Current rigged settings display
            if appState.isRiggedMode {
                HStack {
                    Text("Active:")
                        .font(AppTypography.caption2)
                        .foregroundColor(AppTheme.secondaryText)

                    if let riggedNum = appState.selectedRiggedNumber {
                        Text("Number \(riggedNum)")
                            .font(AppTypography.caption2)
                            .foregroundColor(AppTheme.casinoGold)
                    }

                    if let riggedCol = appState.selectedRiggedColor {
                        Text(riggedCol.rawValue)
                            .font(AppTypography.caption2)
                            .foregroundColor(getColorForRouletteColor(riggedCol))
                    }

                    Spacer()
                }
            }
        }
        .padding(AppSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                .fill(AppTheme.surfaceBackground.opacity(0.5))
        )
    }

    private func setRiggedMode() {
        if let number = Int(riggedNumber), number >= 0 && number <= 36 {
            if let color = selectedRiggedColor {
                appState.setRiggedNumberAndColor(number, color)
            } else {
                appState.setRiggedNumber(number)
            }
        } else if let color = selectedRiggedColor {
            appState.setRiggedColor(color)
        }
    }

    private func clearRiggedMode() {
        appState.clearRiggedMode()
        riggedNumber = ""
        selectedRiggedColor = nil
    }

    private func getColorForRouletteColor(_ color: RouletteColor) -> Color {
        switch color {
        case .red: return AppTheme.casinoRed
        case .black: return AppTheme.casinoBlack
        case .green: return AppTheme.casinoGreen
        }
    }
}

// MARK: - Result Overlay
struct ResultOverlayView: View {
    let result: RouletteResult
    let bets: [Bet]
    @Binding var isShowing: Bool
    
    private var totalWinnings: Double {
        bets.filter { $0.outcome == .won }.reduce(0) { $0 + $1.payout }
    }
    
    private var hasWinningBets: Bool {
        bets.contains { $0.outcome == .won }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isShowing = false
                    }
                }

            VStack(spacing: AppSpacing.md) {
                Text("Result")
                    .font(AppTypography.title)
                    .foregroundColor(AppTheme.text)

                // Winning number display
                Text("\(result.number)")
                    .font(.system(size: 72, weight: .bold))
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

                Text(result.color.rawValue.uppercased())
                    .font(AppTypography.headline)
                    .foregroundColor(getColorForNumber(result.number))
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                            .fill(getColorForNumber(result.number).opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                    .stroke(getColorForNumber(result.number), lineWidth: 2)
                            )
                    )
                
                // Winner display
                if hasWinningBets {
                    VStack(spacing: AppSpacing.xs) {
                        Text("🎉 WINNER! 🎉")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.casinoGold)
                            .padding(.top, AppSpacing.sm)
                        
                        Text("You won:")
                            .font(AppTypography.body)
                            .foregroundColor(AppTheme.secondaryText)
                        
                        Text("$\(Int(totalWinnings))")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(AppTheme.casinoGold)
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, AppSpacing.xs)
                            .background(
                                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                    .fill(AppTheme.casinoGold.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                            .stroke(AppTheme.casinoGold, lineWidth: 2)
                                    )
                            )
                    }
                } else {
                    VStack(spacing: AppSpacing.xs) {
                        Text("Better luck next time!")
                            .font(AppTypography.headline)
                            .foregroundColor(AppTheme.secondaryText)
                            .padding(.top, AppSpacing.sm)
                        
                        let totalWagered = bets.reduce(0) { $0 + $1.amount }
                        if totalWagered > 0 {
                            Text("You wagered: $\(Int(totalWagered))")
                                .font(AppTypography.body)
                                .foregroundColor(AppTheme.secondaryText)
                        }
                    }
                }

                Button("Continue") {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isShowing = false
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(AppSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                    .fill(AppTheme.surfaceBackground)
            )
            .padding(AppSpacing.xl)
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

// MARK: - Coming Soon View
struct ComingSoonView: View {
    let gameName: String

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "gamecontroller")
                .font(.system(size: 64))
                .foregroundColor(AppTheme.secondaryText)

            Text("\(gameName)")
                .font(AppTypography.title)
                .foregroundColor(AppTheme.text)

            Text("Coming Soon")
                .font(AppTypography.headline)
                .foregroundColor(AppTheme.secondaryText)

            Text("This game is currently under development. Stay tuned for updates!")
                .font(AppTypography.body)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
    }
}

// MARK: - Preview Provider
struct CasinoView_Previews: PreviewProvider {
    static var previews: some View {
        CasinoView()
            .environmentObject(AppState())
    }
}
