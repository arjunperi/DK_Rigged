import SwiftUI

// MARK: - Global Helper Functions
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
        return number == 0 ? "zero" : (number == 37 ? "double_zero" : "number_\(number)")
    case .split(let numbers):
        return "split_\(numbers.map { String($0) }.joined(separator: "_"))"
    case .street(let numbers):
        return "street_\(numbers.map { String($0) }.joined(separator: "_"))"
    case .corner(let numbers):
        return "corner_\(numbers.map { String($0) }.joined(separator: "_"))"
    case .fiveNumber:
        return "five_number"
    case .line(let numbers):
        return "line_\(numbers.map { String($0) }.joined(separator: "_"))"
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

// MARK: - Pentagon Shape with Perfectly Vertical Edges
struct Pentagon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let height = rect.height
        let centerX = rect.midX
        
        // Create pentagon with perfectly vertical left and right edges
        let topY = rect.minY + height * 0.1      // Top point
        let bottomY = rect.maxY - height * 0.1   // Bottom corners
        let leftX = rect.minX                    // Left edge (perfectly vertical)
        let rightX = rect.maxX                   // Right edge (perfectly vertical)
        let midHeight = rect.midY                // Middle height for side points
        
        // Pentagon points with truly vertical left and right edges
        let points = [
            CGPoint(x: centerX, y: topY),        // Top point (center)
            CGPoint(x: rightX, y: midHeight),    // Right middle (vertical edge)
            CGPoint(x: rightX, y: bottomY),      // Right bottom (vertical edge continues)
            CGPoint(x: leftX, y: bottomY),       // Left bottom (vertical edge starts)
            CGPoint(x: leftX, y: midHeight)      // Left middle (vertical edge)
        ]
        
        // Create the path
        path.move(to: points[0])
        for i in 1..<points.count {
            path.addLine(to: points[i])
        }
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Main Roulette Table View
struct RouletteTableView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedChipValue: Double = 25
    @State private var placedBets: [String: Double] = [:]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: AppSpacing.xxs) {
                    // Main roulette table
                    RouletteTable(
                        placedBets: $placedBets,
                        selectedChipValue: $selectedChipValue,
                        cellSize: calculateCellSize(for: geometry.size),
                        narrowCellSize: calculateNarrowCellSize(for: geometry.size)
                    )
                    .padding(.horizontal, 16) // Equal small margins
                    .padding(.vertical, 8)
                    
                    // Chip selection below the table
                    HStack(spacing: AppSpacing.sm) {
                        ForEach([1.0, 5.0, 10.0, 25.0, 50.0, 100.0], id: \.self) { chipValue in
                            ChipSelectorButton(
                                value: chipValue,
                                isSelected: selectedChipValue == chipValue
                            ) {
                                selectedChipValue = chipValue
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.xs)
                }
            }
        }
    }
    
    private func calculateCellSize(for size: CGSize) -> CGSize {
        let tableWidth = size.width - 32 // Small equal margins on left/right
        let tableHeight = size.height - 120 // Reserve space for controls and chips below
        
        // DraftKings has 2 narrow columns + 3 wide columns
        let _ = min(tableWidth / 8, 45) // Narrow columns (left bets + dozens)
        let wideWidth = min(tableWidth / 5, 60)   // Wide columns (numbers)
        let cellHeight = min(tableHeight / 14, 45) // Fit 12 number rows + 2:1 row
        
        return CGSize(width: wideWidth, height: cellHeight)
    }
    
    private func calculateNarrowCellSize(for size: CGSize) -> CGSize {
        let tableWidth = size.width - 32
        let tableHeight = size.height - 120
        
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
                
                // Green zeros above the 3 number columns only - match exact width
                ZeroSection(placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                    .frame(maxWidth: .infinity) // Match number grid flexible width exactly
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
            // Single Zero (0) - Positioned to align with left edge of first number column
            StyledZeroBettingArea(
                title: "0",
                betKey: "zero",
                placedBets: $placedBets,
                selectedChipValue: $selectedChipValue,
                cellSize: cellSize
            )
            .frame(width: cellSize.width * 1.5) // From left edge of column 1 to midpoint
            .frame(height: cellSize.height * 1.0)
            
            // Double Zero (00) - From midpoint to right edge of last number column
            StyledZeroBettingArea(
                title: "00",
                betKey: "double_zero",
                placedBets: $placedBets,
                selectedChipValue: $selectedChipValue,
                cellSize: cellSize
            )
            .frame(width: cellSize.width * 1.5) // From midpoint to right edge of column 3
            .frame(height: cellSize.height * 1.0)
        }
    }
}

// MARK: - Styled Zero Betting Area
struct StyledZeroBettingArea: View {
    let title: String
    let betKey: String
    @Binding var placedBets: [String: Double]
    @Binding var selectedChipValue: Double
    let cellSize: CGSize
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            // Green pentagon background with white border like your screenshot
            Pentagon()
                .fill(AppTheme.casinoGreen)
                .overlay(
                    Pentagon()
                        .stroke(Color.white, lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
            
            VStack(spacing: 2) {
                // Zero text
                Text(title)
                    .font(.system(size: min(cellSize.width * 0.5, 24), weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                
                // Show placed chips
                if let betAmount = getBetAmount(for: betKey), betAmount > 0 {
                    ChipView(value: getChipValue(for: betAmount), size: min(cellSize.width * 0.25, 16))
                }
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                placeBet(betKey: betKey)
            }
        }
    }
    
    private func placeBet(betKey: String) {
        let rouletteBetType = mapBetKeyToRouletteBetType(betKey)
        let betType = BetType.roulette(rouletteBetType)
        appState.placeRouletteBet(betType: betType, amount: selectedChipValue)
    }
    
    private func getBetAmount(for betKey: String) -> Double? {
        let rouletteBetType = mapBetKeyToRouletteBetType(betKey)
        return appState.bets
            .filter { bet in
                if case .roulette(let type) = bet.type {
                    return type == rouletteBetType && bet.outcome == .pending
                }
                return false
            }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func getChipValue(for totalAmount: Double) -> Double {
        let availableChips: [Double] = [1, 5, 10, 25, 50, 100]
        return availableChips.reversed().first { $0 <= totalAmount } ?? 1
    }
    

}

// MARK: - Main Number Grid
struct NumberGrid: View {
    @Binding var placedBets: [String: Double]
    @Binding var selectedChipValue: Double
    let cellSize: CGSize
    let narrowCellSize: CGSize
    
    // Numbers arranged in DraftKings 3-column layout (1,4,7 column on left, 3,6,9 column on right)
    private let numberRows = [
        [1, 2, 3],   // Row 1 (top)
        [4, 5, 6],   // Row 2  
        [7, 8, 9],   // Row 3
        [10, 11, 12], // Row 4
        [13, 14, 15], // Row 5
        [16, 17, 18], // Row 6
        [19, 20, 21], // Row 7
        [22, 23, 24], // Row 8
        [25, 26, 27], // Row 9
        [28, 29, 30], // Row 10
        [31, 32, 33], // Row 11
        [34, 35, 36]  // Row 12 (bottom)
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
        // Green numbers (0 and 00) stay unchanged
        case 0, 37:
            return AppTheme.casinoGreen
            
        // Custom red numbers based on your specification
        case 1, 7, 16, 19, 25, 34,         // Leftmost column (1,4,7...) - your "Column 1"
             5, 14, 23, 32,                 // Middle column (2,5,8...) - your "Column 2"  
             3, 9, 12, 18, 21, 27, 30, 36:  // Rightmost column (3,6,9...) - your "Column 3"
            return AppTheme.casinoRed
            
        // All other numbers are black
        default:
            return AppTheme.casinoBlack
        }
    }
}

// MARK: - Left Side Bets (Redesigned to match screenshot)
struct LeftSideBets: View {
    @Binding var placedBets: [String: Double]
    @Binding var selectedChipValue: Double
    let cellSize: CGSize
    
    var body: some View {
        VStack(spacing: 0) {
            // 1-18
            ModernBettingArea(title: "1-18", backgroundColor: AppTheme.casinoGreen, textColor: .white, betKey: "low", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                .frame(maxHeight: .infinity)
            
            // EVEN
            ModernBettingArea(title: "EVEN", backgroundColor: AppTheme.casinoGreen, textColor: .white, betKey: "even", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                .frame(maxHeight: .infinity)
            
            // RED with diamond
            DiamondBettingArea(color: .red, betKey: "red", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                .frame(maxHeight: .infinity)
            
            // BLACK with diamond
            DiamondBettingArea(color: .black, betKey: "black", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                .frame(maxHeight: .infinity)
            
            // ODD
            ModernBettingArea(title: "ODD", backgroundColor: AppTheme.casinoGreen, textColor: .white, betKey: "odd", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                .frame(maxHeight: .infinity)
            
            // 19-36
            ModernBettingArea(title: "19-36", backgroundColor: AppTheme.casinoGreen, textColor: .white, betKey: "high", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
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

// MARK: - Dozen Bets (Redesigned to match screenshot)
struct DozenBets: View {
    @Binding var placedBets: [String: Double]
    @Binding var selectedChipValue: Double
    let cellSize: CGSize
    
    var body: some View {
        VStack(spacing: 0) {
            // 1-12
            ModernBettingArea(title: "1-12", backgroundColor: AppTheme.casinoGreen, textColor: .white, betKey: "dozen1", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                .frame(maxHeight: .infinity)
            
            // 13-24
            ModernBettingArea(title: "13-24", backgroundColor: AppTheme.casinoGreen, textColor: .white, betKey: "dozen2", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
                .frame(maxHeight: .infinity)
            
            // 25-36
            ModernBettingArea(title: "25-36", backgroundColor: AppTheme.casinoGreen, textColor: .white, betKey: "dozen3", placedBets: $placedBets, selectedChipValue: $selectedChipValue, cellSize: cellSize)
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

// MARK: - Modern Betting Area (Clean design like screenshot)
struct ModernBettingArea: View {
    let title: String
    let backgroundColor: Color
    let textColor: Color
    let betKey: String
    @Binding var placedBets: [String: Double]
    @Binding var selectedChipValue: Double
    let cellSize: CGSize
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(backgroundColor)
                .overlay(
                    Rectangle()
                        .stroke(Color.white, lineWidth: 2)
                )
            
            // Content - Centered text and chips
            VStack(spacing: 2) {
                // Text - horizontally centered
                Text(title)
                    .font(.system(size: min(cellSize.width * 0.25, 14), weight: .bold)) // Match main number grid font
                    .foregroundColor(textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .allowsTightening(true)
                    .frame(maxWidth: .infinity) // Center horizontally
                
                // Chip indicator (if bet placed)
                if let amount = getBetAmount(for: betKey), amount > 0 {
                    ChipView(value: getChipValue(for: amount), size: min(cellSize.width * 0.4, 20))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Center both ways
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                placeBet(betKey: betKey)
            }
        }
    }
    
    private func placeBet(betKey: String) {
        let rouletteBetType = mapBetKeyToRouletteBetType(betKey)
        let betType = BetType.roulette(rouletteBetType)
        appState.placeRouletteBet(betType: betType, amount: selectedChipValue)
        
        // Update local tracking
        let currentAmount = placedBets[betKey] ?? 0
        placedBets[betKey] = currentAmount + selectedChipValue
    }
    
    private func getBetAmount(for betKey: String) -> Double? {
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
        let availableChips: [Double] = [100, 50, 25, 10, 5, 1]
        
        for chipValue in availableChips {
            if amount >= chipValue {
                return chipValue
            }
        }
        
        return 1
    }
}

// MARK: - Diamond Betting Area (For RED/BLACK)
struct DiamondBettingArea: View {
    enum DiamondColor {
        case red, black
    }
    
    let color: DiamondColor
    let betKey: String
    @Binding var placedBets: [String: Double]
    @Binding var selectedChipValue: Double
    let cellSize: CGSize
    @EnvironmentObject var appState: AppState
    
    var backgroundColor: Color {
        switch color {
        case .red: return AppTheme.casinoRed
        case .black: return AppTheme.casinoBlack
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(AppTheme.casinoGreen)
                .overlay(
                    Rectangle()
                        .stroke(Color.white, lineWidth: 2)
                )
            
            // Diamond shape - wider and centered
            Diamond()
                .fill(backgroundColor)
                .frame(width: min(cellSize.width * 0.8, 35), height: min(cellSize.width * 0.6, 28)) // Wider diamond
                .overlay(
                    Diamond()
                        .stroke(Color.white, lineWidth: 2) // Slightly thicker border
                        .frame(width: min(cellSize.width * 0.8, 35), height: min(cellSize.width * 0.6, 28))
                )
            
            // Chip indicator (if bet placed) - positioned below diamond
            if let amount = getBetAmount(for: betKey), amount > 0 {
                VStack {
                    Spacer()
                    ChipView(value: getChipValue(for: amount), size: min(cellSize.width * 0.35, 18))
                        .padding(.bottom, 6)
                }
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                placeBet(betKey: betKey)
            }
        }
    }
    
    private func placeBet(betKey: String) {
        let rouletteBetType = mapBetKeyToRouletteBetType(betKey)
        let betType = BetType.roulette(rouletteBetType)
        appState.placeRouletteBet(betType: betType, amount: selectedChipValue)
        
        // Update local tracking
        let currentAmount = placedBets[betKey] ?? 0
        placedBets[betKey] = currentAmount + selectedChipValue
    }
    
    private func getBetAmount(for betKey: String) -> Double? {
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
        let availableChips: [Double] = [100, 50, 25, 10, 5, 1]
        
        for chipValue in availableChips {
            if amount >= chipValue {
                return chipValue
            }
        }
        
        return 1
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
                        ChipView(value: getChipValue(for: betAmount), size: min(cellSize.width * 0.4, 20))
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
}

// MARK: - Preview Provider
struct RouletteTableView_Previews: PreviewProvider {
    static var previews: some View {
        RouletteTableView()
            .environmentObject(AppState())
            .background(AppTheme.background)
    }
} 