import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var currentUser: User
    @Published var bets: [Bet] = []
    @Published var rouletteHistory: [RouletteResult] = []
    @Published var gameHistory: [RouletteGame] = []
    @Published var upcomingEvents: [SportsEvent] = []
    @Published var selectedRiggedNumber: Int? = nil
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
            SportsEvent(homeTeam: "Lakers", awayTeam: "Warriors", sport: .basketball, startTime: Date().addingTimeInterval(7200)),
            SportsEvent(homeTeam: "Yankees", awayTeam: "Red Sox", sport: .baseball, startTime: Date().addingTimeInterval(10800))
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
        
        // Add some sample bets
        let sampleBet1 = Bet(userId: currentUser.id, amount: 50.0, type: .roulette(.singleNumber(7)))
        let sampleBet2 = Bet(userId: currentUser.id, amount: 25.0, type: .roulette(.red))
        
        bets = [sampleBet1, sampleBet2]
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
        
        if isRiggedMode, let riggedNumber = selectedRiggedNumber {
            // Use the rigged number
            number = riggedNumber
            color = getColorForNumber(riggedNumber)
            // Reset rigged mode after use
            isRiggedMode = false
            selectedRiggedNumber = nil
        } else {
            // Random spin
            number = Int.random(in: 0...36)
            color = getColorForNumber(number)
        }
        
        let result = RouletteResult(number: number, color: color, timestamp: Date())
        rouletteHistory.append(result)
        
        // Process any pending bets
        processRouletteBets(result)
        
        return result
    }
    
    private func getColorForNumber(_ number: Int) -> RouletteColor {
        if number == 0 {
            return .green
        }
        
        let redNumbers = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]
        return redNumbers.contains(number) ? .red : .black
    }
    
    private func processRouletteBets(_ result: RouletteResult) {
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
                    return (.won, bet.amount * 35.0)
                }
            case .red:
                if result.color == .red {
                    return (.won, bet.amount * 2.0)
                }
            case .black:
                if result.color == .black {
                    return (.won, bet.amount * 2.0)
                }
            case .even:
                if result.number != 0 && result.number % 2 == 0 {
                    return (.won, bet.amount * 2.0)
                }
            case .odd:
                if result.number != 0 && result.number % 2 == 1 {
                    return (.won, bet.amount * 2.0)
                }
            case .low:
                if result.number >= 1 && result.number <= 18 {
                    return (.won, bet.amount * 2.0)
                }
            case .high:
                if result.number >= 19 && result.number <= 36 {
                    return (.won, bet.amount * 2.0)
                }
            case .dozen1:
                if result.number >= 1 && result.number <= 12 {
                    return (.won, bet.amount * 3.0)
                }
            case .dozen2:
                if result.number >= 13 && result.number <= 24 {
                    return (.won, bet.amount * 3.0)
                }
            case .dozen3:
                if result.number >= 25 && result.number <= 36 {
                    return (.won, bet.amount * 3.0)
                }
            case .column1:
                if result.number % 3 == 1 {
                    return (.won, bet.amount * 3.0)
                }
            case .column2:
                if result.number % 3 == 2 {
                    return (.won, bet.amount * 3.0)
                }
            case .column3:
                if result.number % 3 == 0 && result.number != 0 {
                    return (.won, bet.amount * 3.0)
                }
            }
        case .sports:
            // Sports betting logic would go here
            return (.lost, 0.0)
        }
        
        return (.lost, 0.0)
    }
    
    // MARK: - Rigged Mode
    func setRiggedNumber(_ number: Int) {
        selectedRiggedNumber = number
        isRiggedMode = true
    }
    
    func clearRiggedMode() {
        selectedRiggedNumber = nil
        isRiggedMode = false
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
    
    func spinRouletteAndRecord() {
        let result = spinRoulette()
        
        // Create a new roulette game for history
        let game = RouletteGame()
        game.winningNumber = result.number
        game.isComplete = true
        gameHistory.append(game)
        
        // Reset rigged mode
        if isRiggedMode {
            isRiggedMode = false
            selectedRiggedNumber = nil
        }
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