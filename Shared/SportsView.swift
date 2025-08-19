import SwiftUI

struct SportsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedSport: Sport? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Sport filter tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(Sport.allCases, id: \.self) { sport in
                            SportFilterButton(
                                sport: sport,
                                isSelected: selectedSport == sport || selectedSport == nil
                            ) {
                                if selectedSport == sport {
                                    selectedSport = nil
                                } else {
                                    selectedSport = sport
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Events list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredEvents) { event in
                            SportsEventCard(event: event)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Sports")
        }
    }
    
    private var filteredEvents: [SportsEvent] {
        if let selectedSport = selectedSport {
            return appState.upcomingEvents.filter { $0.sport == selectedSport }
        }
        return appState.upcomingEvents
    }
}

struct SportFilterButton: View {
    let sport: Sport
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(sport.icon)
                    .font(.title2)
                
                Text(sport.rawValue)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SportsEventCard: View {
    let event: SportsEvent
    @State private var showingBettingOptions = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Event header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(event.awayTeam) @ \(event.homeTeam)")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Text(event.sport.icon)
                        Text(event.sport.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(event.startTime, style: .time)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(event.startTime, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Quick betting options
            HStack(spacing: 12) {
                QuickBetButton(
                    title: "\(event.awayTeam) Win",
                    odds: "+150",
                    action: { showingBettingOptions = true }
                )
                
                QuickBetButton(
                    title: "\(event.homeTeam) Win",
                    odds: "-120",
                    action: { showingBettingOptions = true }
                )
                
                QuickBetButton(
                    title: "Over/Under",
                    odds: "O/U 48.5",
                    action: { showingBettingOptions = true }
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.adaptiveBackground)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .sheet(isPresented: $showingBettingOptions) {
            SportsBettingOptionsView(event: event)
        }
    }
}

struct QuickBetButton: View {
    let title: String
    let odds: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                
                Text(odds)
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.1))
            )
            .foregroundColor(.primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SportsBettingOptionsView: View {
    let event: SportsEvent
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedBetType = ""
    @State private var betAmount = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Event info
                VStack(spacing: 8) {
                    Text("\(event.awayTeam) @ \(event.homeTeam)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(event.sport.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Betting options
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select Bet Type")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        BettingOptionCard(
                            title: "\(event.awayTeam) Win",
                            odds: "+150",
                            payout: "2.5x",
                            isSelected: selectedBetType == "away"
                        ) {
                            selectedBetType = "away"
                        }
                        
                        BettingOptionCard(
                            title: "\(event.homeTeam) Win",
                            odds: "-120",
                            payout: "1.83x",
                            isSelected: selectedBetType == "home"
                        ) {
                            selectedBetType = "home"
                        }
                        
                        BettingOptionCard(
                            title: "Over 48.5",
                            odds: "-110",
                            payout: "1.91x",
                            isSelected: selectedBetType == "over"
                        ) {
                            selectedBetType = "over"
                        }
                        
                        BettingOptionCard(
                            title: "Under 48.5",
                            odds: "-110",
                            payout: "1.91x",
                            isSelected: selectedBetType == "under"
                        ) {
                            selectedBetType = "under"
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Bet amount
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bet Amount")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TextField("Enter amount", text: $betAmount)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }
                
                // Place bet button
                Button(action: placeBet) {
                    Text("Place Bet")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedBetType.isEmpty || betAmount.isEmpty ? Color.gray : Color.blue)
                        )
                }
                .disabled(selectedBetType.isEmpty || betAmount.isEmpty)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Place Bet")
        }
    }
    
    private func placeBet() {
        // Place bet logic would go here
        presentationMode.wrappedValue.dismiss()
    }
}

struct BettingOptionCard: View {
    let title: String
    let odds: String
    let payout: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                
                Text(odds)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                
                Text(payout)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.1))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SportsView_Previews: PreviewProvider {
    static var previews: some View {
        SportsView()
            .environmentObject(AppState())
    }
} 
