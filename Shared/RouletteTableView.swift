import SwiftUI

// MARK: - Main Roulette Table View
struct RouletteTableView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedChipValue: Double = 25
    @State private var placedBets: [String: Double] = [:]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: AppSpacing.xxs) {
                    // Chip selector
                    ChipSelectorView(selectedChipValue: $selectedChipValue)
                    
                    // Main roulette table
                    RouletteTable(
                        placedBets: $placedBets,
                        selectedChipValue: $selectedChipValue,
                        cellSize: calculateCellSize(for: geometry.size),
                        narrowCellSize: calculateNarrowCellSize(for: geometry.size)
                    )
                    .padding(.horizontal, 16) // Equal small margins
                    .padding(.vertical, 8)
                }
            }
        }
    }
    
    private func calculateCellSize(for size: CGSize) -> CGSize {
        let tableWidth = size.width - 32 // Small equal margins on left/right
        let tableHeight = size.height - 80 // Reserve space for controls
        
        // DraftKings has 2 narrow columns + 3 wide columns
        let narrowWidth = min(tableWidth / 8, 45) // Narrow columns (left bets + dozens)
        let wideWidth = min(tableWidth / 5, 60)   // Wide columns (numbers)
        let cellHeight = min(tableHeight / 14, 45) // Fit 12 number rows + 2:1 row
        
        return CGSize(width: wideWidth, height: cellHeight)
    }
    
    private func calculateNarrowCellSize(for size: CGSize) -> CGSize {
        let tableWidth = size.width - 32
        let tableHeight = size.height - 80
        
        let narrowWidth = min(tableWidth / 8, 45) // Narrow columns
        let cellHeight = min(tableHeight / 14, 45)
        
        return CGSize(width: narrowWidth, height: cellHeight)
    }
}

// MARK: - Roulette Table Layout
struct RouletteTable: View {
    @EnvironmentObject var appState: AppState
    @Binding var placedBets: [String: Double]
    @Binding var selectedChipValue: Double
    let cellSize: CGSize
    let narrowCellSize: CGSize
    
    var body: some View {
        VStack(spacing: 0) {
            // Layout with zeros positioned above number columns only
            HStack(spacing: 0) {
                // Empty space above left columns (LeftSideBets + DozenBets)
                HStack(spacing: 0) {
                    Spacer().frame(width: narrowCellSize.width) // Left side bets space
                    Spacer().frame(width: narrowCellSize.width) // Dozen bets space
                }
                
                // Green zeros above the 3 number columns only
                ZeroSection(placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
            }
            
            // Main betting rectangle - no extra spacing
            // Main number grid (now includes dozen bets as vertical columns)
            NumberGrid(placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize, narrowCellSize: narrowCellSize)
            .background(AppTheme.casinoBlue)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.small)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
        }
    }
}

// MARK: - Zero Section (0, 00)
struct ZeroSection: View {
    @Binding var placedBets: [String: Double]
    @Binding var selectedChipValue: Double
    let cellSize: CGSize
    
    var body: some View {
        HStack(spacing: 0) {
            // Single Zero (0)
            BettingArea(
                title: "0",
                backgroundColor: AppTheme.casinoGreen,
                textColor: .white,
                betKey: "zero",
                placedBets: $placedBets,
                selectedChipValue: $selectedChipValue,
                cellSize: cellSize
            )
            .frame(maxWidth: .infinity)
            .frame(height: cellSize.height * 0.8)
            
            // Double Zero (00) - American Roulette
            BettingArea(
                title: "00",
                backgroundColor: AppTheme.casinoGreen,
                textColor: .white,
                betKey: "double_zero",
                placedBets: $placedBets,
                selectedChipValue: $selectedChipValue,
                cellSize: cellSize
            )
            .frame(maxWidth: .infinity)
            .frame(height: cellSize.height * 0.8)
        }
    }
}

// MARK: - Main Number Grid
struct NumberGrid: View {
    @Binding var placedBets: [String: Double]
    @Binding var selectedChipValue: Double
    let cellSize: CGSize
    let narrowCellSize: CGSize
    
    // Numbers arranged in DraftKings 3-column layout (standard roulette table)
    private let numberRows = [
        [3, 2, 1],   // Row 1 (top)
        [6, 5, 4],   // Row 2  
        [9, 8, 7],   // Row 3
        [12, 11, 10], // Row 4
        [15, 14, 13], // Row 5
        [18, 17, 16], // Row 6
        [21, 20, 19], // Row 7
        [24, 23, 22], // Row 8
        [27, 26, 25], // Row 9
        [30, 29, 28], // Row 10
        [33, 32, 31], // Row 11
        [36, 35, 34]  // Row 12 (bottom)
    ]
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left side bets column (narrow) - constrained to exact height
            LeftSideBets(placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: narrowCellSize)
                .frame(width: narrowCellSize.width, height: cellSize.height * 13) // 12 number rows + 1 for 2:1
            
            // Dozen bets column (narrow) - constrained to exact height
            DozenBets(placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: narrowCellSize)
                .frame(width: narrowCellSize.width, height: cellSize.height * 13) // 12 number rows + 1 for 2:1
            
            // Main number grid with 2:1 below (wide columns) - fill remaining space
            VStack(spacing: 0) {
                // Number grid (3 columns, 12 rows)
                ForEach(Array(numberRows.enumerated()), id: \.offset) { rowIndex, numbers in
                    HStack(spacing: 0) {
                        ForEach(numbers, id: \.self) { number in
                            BettingArea(
                                title: "\(number)",
                                backgroundColor: getNumberColor(number),
                                textColor: .white,
                                betKey: "number_\(number)",
                                placedBets: $placedBets,
                                selectedChipValue: $selectedChipValue,
                                cellSize: cellSize
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: cellSize.height)
                        }
                    }
                }
                
                // 2:1 column bets below the numbers
                HStack(spacing: 0) {
                    BettingArea(title: "2:1", backgroundColor: AppTheme.casinoBlue, textColor: .white, betKey: "column1", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                        .frame(maxWidth: .infinity)
                    BettingArea(title: "2:1", backgroundColor: AppTheme.casinoBlue, textColor: .white, betKey: "column2", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                        .frame(maxWidth: .infinity)
                    BettingArea(title: "2:1", backgroundColor: AppTheme.casinoBlue, textColor: .white, betKey: "column3", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                        .frame(maxWidth: .infinity)
                }
                .frame(height: cellSize.height)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func getNumberColor(_ number: Int) -> Color {
        switch number {
        case 1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36:
            return AppTheme.casinoRed
        default:
            return AppTheme.casinoBlack
        }
    }
}

// MARK: - Left Side Bets
struct LeftSideBets: View {
    @Binding var placedBets: [String: Double]
    @Binding var selectedChipValue: Double
    let cellSize: CGSize
    
    var body: some View {
        VStack(spacing: 0) {
            BettingArea(title: "1-18", backgroundColor: AppTheme.casinoBlue, textColor: .white, betKey: "low", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                .frame(maxHeight: .infinity)
            BettingArea(title: "EVEN", backgroundColor: AppTheme.casinoBlue, textColor: .white, betKey: "even", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                .frame(maxHeight: .infinity)
            BettingArea(title: "RED", backgroundColor: AppTheme.casinoRed, textColor: .white, betKey: "red", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                .frame(maxHeight: .infinity)
            BettingArea(title: "BLACK", backgroundColor: AppTheme.casinoBlack, textColor: .white, betKey: "black", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                .frame(maxHeight: .infinity)
            BettingArea(title: "ODD", backgroundColor: AppTheme.casinoBlue, textColor: .white, betKey: "odd", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                .frame(maxHeight: .infinity)
            BettingArea(title: "19-36", backgroundColor: AppTheme.casinoBlue, textColor: .white, betKey: "high", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                .frame(maxHeight: .infinity)
        }
    }
}

// MARK: - Right Side Bets (Column bets)
struct RightSideBets: View {
    @Binding var placedBets: [String: Double]
    @Binding var selectedChipValue: Double
    let cellSize: CGSize
    
    var body: some View {
        VStack(spacing: 0) {
            BettingArea(title: "2:1", backgroundColor: AppTheme.casinoBlue, textColor: .white, betKey: "column1", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                .frame(height: cellSize.height)
            BettingArea(title: "2:1", backgroundColor: AppTheme.casinoBlue, textColor: .white, betKey: "column2", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                .frame(height: cellSize.height)
            BettingArea(title: "2:1", backgroundColor: AppTheme.casinoBlue, textColor: .white, betKey: "column3", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                .frame(height: cellSize.height)
        }
        .frame(width: cellSize.width * 0.8)
    }
}

// MARK: - Dozen Bets (Vertical Column)
struct DozenBets: View {
    @Binding var placedBets: [String: Double]
    @Binding var selectedChipValue: Double
    let cellSize: CGSize
    
    var body: some View {
        VStack(spacing: 0) {
            BettingArea(title: "1st 12", backgroundColor: AppTheme.casinoBlue, textColor: .white, betKey: "dozen1", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                .frame(maxHeight: .infinity)
            BettingArea(title: "2nd 12", backgroundColor: AppTheme.casinoBlue, textColor: .white, betKey: "dozen2", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                .frame(maxHeight: .infinity)
            BettingArea(title: "3rd 12", backgroundColor: AppTheme.casinoBlue, textColor: .white, betKey: "dozen3", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                .frame(maxHeight: .infinity)
        }
    }
}

// MARK: - Bottom Section (Dozen bets) - DEPRECATED
struct BottomSection: View {
    @Binding var placedBets: [String: Double]
    @Binding var selectedChipValue: Double
    let cellSize: CGSize
    
    var body: some View {
        HStack(spacing: 0) {
            BettingArea(title: "1st 12", backgroundColor: AppTheme.casinoBlue, textColor: .white, betKey: "dozen1", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
            BettingArea(title: "2nd 12", backgroundColor: AppTheme.casinoBlue, textColor: .white, betKey: "dozen2", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
            BettingArea(title: "3rd 12", backgroundColor: AppTheme.casinoBlue, textColor: .white, betKey: "dozen3", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
        }
        .frame(height: cellSize.height)
    }
}

// MARK: - Individual Betting Area
struct BettingArea: View {
    let title: String
    let backgroundColor: Color
    let textColor: Color
    let betKey: String
    @Binding var placedBets: [String: Double]
    @Binding var selectedChipValue: Double
    let cellSize: CGSize
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Rectangle()
            .fill(backgroundColor)
            .overlay(
                VStack(spacing: 2) {
                    // Area title
                    Text(title)
                        .font(.system(size: min(cellSize.width * 0.25, 14), weight: .bold))
                        .foregroundColor(textColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .allowsTightening(true)
                    
                    // Show placed chips
                    if let betAmount = getBetAmount(for: betKey), betAmount > 0 {
                        ChipView(value: getChipValue(for: betAmount), size: min(cellSize.width * 0.6, 30))
                    }
                }
            )
            .overlay(
                Rectangle()
                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    placeBet(betKey: betKey)
                }
            }
    }
    
    private func placeBet(betKey: String) {
        // Convert betKey to RouletteBetType
        let rouletteBetType = mapBetKeyToRouletteBetType(betKey)
        
        // Place bet through AppState
        appState.placeRouletteBet(betType: .roulette(rouletteBetType), amount: selectedChipValue)
        
        // Update local tracking
        let currentAmount = placedBets[betKey] ?? 0
        placedBets[betKey] = currentAmount + selectedChipValue
    }
    
    private func getBetAmount(for betKey: String) -> Double? {
        // Get amount from AppState bets
        let totalAmount = appState.bets
            .filter { bet in
                if case .roulette(let rouletteBetType) = bet.type {
                    return getBetKey(for: rouletteBetType) == betKey && bet.outcome == .pending
                }
                return false
            }
            .reduce(0) { $0 + $1.amount }
        
        return totalAmount > 0 ? totalAmount : nil
    }
    
    private func getChipValue(for amount: Double) -> Double {
        let availableChips: [Double] = [500, 250, 100, 50, 25, 10, 5, 1]
        
        for chipValue in availableChips {
            if amount >= chipValue {
                return chipValue
            }
        }
        
        return 1
    }
    
    private func mapBetKeyToRouletteBetType(_ betKey: String) -> RouletteBetType {
        switch betKey {
        case "zero": return .singleNumber(0)
        case "double_zero": return .singleNumber(37) // 00 in American roulette
        case "red": return .red
        case "black": return .black
        case "even": return .even
        case "odd": return .odd
        case "low": return .low
        case "high": return .high
        case "dozen1": return .dozen1
        case "dozen2": return .dozen2
        case "dozen3": return .dozen3
        case "column1": return .column1
        case "column2": return .column2
        case "column3": return .column3
        default:
            // Handle number bets
            if betKey.hasPrefix("number_") {
                let numberString = String(betKey.dropFirst(7))
                if let number = Int(numberString) {
                    return .singleNumber(number)
                }
            }
            return .singleNumber(1) // Default fallback
        }
    }
    
    private func getBetKey(for rouletteBetType: RouletteBetType) -> String {
        switch rouletteBetType {
        case .singleNumber(let number):
            return number == 0 ? "zero" : "number_\(number)"
        case .red: return "red"
        case .black: return "black"
        case .even: return "even"
        case .odd: return "odd"
        case .low: return "low"
        case .high: return "high"
        case .dozen1: return "dozen1"
        case .dozen2: return "dozen2"
        case .dozen3: return "dozen3"
        case .column1: return "column1"
        case .column2: return "column2"
        case .column3: return "column3"
        }
    }
}

// MARK: - Preview Provider
struct RouletteTableView_Previews: PreviewProvider {
    static var previews: some View {
        RouletteTableView()
            .environmentObject(AppState())
            .background(AppTheme.background)
    }
} 