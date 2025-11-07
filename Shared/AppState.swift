import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var currentUser: User
    @Published var bets: [Bet] = []
    @Published var rouletteHistory: [RouletteResult] = []
    @Published var gameHistory: [RouletteGame] = []
    @Published var upcomingEvents: [SportsEvent] = []
    @Published var selectedRiggedNumber: Int? = nil
    @Published var selectedRiggedColor: RouletteColor? = nil
    @Published var isRiggedMode: Bool = false
    
    init() {
        // Initialize with a default user
        self.currentUser = User(username: "Player", balance: 1000.0)
        
        // Load some sample data
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Load sample sports events
        upcomingEvents = [
            SportsEvent(homeTeam: "Patriots", awayTeam: "Bills", sport: .football, startTime: Date().addingTimeInterval(3600)),
            SportsEvent(homeTeam: "Lakers", awayTeam: "Warriors", sport: .basketball, startTime: Date().addingTimeInterval(7200))
        ]
        
        // Load sample roulette history
        rouletteHistory = [
            RouletteResult(number: 7, color: .red, timestamp: Date().addingTimeInterval(-3600)),
            RouletteResult(number: 23, color: .red, timestamp: Date().addingTimeInterval(-7200)),
            RouletteResult(number: 0, color: .green, timestamp: Date().addingTimeInterval(-10800))
        ]
        
        // Load sample game history
        let game1 = RouletteGame()
        game1.winningNumber = 7
        game1.isComplete = true
        
        let game2 = RouletteGame()
        game2.winningNumber = 23
        game2.isComplete = true
        
        gameHistory = [game1, game2]
        
        // Start with no bets - user will place their own
        bets = []
    }
    

    
    // MARK: - User Management
    func addFunds(_ amount: Double) {
        currentUser.balance += amount
    }
    
    func withdrawFunds(_ amount: Double) {
        if currentUser.balance >= amount {
            currentUser.balance -= amount
        }
    }
    
    // MARK: - Betting
    func placeBet(_ bet: Bet) {
        if currentUser.balance >= bet.amount {
            currentUser.balance -= bet.amount
            currentUser.totalWagered += bet.amount
            bets.append(bet)
        }
    }
    
    func processBetOutcome(_ bet: Bet, outcome: BetOutcome, payout: Double) {
        if let index = bets.firstIndex(where: { $0.id == bet.id }) {
            bets[index].outcome = outcome
            bets[index].payout = payout
            
            if outcome == .won {
                currentUser.balance += payout
                currentUser.totalWon += payout
            } else {
                currentUser.totalLost += bet.amount
            }
        }
    }
    
    // MARK: - Roulette
    func spinRoulette() -> RouletteResult {
        let number: Int
        let color: RouletteColor
        
        if isRiggedMode {
            if let riggedNumber = selectedRiggedNumber {
                // Use the rigged number
                number = riggedNumber
                
                // If color is also rigged, use it; otherwise calculate from number
                if let riggedColor = selectedRiggedColor {
                    color = riggedColor
                } else {
                    color = getColorForNumber(riggedNumber)
                }
            } else if let riggedColor = selectedRiggedColor {
                // Only color is rigged, pick a random number of that color
                number = getRandomNumberForColor(riggedColor)
                color = riggedColor
            } else {
                // Fallback to random
                number = Int.random(in: 0...37) // Include 00 (37) for American roulette
                color = getColorForNumber(number)
            }
            
            // Don't reset rigged mode here - let it persist until after results are shown
            // The rig will be cleared in processRouletteBetsForResult after the user sees the results
        } else {
            // Random spin
            number = Int.random(in: 0...37) // Include 00 (37) for American roulette
            color = getColorForNumber(number)
        }
        
        let result = RouletteResult(number: number, color: color, timestamp: Date())
        rouletteHistory.append(result)
        
        // Don't process bets here - let the caller decide when to process them
        // This prevents double processing and allows for proper timing control
        
        return result
    }
    
    public func getColorForNumber(_ number: Int) -> RouletteColor {
        if number == 0 || number == 37 { // 0 and 00 (37) are green
            return .green
        }
        
        let redNumbers = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]
        return redNumbers.contains(number) ? .red : .black
    }
    
    private func getRandomNumberForColor(_ color: RouletteColor) -> Int {
        switch color {
        case .green:
            let greenNumbers = [0, 37] // 0 and 00
            return greenNumbers.randomElement() ?? 0
        case .red:
            let redNumbers = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]
            return redNumbers.randomElement() ?? 1
        case .black:
            let blackNumbers = [2, 4, 6, 8, 10, 11, 13, 15, 17, 20, 22, 24, 26, 28, 29, 31, 33, 35]
            return blackNumbers.randomElement() ?? 2
        }
    }
    
    func processRouletteBets(_ result: RouletteResult) {
        let pendingBets = bets.filter { $0.outcome == .pending && $0.type.isRoulette }
        
        for bet in pendingBets {
            let (outcome, payout) = calculateRouletteOutcome(bet: bet, result: result)
            processBetOutcome(bet, outcome: outcome, payout: payout)
        }
    }
    
    private func calculateRouletteOutcome(bet: Bet, result: RouletteResult) -> (BetOutcome, Double) {
        switch bet.type {
        case .roulette(let rouletteType):
            switch rouletteType {
            case .singleNumber(let number):
                if result.number == number {
                    // Green numbers (0 and 00) pay 35:1, all others pay 36:1
                    if number == 0 || number == 37 {
                        return (.won, bet.amount * 35.0)
                    } else {
                        return (.won, bet.amount * 36.0)
                    }
                } else {
                    return (.lost, 0.0)
                }
            case .split(let numbers):
                if numbers.contains(result.number) {
                    return (.won, bet.amount * 18.0)
                } else {
                    return (.lost, 0.0)
                }
            case .street(let numbers):
                if numbers.contains(result.number) {
                    return (.won, bet.amount * 12.0)
                } else {
                    return (.lost, 0.0)
                }
            case .corner(let numbers):
                if numbers.contains(result.number) {
                    return (.won, bet.amount * 9.0)
                } else {
                    return (.lost, 0.0)
                }
            case .fiveNumber:
                if [0, 37, 1, 2, 3].contains(result.number) {
                    return (.won, bet.amount * 7.0)
                } else {
                    return (.lost, 0.0)
                }
            case .line(let numbers):
                if numbers.contains(result.number) {
                    return (.won, bet.amount * 6.0)
                } else {
                    return (.lost, 0.0)
                }
            case .red:
                if result.color == .red {
                    return (.won, bet.amount * 2.0)
                } else {
                    return (.lost, 0.0)
                }
            case .black:
                if result.color == .black {
                    return (.won, bet.amount * 2.0)
                } else {
                    return (.lost, 0.0)
                }
            case .even:
                if result.number != 0 && result.number != 37 && result.number % 2 == 0 {
                    return (.won, bet.amount * 2.0)
                } else {
                    return (.lost, 0.0)
                }
            case .odd:
                if result.number != 0 && result.number != 37 && result.number % 2 == 1 {
                    return (.won, bet.amount * 2.0)
                } else {
                    return (.lost, 0.0)
                }
            case .low:
                if result.number >= 1 && result.number <= 18 {
                    return (.won, bet.amount * 2.0)
                } else {
                    return (.lost, 0.0)
                }
            case .high:
                if result.number >= 19 && result.number <= 36 {
                    return (.won, bet.amount * 2.0)
                } else {
                    return (.lost, 0.0)
                }
            case .dozen1:
                if result.number >= 1 && result.number <= 12 {
                    return (.won, bet.amount * 3.0)
                } else {
                    return (.lost, 0.0)
                }
            case .dozen2:
                if result.number >= 13 && result.number <= 24 {
                    return (.won, bet.amount * 3.0)
                } else {
                    return (.lost, 0.0)
                }
            case .dozen3:
                if result.number >= 25 && result.number <= 36 {
                    return (.won, bet.amount * 3.0)
                } else {
                    return (.lost, 0.0)
                }
            case .column1:
                // Column 1: 3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36
                let column1Numbers = [3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36]
                if column1Numbers.contains(result.number) {
                    return (.won, bet.amount * 3.0)
                } else {
                    return (.lost, 0.0)
                }
            case .column2:
                // Column 2: 2, 5, 8, 11, 14, 17, 20, 23, 26, 29, 32, 35
                let column2Numbers = [2, 5, 8, 11, 14, 17, 20, 23, 26, 29, 32, 35]
                if column2Numbers.contains(result.number) {
                    return (.won, bet.amount * 3.0)
                } else {
                    return (.lost, 0.0)
                }
            case .column3:
                // Column 3: 1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34
                let column3Numbers = [1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34]
                if column3Numbers.contains(result.number) {
                    return (.won, bet.amount * 3.0)
                } else {
                    return (.lost, 0.0)
                }
            }
        case .sports:
            // Sports betting logic would go here
            return (.lost, 0.0)
        }
    }
    
    // MARK: - Rigged Mode
    func setRiggedNumber(_ number: Int) {
        selectedRiggedNumber = number
        isRiggedMode = true
    }
    
    func setRiggedColor(_ color: RouletteColor) {
        selectedRiggedColor = color
        isRiggedMode = true
    }
    
    func setRiggedNumberAndColor(_ number: Int, _ color: RouletteColor) {
        selectedRiggedNumber = number
        selectedRiggedColor = color
        isRiggedMode = true
    }
    
    func clearRiggedMode() {
        selectedRiggedNumber = nil
        selectedRiggedColor = nil
        isRiggedMode = false
    }
    
    // MARK: - Rig Status
    func getCurrentRigStatus() -> (color: RouletteColor?, number: Int?) {
        return (selectedRiggedColor, selectedRiggedNumber)
    }
    
    func isRigActive() -> Bool {
        return isRiggedMode
    }
    
    func clearBetResults() {
        // Reset all bets to pending status for a fresh spin
        for i in 0..<bets.count {
            bets[i].outcome = .pending
            bets[i].payout = 0.0
        }
    }
    
    func clearAllBets() {
        // Remove all bets completely for a fresh game
        bets.removeAll()
        
        // Notify observers that bets have been cleared
        objectWillChange.send()
    }
    
    // MARK: - Roulette Game Management
    func placeRouletteBet(betType: BetType, amount: Double) {
        guard amount <= currentUser.balance else { return }
        
        let bet = Bet(userId: currentUser.id, amount: amount, type: betType)
        bets.append(bet)
        
        // Deduct amount from user balance
        currentUser.balance -= amount
        currentUser.totalWagered += amount
    }
    
    func undoLastBet() -> Bool {
        // Find the last pending roulette bet
        if let lastBetIndex = bets.lastIndex(where: { bet in
            if case .roulette(_) = bet.type {
                return bet.outcome == .pending
            }
            return false
        }) {
            let lastBet = bets[lastBetIndex]
            
            // Return the bet amount to balance
            currentUser.balance += lastBet.amount
            currentUser.totalWagered -= lastBet.amount
            
            // Remove the bet
            bets.remove(at: lastBetIndex)
            
            return true
        }
        return false
    }
    
    func spinRouletteAndRecord() -> RouletteResult {
        let result = spinRoulette()
        
        // Create a new roulette game for history
        let game = RouletteGame()
        game.winningNumber = result.number
        game.isComplete = true
        gameHistory.append(game)
        
        // Process bets immediately (for backward compatibility)
        processRouletteBets(result)
        
        // Reset rigged mode after processing bets
        if isRiggedMode {
            isRiggedMode = false
            selectedRiggedNumber = nil
            selectedRiggedColor = nil
        }
        
        return result
    }
    
    func spinRouletteWithoutProcessingBets() -> RouletteResult {
        let result = spinRoulette()
        
        // Create a new roulette game for history
        let game = RouletteGame()
        game.winningNumber = result.number
        game.isComplete = true
        gameHistory.append(game)
        
        // Don't reset rigged mode here - let it persist until after results are shown
        // The rig will be cleared in processRouletteBetsForResult after the user sees the results
        
        return result
    }
    
    func processRouletteBetsForResult(_ result: RouletteResult) {
        // Process the bets and update balance
        processRouletteBets(result)
        
        // Don't clear bets here - let the CasinoView show results first
        // Bets will be cleared after the user dismisses the results screen
        
        // Don't clear rigged mode here - it will be cleared after the wheel animation completes
        // This ensures the rig stays active for the entire wheel animation
    }
    
    func clearRiggedModeAfterAnimation() {
        // Clear the rigged mode after the wheel animation is complete
        if isRiggedMode {
            isRiggedMode = false
            selectedRiggedNumber = nil
            selectedRiggedColor = nil
        }
    }
    
    func clearBetsAfterResults() {
        // Clear all bets after the results have been shown
        clearAllBets()
    }
}

// MARK: - Extensions
extension BetType {
    var isRoulette: Bool {
        switch self {
        case .roulette:
            return true
        default:
            return false
        }
    }
} 
