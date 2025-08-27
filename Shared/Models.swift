import Foundation
import SwiftUI

// MARK: - User Model
struct User: Identifiable, Codable {
    var id = UUID()
    var username: String
    var balance: Double
    var totalWagered: Double
    var totalWon: Double
    var totalLost: Double
    
    init(username: String, balance: Double = 1000.0) {
        self.username = username
        self.balance = balance
        self.totalWagered = 0.0
        self.totalWon = 0.0
        self.totalLost = 0.0
    }
}

// MARK: - Bet Model
struct Bet: Identifiable, Codable {
    var id = UUID()
    let userId: UUID
    let amount: Double
    let type: BetType
    let timestamp: Date
    var outcome: BetOutcome
    var payout: Double
    
    init(userId: UUID, amount: Double, type: BetType) {
        self.userId = userId
        self.amount = amount
        self.type = type
        self.timestamp = Date()
        self.outcome = .pending
        self.payout = 0.0
    }
}

// MARK: - Bet Types
enum BetType: Codable {
    case roulette(RouletteBetType)
    case sports(SportsBetType)
    
    var displayName: String {
        switch self {
        case .roulette(let rouletteType):
            return rouletteType.displayName
        case .sports(let sportsType):
            switch sportsType {
            case .moneyline(let team):
                return "\(team) Moneyline"
            case .spread(let team, let points):
                return "\(team) Spread (\(points > 0 ? "+" : "")\(points))"
            case .overUnder(let points, let isOver):
                return "\(isOver ? "Over" : "Under") \(points)"
            }
        }
    }
}

enum RouletteBetType: Codable, Hashable {
    case singleNumber(Int)
    case split([Int]) // Two adjacent numbers
    case street([Int]) // Three numbers in a row
    case corner([Int]) // Four numbers in a square
    case fiveNumber // 0, 00, 1, 2, 3 (American roulette only)
    case line([Int]) // Two rows of three numbers
    case red
    case black
    case even
    case odd
    case low
    case high
    case dozen1
    case dozen2
    case dozen3
    case column1
    case column2
    case column3
    
    var displayName: String {
        switch self {
        case .singleNumber(let number):
            return number == 37 ? "00" : "Number \(number)"
        case .split(let numbers):
            return "Split \(numbers.map { $0 == 37 ? "00" : "\($0)" }.joined(separator:", "))"
        case .street(let numbers):
            return "Street \(numbers.map { $0 == 37 ? "00" : "\($0)" }.joined(separator:", "))"
        case .corner(let numbers):
            return "Corner \(numbers.map { $0 == 37 ? "00" : "\($0)" }.joined(separator:", "))"
        case .fiveNumber:
            return "Five Number (0,00,1,2,3)"
        case .line(let numbers):
            return "Line \(numbers.map { $0 == 37 ? "00" : "\($0)" }.joined(separator:", "))"
        case .red:
            return "Red"
        case .black:
            return "Black"
        case .even:
            return "Even"
        case .odd:
            return "Odd"
        case .low:
            return "1-18"
        case .high:
            return "19-36"
        case .dozen1:
            return "1st Dozen"
        case .dozen2:
            return "2nd Dozen"
        case .dozen3:
            return "3rd Dozen"
        case .column1:
            return "1st Column"
        case .column2:
            return "2nd Column"
        case .column3:
            return "3rd Column"
        }
    }
    
    static let allRouletteTypes: [RouletteBetType] = [
        .singleNumber(0), .singleNumber(37), // 0 and 00
        .singleNumber(1), .singleNumber(2), .singleNumber(3), .singleNumber(4), .singleNumber(5), .singleNumber(6), .singleNumber(7), .singleNumber(8), .singleNumber(9),
        .singleNumber(10), .singleNumber(11), .singleNumber(12), .singleNumber(13), .singleNumber(14), .singleNumber(15), .singleNumber(16), .singleNumber(17), .singleNumber(18), .singleNumber(19),
        .singleNumber(20), .singleNumber(21), .singleNumber(22), .singleNumber(23), .singleNumber(24), .singleNumber(25), .singleNumber(26), .singleNumber(27), .singleNumber(28), .singleNumber(29),
        .singleNumber(30), .singleNumber(31), .singleNumber(32), .singleNumber(33), .singleNumber(34), .singleNumber(35), .singleNumber(36),
        .fiveNumber, // American roulette special bet
        .red, .black, .even, .odd, .low, .high,
        .dozen1, .dozen2, .dozen3,
        .column1, .column2, .column3
    ]
    
    var payoutMultiplier: Double {
        switch self {
        case .singleNumber:
            return 36.0 // 35:1 means you get 35 + your original bet = 36 total
        case .split:
            return 18.0 // 17:1 payout
        case .street:
            return 12.0 // 11:1 payout
        case .corner:
            return 9.0 // 8:1 payout
        case .fiveNumber:
            return 7.0 // 6:1 payout
        case .line:
            return 6.0 // 5:1 payout
        case .red, .black, .even, .odd, .low, .high:
            return 2.0 // 1:1 means you get 1 + your original bet = 2 total
        case .dozen1, .dozen2, .dozen3:
            return 3.0 // 2:1 payout
        case .column1, .column2, .column3:
            return 3.0 // 2:1 payout
        }
    }
    
    // Check if this bet type wins for a given result number
    func isWinningBet(for resultNumber: Int) -> Bool {
        switch self {
        case .singleNumber(let number):
            return number == resultNumber
        case .split(let numbers):
            return numbers.contains(resultNumber)
        case .street(let numbers):
            return numbers.contains(resultNumber)
        case .corner(let numbers):
            return numbers.contains(resultNumber)
        case .fiveNumber:
            return [0, 37, 1, 2, 3].contains(resultNumber)
        case .line(let numbers):
            return numbers.contains(resultNumber)
        case .red:
            return [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36].contains(resultNumber)
        case .black:
            return [2, 4, 6, 8, 10, 11, 13, 15, 17, 20, 22, 24, 26, 28, 29, 31, 33, 35].contains(resultNumber)
        case .even:
            return resultNumber != 0 && resultNumber != 37 && resultNumber % 2 == 0
        case .odd:
            return resultNumber != 0 && resultNumber != 37 && resultNumber % 2 == 1
        case .low:
            return resultNumber >= 1 && resultNumber <= 18
        case .high:
            return resultNumber >= 19 && resultNumber <= 36
        case .dozen1:
            return resultNumber >= 1 && resultNumber <= 12
        case .dozen2:
            return resultNumber >= 13 && resultNumber <= 24
        case .dozen3:
            return resultNumber >= 25 && resultNumber <= 36
        case .column1:
            return resultNumber % 3 == 1 && resultNumber != 37
        case .column2:
            return resultNumber % 3 == 2 && resultNumber != 37
        case .column3:
            return resultNumber % 3 == 0 && resultNumber != 0 && resultNumber != 37
        }
    }
}

enum SportsBetType: Codable {
    case moneyline(team: String)
    case spread(team: String, points: Double)
    case overUnder(points: Double, isOver: Bool)
}

// MARK: - Bet Outcomes
enum BetOutcome: String, Codable, CaseIterable {
    case pending = "Pending"
    case won = "Won"
    case lost = "Lost"
    case cancelled = "Cancelled"
}

// MARK: - Roulette Types
enum RouletteColor: String {
    case red = "Red"
    case black = "Black"
    case green = "Green"
}

struct RouletteResult {
    let number: Int
    let color: RouletteColor
    let timestamp: Date
}

// MARK: - Roulette Game
class RouletteGame: ObservableObject, Identifiable {
    let id = UUID()
    @Published var bets: [RouletteBet] = []
    @Published var winningNumber: Int?
    @Published var isComplete: Bool = false
    let timestamp: Date
    
    init() {
        self.bets = []
        self.winningNumber = nil
        self.isComplete = false
        self.timestamp = Date()
    }
}

struct RouletteBet {
    let betType: BetType
    let amount: Double
    var outcome: BetOutcome = .pending
    var payout: Double = 0.0
}

// MARK: - Sports Models
enum Sport: String, CaseIterable {
    case football = "Football"
    case basketball = "Basketball"
    case baseball = "Baseball"
    case soccer = "Soccer"
    case hockey = "Hockey"
    
    var icon: String {
        switch self {
        case .football:
            return "🏈"
        case .basketball:
            return "🏀"
        case .baseball:
            return "⚾"
        case .soccer:
            return "⚽"
        case .hockey:
            return "🏒"
        }
    }
}

struct SportsEvent: Identifiable {
    let id = UUID()
    let homeTeam: String
    let awayTeam: String
    let sport: Sport
    let startTime: Date
    let homeOdds: Double
    let awayOdds: Double
    let spread: Double?
    
    init(homeTeam: String, awayTeam: String, sport: Sport, startTime: Date, homeOdds: Double = -110, awayOdds: Double = -110, spread: Double? = nil) {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.sport = sport
        self.startTime = startTime
        self.homeOdds = homeOdds
        self.awayOdds = awayOdds
        self.spread = spread
    }
}

 