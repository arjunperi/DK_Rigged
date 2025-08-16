import SwiftUI

struct CasinoView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedGame: String = "Roulette"
    
    let casinoGames = ["Roulette", "Slots", "Blackjack", "Poker"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Game selection tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(casinoGames, id: \.self) { game in
                            GameTabButton(
                                title: game,
                                isSelected: selectedGame == game
                            ) {
                                selectedGame = game
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Game content
                if selectedGame == "Roulette" {
                    RouletteGameView()
                } else {
                    ComingSoonView(gameName: selectedGame)
                }
            }
            .navigationTitle("Casino")
        }
    }
}

struct GameTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RouletteGameView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedBetType: RouletteBetType?
    @State private var betAmount: String = ""
    @State private var showingRiggedControls = false
    @State private var riggedNumber: String = ""
    @State private var selectedRiggedColor: RouletteColor? = nil
    @State private var showingResult = false
    @State private var lastResult: RouletteResult? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Roulette wheel display
                RouletteWheelView()
                
                // Betting options
                VStack(alignment: .leading, spacing: 16) {
                    Text("Place Your Bets")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    RouletteBettingOptionsView(
                        selectedBetType: $selectedBetType,
                        betAmount: $betAmount
                    )
                    
                    // Place bet button
                    Button(action: placeBet) {
                        Text("Place Bet")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedBetType != nil && !betAmount.isEmpty ? Color.blue : Color.gray)
                            )
                    }
                    .disabled(selectedBetType == nil || betAmount.isEmpty)
                    .padding(.top)
                }
                .padding()
                
                // Spin button
                Button(action: spinWheel) {
                    Text("SPIN!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red)
                        )
                }
                .padding(.horizontal)
                
                // Current result display
                if showingResult, let result = lastResult {
                    VStack(spacing: 16) {
                        Text("🎉 SPIN RESULT! 🎉")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 20) {
                            // Number display
                            VStack(spacing: 4) {
                                Text("\(result.number)")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                Text("Number")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineLimit(1)
                            }
                            .frame(width: 90, height: 90)
                            .background(
                                Circle()
                                    .fill(getColorForRouletteColor(result.color))
                            )
                            
                            // Color display
                            VStack(spacing: 4) {
                                Text(result.color.rawValue.uppercased())
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                Text("Color")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineLimit(1)
                            }
                            .frame(width: 90, height: 90)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(getColorForRouletteColor(result.color))
                            )
                        }
                        
                        // Bet outcomes - only show current spin results
                        let currentSpinBets = appState.bets.filter({ $0.outcome != .pending })
                        if !currentSpinBets.isEmpty {
                            VStack(spacing: 8) {
                                Text("Current Spin Results:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                ForEach(currentSpinBets, id: \.id) { bet in
                                    HStack {
                                        Text(bet.type.displayName)
                                            .foregroundColor(.white)
                                        Spacer()
                                        if bet.outcome == .won {
                                            Text("+$\(bet.payout, specifier: "%.2f")")
                                                .foregroundColor(.green)
                                                .fontWeight(.bold)
                                        } else {
                                            Text("-$\(bet.amount, specifier: "%.2f")")
                                                .foregroundColor(.red)
                                                .fontWeight(.bold)
                                        }
                                    }
                                    .font(.subheadline)
                                }
                            }
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(8)
                        }
                        
                        Button("Continue") {
                            showingResult = false
                            lastResult = nil
                        }
                        .buttonStyle(.borderedProminent)
                        .foregroundColor(.white)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.9))
                    )
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                
                // Rigged controls (hidden)
                Button("Rigged") {
                    showingRiggedControls.toggle()
                }
                .font(.caption)
                .foregroundColor(.gray)
                
                if showingRiggedControls {
                    VStack(spacing: 16) {
                        Text("Rigged Mode Controls")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        // Number input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Number (0-36):")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextField("Enter number (0-36)", text: $riggedNumber)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        
                        // Color selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Color:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            HStack(spacing: 12) {
                                Button(action: { selectedRiggedColor = .red }) {
                                    Text("Red")
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(selectedRiggedColor == .red ? Color.red : Color.red.opacity(0.6))
                                        )
                                }
                                
                                Button(action: { selectedRiggedColor = .black }) {
                                    Text("Black")
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(selectedRiggedColor == .black ? Color.black : Color.black.opacity(0.6))
                                        )
                                }
                                
                                Button(action: { selectedRiggedColor = .green }) {
                                    Text("Green")
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(selectedRiggedColor == .green ? Color.green : Color.green.opacity(0.6))
                                        )
                                }
                            }
                        }
                        
                        // Action buttons
                        HStack(spacing: 12) {
                            Button("Set Number Only") {
                                if let number = Int(riggedNumber), number >= 0 && number <= 36 {
                                    appState.setRiggedNumber(number)
                                    riggedNumber = ""
                                    showingRiggedControls = false
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(riggedNumber.isEmpty)
                            
                            Button("Set Color Only") {
                                if let color = selectedRiggedColor {
                                    appState.setRiggedColor(color)
                                    selectedRiggedColor = nil
                                    showingRiggedControls = false
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(selectedRiggedColor == nil)
                            
                            Button("Set Both") {
                                if let number = Int(riggedNumber), number >= 0 && number <= 36,
                                   let color = selectedRiggedColor {
                                    appState.setRiggedNumberAndColor(number, color)
                                    riggedNumber = ""
                                    selectedRiggedColor = nil
                                    showingRiggedControls = false
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(riggedNumber.isEmpty || selectedRiggedColor == nil)
                        }
                        
                        Button("Clear All") {
                            appState.clearRiggedMode()
                            riggedNumber = ""
                            selectedRiggedColor = nil
                            showingRiggedControls = false
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Game history
                if !appState.gameHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Games")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(appState.gameHistory.prefix(5)) { game in
                            GameHistoryRow(game: game)
                        }
                    }
                }
            }
        }
    }
    
    private func placeBet() {
        guard let betType = selectedBetType,
              let amount = Double(betAmount),
              amount > 0,
              amount <= appState.currentUser.balance else { return }
        
        let betTypeWrapper = BetType.roulette(betType)
        appState.placeRouletteBet(betType: betTypeWrapper, amount: amount)
        
        // Reset form
        selectedBetType = nil
        betAmount = ""
    }
    
    private func spinWheel() {
        // Clear previous bet results by resetting all bets to pending
        appState.clearBetResults()
        
        let result = appState.spinRouletteAndRecord()
        lastResult = result
        showingResult = true
    }
    
    private func getColorForRouletteColor(_ color: RouletteColor) -> Color {
        switch color {
        case .red:
            return .red
        case .black:
            return .black
        case .green:
            return .green
        }
    }
}

struct RouletteWheelView: View {
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.red, .black, .green],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: 200, height: 200)
                
                Text("🎰")
                    .font(.system(size: 60))
            }
            
            Text("Roulette Wheel")
                .font(.headline)
                .padding(.top)
        }
        .padding()
    }
}

struct RouletteBettingOptionsView: View {
    @Binding var selectedBetType: RouletteBetType?
    @Binding var betAmount: String
    
    var body: some View {
        VStack(spacing: 12) {
            // Bet type selection
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(RouletteBetType.allRouletteTypes, id: \.self) { betType in
                    BetTypeButton(
                        betType: betType,
                        isSelected: selectedBetType == betType
                    ) {
                        selectedBetType = betType
                    }
                }
            }
            
            // Bet amount input
            VStack(alignment: .leading, spacing: 8) {
                Text("Bet Amount")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Enter amount", text: $betAmount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
            }
        }
    }
}

struct BetTypeButton: View {
    let betType: RouletteBetType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(betType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                
                Text("\(betType.payoutMultiplier, specifier: "%.0f")x")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GameHistoryRow: View {
    let game: RouletteGame
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Winning Number: \(game.winningNumber ?? 0)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Bets: \(game.bets.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(game.timestamp, style: .time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

struct ComingSoonView: View {
    let gameName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("\(gameName) Coming Soon!")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("This exciting casino game is currently under development.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
} 