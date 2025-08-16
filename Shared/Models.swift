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
            return "Number \(number)"
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
        .singleNumber(0), .singleNumber(1), .singleNumber(2), .singleNumber(3), .singleNumber(4), .singleNumber(5), .singleNumber(6), .singleNumber(7), .singleNumber(8), .singleNumber(9),
        .singleNumber(10), .singleNumber(11), .singleNumber(12), .singleNumber(13), .singleNumber(14), .singleNumber(15), .singleNumber(16), .singleNumber(17), .singleNumber(18), .singleNumber(19),
        .singleNumber(20), .singleNumber(21), .singleNumber(22), .singleNumber(23), .singleNumber(24), .singleNumber(25), .singleNumber(26), .singleNumber(27), .singleNumber(28), .singleNumber(29),
        .singleNumber(30), .singleNumber(31), .singleNumber(32), .singleNumber(33), .singleNumber(34), .singleNumber(35), .singleNumber(36),
        .red, .black, .even, .odd, .low, .high,
        .dozen1, .dozen2, .dozen3,
        .column1, .column2, .column3
    ]
    
    var payoutMultiplier: Double {
        switch self {
        case .singleNumber:
            return 35.0
        case .red, .black, .even, .odd, .low, .high:
            return 2.0
        case .dozen1, .dozen2, .dozen3:
            return 3.0
        case .column1, .column2, .column3:
            return 3.0
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

 