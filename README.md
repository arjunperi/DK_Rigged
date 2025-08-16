# DK Rigged - Sports & Casino Betting App

A comprehensive sports and casino betting application built with SwiftUI, featuring a rigged roulette game for controlled outcomes.

## Features

### 🏈 Sports Betting
- View upcoming sports events across multiple sports (Football, Basketball, Baseball, Soccer, Hockey)
- Filter events by sport type
- View betting odds and options
- Modern interface similar to DraftKings/FanDuel

### 🎰 Casino Games
- **Roulette Game** (Fully Implemented)
  - Multiple betting options (Single Number, Red/Black, Even/Odd, etc.)
  - Realistic payout multipliers
  - Game history tracking
- **Coming Soon**: Slots, Blackjack, Poker

### 🎯 Rigged Roulette Controls
- **Hidden Rigged Mode**: Tap the "Rigged" button in the Casino tab
- **Set Outcome**: Choose any number (0-36) for the next spin
- **Controlled Results**: Perfect for demonstrations or testing
- **History Tracking**: All rigged games are marked in the history

### 👤 Account Management
- User profile and statistics
- Account balance management
- Add funds functionality
- Betting statistics (Total Wagered, Won, Lost, Net Profit)
- Recent activity tracking

## How to Use

### Getting Started
1. Launch the app
2. Start with $1000 in your account
3. Navigate between Sports, Casino, and Account tabs

### Playing Roulette
1. Go to the **Casino** tab
2. Select "Roulette" (default)
3. Enter your bet amount
4. Choose your bet type (Red, Black, Single Number, etc.)
5. Tap "Place Bet"
6. Tap "Spin" to see the result

### Using Rigged Mode
1. In the **Casino** tab, tap the "Rigged" button in the top-right
2. Enter your desired number (0-36)
3. Tap "Set" to activate rigged mode
4. Place your bets normally
5. The next spin will land on your chosen number
6. Use "Disable" to turn off rigged mode

### Adding Funds
1. Go to the **Account** tab
2. Tap "Add Funds" in the balance section
3. Enter amount or use quick amount buttons
4. Tap "Add Funds" to confirm

## Technical Details

- **Framework**: SwiftUI
- **Platform**: iOS, macOS (Universal App)
- **Architecture**: MVVM with ObservableObject
- **Data**: In-memory storage with Codable models
- **UI**: Modern, card-based design with shadows and rounded corners

## Betting Options

### Roulette Bet Types
- **Single Number**: 35x payout
- **Red/Black**: 1x payout
- **Even/Odd**: 1x payout
- **Low (1-18)/High (19-36)**: 1x payout
- **Dozen Bets**: 2x payout
- **Column Bets**: 2x payout

## Safety Features

- **Simulation Only**: This is a fake betting app for entertainment purposes
- **No Real Money**: All transactions are simulated
- **Rigged Controls**: Only visible when explicitly enabled
- **Clear Indicators**: Rigged games are clearly marked in history

## Development Notes

The app is designed to be easily extensible:
- Add new casino games by implementing new game views
- Expand sports betting with more bet types
- Implement persistence for user data
- Add multiplayer functionality
- Integrate with real sports APIs

## Disclaimer

This application is for entertainment and demonstration purposes only. It does not involve real money gambling and should not be used as such. The rigged functionality is intended for educational and testing purposes. 