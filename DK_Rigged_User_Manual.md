# DK_Rigged - User Manual & Documentation

## 🎯 **App Overview**

DK_Rigged is a **simulation betting app** that mimics the interface and functionality of real sports betting applications like DraftKings and FanDuel. The app features a **rigged roulette game** where you can control win/loss outcomes, along with a sports betting interface and account management system.

**⚠️ IMPORTANT: This is a FAKE/SIMULATION app for entertainment purposes only. No real money is involved.**

---

## 🏗️ **App Architecture**

### **Core Components:**
- **SwiftUI Interface**: Modern, responsive UI built with SwiftUI
- **State Management**: Centralized `AppState` class managing all app data
- **Data Models**: Custom models for users, bets, roulette games, and sports events
- **Tab Navigation**: Three main sections (Sports, Casino, Account)

### **File Structure:**
```
DK_Rigged/
├── Shared/
│   ├── DK_RiggedApp.swift      # Main app entry point
│   ├── ContentView.swift       # Tab navigation container
│   ├── AppState.swift          # Central state management
│   ├── Models.swift            # Data models and types
│   ├── SportsView.swift        # Sports betting interface
│   ├── CasinoView.swift        # Casino games (roulette)
│   ├── AccountView.swift       # User account and statistics
│   └── Assets.xcassets/        # App icons and colors
└── DK_Rigged.xcodeproj/        # Xcode project file
```

---

## 🎰 **Casino Tab - Rigged Roulette**

### **How It Works:**
The roulette game is **completely rigged** - you control the outcome of every spin. This allows you to test betting strategies or simply have fun controlling the results.

### **Game Features:**
- **European Roulette**: Numbers 0-36 (37 total slots)
- **Multiple Bet Types**: Single numbers, colors, even/odd, dozens, columns
- **Realistic Payouts**: Standard roulette odds (35:1 for single numbers, 2:1 for colors, etc.)
- **Rigged Mode**: Control exactly which number wins

### **Betting Options:**

#### **Single Number Bets:**
- **Bet on**: Any number 0-36
- **Payout**: 35:1 (bet $10, win $350)
- **Example**: Bet on 7, if 7 wins, you get 35x your bet

#### **Color Bets:**
- **Red Numbers**: 1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36
- **Black Numbers**: 2,4,6,8,10,11,13,15,17,20,22,24,26,28,29,31,33,35
- **Green**: 0 (house edge)
- **Payout**: 2:1 (bet $10, win $20)

#### **Other Bet Types:**
- **Even/Odd**: 2:1 payout (0 doesn't count as even)
- **Low (1-18) / High (19-36)**: 2:1 payout
- **Dozen Bets**: 3:1 payout
  - 1st Dozen: 1-12
  - 2nd Dozen: 13-24
  - 3rd Dozen: 25-36
- **Column Bets**: 3:1 payout
  - 1st Column: 1,4,7,10,13,16,19,22,25,28,31,34
  - 2nd Column: 2,5,8,11,14,17,20,23,26,29,32,35
  - 3rd Column: 3,6,9,12,15,18,21,24,27,30,33,36

---

## 🎮 **How to Use the Rigged Roulette**

### **Step 1: Enable Rigged Mode**
1. Go to the **Casino** tab
2. Scroll down to find the **"Rigged"** button
3. Tap it to enable rigged mode

### **Step 2: Set Your Desired Outcome**
1. **Enter a number** (0-36) in the text field
2. **Tap "Set Outcome"** to confirm
3. The app will remember this number for the next spin

### **Step 3: Place Your Bet**
1. **Select a bet type** from the grid of options
2. **Enter your bet amount** in the "Bet Amount" field
3. **Tap "Place Bet"** to confirm your bet

### **Step 4: Spin the Wheel**
1. **Tap "Spin Roulette"** to spin the wheel
2. **Watch as your rigged number wins!** 🎉
3. **Collect your winnings** (if you bet on the winning outcome)

### **Step 5: Repeat**
- **Rigged mode automatically resets** after each spin
- **Enable it again** for the next round
- **Set a new number** each time if desired

---

## 🏈 **Sports Tab - Sports Betting Interface**

### **Features:**
- **Upcoming Events**: View scheduled sports events
- **Sport Filtering**: Filter by Football, Basketball, Baseball
- **Event Details**: Home team vs. Away team with start times
- **Betting Interface**: Place bets on sports outcomes (simulation only)

### **Sample Events:**
- **Football**: Patriots vs. Bills
- **Basketball**: Lakers vs. Warriors  
- **Baseball**: Yankees vs. Red Sox

---

## 👤 **Account Tab - User Management**

### **User Profile:**
- **Username**: Display name (default: "Player")
- **Balance**: Current available funds
- **Statistics**: Total wagered, won, and lost amounts

### **Quick Actions:**
- **Add Funds**: Increase your balance (simulation)
- **Withdraw**: Decrease your balance (simulation)

### **Game History:**
- **Recent Roulette Games**: View past spins and results
- **Betting History**: Track all your bets and outcomes
- **Performance Stats**: Monitor your win/loss ratio

---

## 💰 **Starting Balance & Economics**

### **Initial Setup:**
- **Starting Balance**: $1,000.00
- **Sample Bets**: Pre-loaded for demonstration
- **Sample History**: Previous games for context

### **Money Management:**
- **No Real Money**: All transactions are simulated
- **Unlimited Funds**: Add as much as you want
- **Risk-Free Testing**: Perfect for learning betting strategies

---

## 🔧 **Technical Details**

### **State Management:**
```swift
class AppState: ObservableObject {
    @Published var currentUser: User
    @Published var bets: [Bet]
    @Published var rouletteHistory: [RouletteResult]
    @Published var gameHistory: [RouletteGame]
    @Published var selectedRiggedNumber: Int?
    @Published var isRiggedMode: Bool
}
```

### **Rigged Mode Logic:**
```swift
func spinRoulette() -> RouletteResult {
    let number: Int
    if isRiggedMode, let riggedNumber = selectedRiggedNumber {
        number = riggedNumber  // Use your chosen number
    } else {
        number = Int.random(in: 0...36)  // Random number
    }
    // ... rest of spin logic
}
```

---

## 🚀 **Getting Started**

### **Prerequisites:**
- **Xcode 13+** installed on macOS
- **iOS Simulator** or physical iOS device
- **Basic understanding** of iOS development

### **Installation Steps:**
1. **Open Xcode**
2. **Open Project**: `DK_Rigged.xcodeproj`
3. **Select Target**: Choose iOS Simulator (e.g., iPhone 13)
4. **Build & Run**: Press `Cmd + R`

### **First Run:**
1. **App launches** with $1,000 starting balance
2. **Navigate to Casino tab**
3. **Enable rigged mode** and set your first number
4. **Place a bet** and spin the wheel
5. **Watch your controlled outcome win!**

---

## 🎯 **Use Cases & Scenarios**

### **For Developers:**
- **Testing betting algorithms** with controlled outcomes
- **UI/UX development** for gambling applications
- **State management** practice with complex data flows

### **For Learning:**
- **Understanding roulette odds** and payouts
- **Learning betting strategies** without financial risk
- **Exploring casino game mechanics**

### **For Entertainment:**
- **Fun with friends** - control who wins
- **Party games** - rig outcomes for laughs
- **Casino simulation** experience

---

## ⚠️ **Important Disclaimers**

### **Legal & Ethical:**
- **This is NOT a real gambling app**
- **No real money is involved**
- **For entertainment and educational purposes only**
- **Do not use for actual gambling**

### **Technical Limitations:**
- **iOS only** - no Android version
- **Simulator/device required** - no web version
- **Local data only** - no cloud sync
- **Single user** - no multiplayer

---

## 🐛 **Troubleshooting**

### **Common Issues:**

#### **"Cannot find AppState in scope"**
- **Solution**: Clean build folder (Shift + Cmd + K)
- **Alternative**: Close and reopen Xcode

#### **"Build input files cannot be found"**
- **Solution**: Check project file paths are correct
- **Alternative**: Rebuild project from scratch

#### **App crashes on launch**
- **Solution**: Check iOS Simulator version compatibility
- **Alternative**: Use different simulator or physical device

### **Performance Tips:**
- **Use iOS Simulator** for development
- **Physical device** for performance testing
- **Clean builds** regularly to avoid caching issues

---

## 🔮 **Future Enhancements**

### **Potential Features:**
- **More Casino Games**: Blackjack, slots, poker
- **Advanced Rigging**: Control multiple outcomes, patterns
- **Multiplayer Support**: Play with friends
- **Cloud Sync**: Save progress across devices
- **More Sports**: Soccer, tennis, golf
- **Live Odds**: Simulated real-time betting lines

### **Technical Improvements:**
- **Better UI/UX**: More polished interface
- **Animations**: Smooth transitions and effects
- **Sound Effects**: Casino atmosphere
- **Haptic Feedback**: Touch sensations
- **Accessibility**: VoiceOver support

---

## 📞 **Support & Contact**

### **For Technical Issues:**
- **Check Xcode console** for error messages
- **Verify project file** structure is correct
- **Ensure all Swift files** are included in build targets

### **For Feature Requests:**
- **Document specific requirements**
- **Provide use case examples**
- **Consider implementation complexity**

---

## 🎉 **Conclusion**

DK_Rigged provides a **unique and entertaining** way to explore casino gaming and sports betting without any financial risk. The rigged roulette feature makes it perfect for:

- **Learning betting strategies**
- **Testing algorithms**
- **Having fun with friends**
- **Understanding casino mechanics**

**Remember: This is a simulation app for entertainment purposes only. Enjoy responsibly!**

---

*Last Updated: August 16, 2025*  
*Version: 1.0*  
*Platform: iOS (SwiftUI)* 