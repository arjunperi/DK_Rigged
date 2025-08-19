import SwiftUI

extension Color {
    static var adaptiveBackground: Color {
        #if os(macOS)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color(.systemBackground)
        #endif
    }
}

struct AccountView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAddFunds = false
    @State private var addAmount: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // User profile header
                    UserProfileHeader()
                    
                    // Balance and quick actions
                    BalanceSection()
                    
                    // Statistics
                    StatisticsSection()
                    
                    // Recent activity
                    RecentActivitySection()
                    
                    // Settings
                    SettingsSection()
                }
                .padding()
            }
            .navigationTitle("Account")
            .sheet(isPresented: $showingAddFunds) {
                AddFundsSheet()
            }
        }
    }
}

struct UserProfileHeader: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile picture
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(String(appState.currentUser.username.prefix(1)).uppercased())
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                )
            
            // User info
            VStack(spacing: 4) {
                Text(appState.currentUser.username)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Member since \(Date(), style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.adaptiveBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
}

struct BalanceSection: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAddFunds = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Current balance
            VStack(spacing: 8) {
                Text("Current Balance")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("$\(String(format: "%.2f", appState.currentUser.balance))")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.green)
            }
            
            // Quick actions
            HStack(spacing: 12) {
                Button(action: { showingAddFunds = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Funds")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                        Text("Withdraw")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.adaptiveBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .sheet(isPresented: $showingAddFunds) {
            AddFundsSheet()
        }
    }
}

struct StatisticsSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                StatCard(
                    title: "Total Wagered",
                    value: "$\(String(format: "%.2f", appState.currentUser.totalWagered))",
                    color: .blue
                )
                
                StatCard(
                    title: "Total Won",
                    value: "$\(String(format: "%.2f", appState.currentUser.totalWon))",
                    color: .green
                )
                
                StatCard(
                    title: "Total Lost",
                    value: "$\(String(format: "%.2f", appState.currentUser.totalLost))",
                    color: .red
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.adaptiveBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

struct RecentActivitySection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
                .fontWeight(.semibold)
            
            if appState.gameHistory.isEmpty {
                Text("No recent activity")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(appState.gameHistory.prefix(5)) { game in
                    ActivityRow(game: game)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.adaptiveBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
}

struct ActivityRow: View {
    let game: RouletteGame
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Roulette Game")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Winning Number: \(game.winningNumber ?? 0)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.2f", game.bets.reduce(0) { $0 + $1.amount }))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(game.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct SettingsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "person.circle",
                    title: "Profile Settings",
                    action: {}
                )
                
                Divider()
                
                SettingsRow(
                    icon: "bell",
                    title: "Notifications",
                    action: {}
                )
                
                Divider()
                
                SettingsRow(
                    icon: "lock",
                    title: "Privacy & Security",
                    action: {}
                )
                
                Divider()
                
                SettingsRow(
                    icon: "questionmark.circle",
                    title: "Help & Support",
                    action: {}
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.adaptiveBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.adaptiveBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AddFundsSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    @State private var amount = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add Funds")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    TextField("Enter amount", text: $amount)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Quick amount buttons
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    QuickAmountButton(amount: "25", action: { amount = "25" })
                    QuickAmountButton(amount: "50", action: { amount = "50" })
                    QuickAmountButton(amount: "100", action: { amount = "100" })
                    QuickAmountButton(amount: "250", action: { amount = "250" })
                    QuickAmountButton(amount: "500", action: { amount = "500" })
                    QuickAmountButton(amount: "1000", action: { amount = "1000" })
                }
                
                Button(action: addFunds) {
                    Text("Add Funds")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(amount.isEmpty ? Color.gray : Color.blue)
                        )
                }
                .disabled(amount.isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Funds")
        }
    }
    
    private func addFunds() {
        if let amountValue = Double(amount) {
            appState.addFunds(amountValue)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct QuickAmountButton: View {
    let amount: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("$\(amount)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
            .environmentObject(AppState())
    }
} 
