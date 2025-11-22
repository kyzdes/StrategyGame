# Corporate Empire - iOS Game

A multiplayer idle strategy game for iOS where players create and develop corporations, trade stocks, form alliances, and compete for economic dominance in a virtual world.

## 🎮 Game Overview

Corporate Empire combines idle mechanics with strategic gameplay:
- **Idle Mechanics**: Companies generate revenue offline
- **Strategic Layer**: Portfolio management, investments, M&A
- **Social Layer**: Cooperative corporations with friends
- **Trading Layer**: Dynamic stock exchange with real-time pricing

## 🏗️ Architecture

The project follows **Clean Architecture** principles with MVVM pattern and Coordinators for navigation.

```
CorporateEmpire/
├── App/                        # Application entry point
│   ├── CorporateEmpireApp.swift
│   ├── AppCoordinator.swift
│   └── MainTabView.swift
│
├── Core/                       # Core infrastructure
│   ├── Network/               # API Client & WebSocket
│   ├── Storage/               # CoreData & Keychain
│   ├── DI/                    # Dependency Injection
│   └── Extensions/            # Common extensions
│
├── Domain/                     # Business Logic Layer
│   ├── Entities/              # Domain models
│   │   ├── Player.swift
│   │   ├── Company.swift
│   │   ├── Stock.swift
│   │   ├── Corporation.swift
│   │   ├── Manager.swift
│   │   └── Upgrade.swift
│   ├── UseCases/              # Business use cases
│   │   ├── CompanyManagement/
│   │   ├── TradingSystem/
│   │   ├── SocialFeatures/
│   │   └── IdleProgress/
│   └── Repositories/          # Repository protocols
│
├── Data/                       # Data Layer
│   ├── Network/               # DTOs & API Services
│   ├── Local/                 # CoreData models
│   └── Repositories/          # Repository implementations
│
└── Presentation/               # UI Layer
    ├── Scenes/                # Feature screens
    │   ├── Dashboard/
    │   ├── Company/
    │   ├── Trading/
    │   ├── Social/
    │   └── Profile/
    └── Components/            # Reusable UI components
        └── DesignSystem/      # Colors, Fonts, Spacing
```

## 📱 Tech Stack

### iOS Technologies
- **UI**: SwiftUI (iOS 16+)
- **Reactive**: Combine
- **Concurrency**: Swift async/await
- **Storage**: CoreData + Keychain
- **Networking**: URLSession + WebSocket
- **Architecture**: Clean Architecture + MVVM

### Backend (Separate Project)
- Node.js + TypeScript
- PostgreSQL + Redis
- WebSocket for real-time updates

## 🎯 Core Features

### 1. Company Management
- Create and manage multiple companies
- Idle revenue generation (continues offline)
- Upgrades system (Automation, Efficiency, Expansion, Innovation)
- Manager system with different rarities (Common, Rare, Epic, Legendary)
- Level progression and experience

### 2. Stock Trading
- Real-time stock market
- Multiple order types (Market, Limit, Stop Loss, Take Profit)
- Portfolio management and analytics
- Market conditions and trends
- Industry-specific multipliers

### 3. Corporations (Guilds)
- Create or join corporations
- Member roles (Founder, CEO, CFO, Member, Investor)
- Corporation projects and perks
- Treasury management
- IPO system for corporations

### 4. Idle Progress
- Offline revenue calculation (up to 48 hours effective)
- Effectiveness degradation after 12 hours
- Missed opportunities tracking
- Multiple revenue multipliers (upgrades, managers, prestige)

### 5. Prestige System
- Hard reset with permanent bonuses
- Prestige points and perks
- Tier system (Bronze, Silver, Gold, Platinum, Diamond)
- Permanent multipliers

### 6. Social Features
- Friends system
- Leaderboards (Net Worth, Revenue, Trading, Corporation Power)
- Chat system (Global, Corporation, Direct Messages)
- Profile privacy settings

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 16.0+
- Swift 5.9+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/StrategyGame.git
cd StrategyGame
```

2. Open the project in Xcode:
```bash
open CorporateEmpire.xcodeproj
```

3. Build and run the project (⌘+R)

### Configuration

The app uses different API endpoints for development and production:

- **Development**: `https://api-dev.corporateempire.game`
- **Production**: `https://api.corporateempire.game`

Update `EndpointConfiguration.swift` to change the base URL.

## 🎨 Design System

The app uses a comprehensive design system:

### Colors
- **Primary**: Blue (#007AFF)
- **Secondary**: Green (#34C759)
- **Status**: Positive (Green), Negative (Red), Neutral (Gray)
- **Rarity**: Common (Gray), Rare (Blue), Epic (Purple), Legendary (Orange)

### Typography
- Display fonts (Large Title, Title, Title2, Title3)
- Body fonts (Headline, Body, Callout, Subheadline, Footnote, Caption)
- Monospaced fonts for numbers/money
- Rounded fonts for stats/metrics

### Spacing
- XXS: 4pt, XS: 8pt, SM: 12pt, MD: 16pt, LG: 24pt, XL: 32pt, XXL: 48pt

## 🧪 Testing

Run tests with:
```bash
swift test
```

Or in Xcode (⌘+U)

## 📊 Game Economy

### Currencies
- **Cash**: Main game currency (earned from companies, trading)
- **Gems**: Premium currency (IAP, rewards, achievements)
- **Prestige Points**: Earned from prestige resets

### Progression Curve
- **Level 1-10**: Tutorial, basic mechanics ($1K - $100K revenue)
- **Level 11-25**: Mid game, multiple companies ($100K - $10M)
- **Level 26-50**: Late game, stock trading focus ($10M - $1B)
- **Level 51-100**: End game, corporations, prestige ($1B+)

### Formulas
```swift
// Company Revenue (per second)
Revenue = BaseRevenue × Level^1.5 × UpgradeMultiplier × ManagerMultiplier × PrestigeBonus

// Upgrade Cost
Cost = BaseCost × 1.15^Level

// Stock Price
Price = (CompanyValuation / TotalShares) × DemandMultiplier × IndustryTrend × EventModifier
```

## 🔐 Security

- Authentication tokens stored in Keychain
- Server-authoritative for all critical data
- Certificate pinning for API calls
- Rate limiting on requests
- No client-side cheating possible for currency/assets

## 📱 Performance Targets

- App launch time: < 2 seconds
- Screen load time: < 500ms
- Animation frame rate: 60 FPS
- Memory usage: < 200MB
- Network request time: < 1 second

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Team

- **Your Name** - Initial work

## 📞 Support

For support, email support@corporateempire.game or join our Discord server.

## 🗺️ Roadmap

### Phase 1: Core Mechanics (Current)
- ✅ Company creation and management
- ✅ Basic idle mechanics
- ✅ Upgrade system
- ⏳ Manager system implementation
- ⏳ Stock market basics

### Phase 2: Trading & Social
- ⏳ Full trading system
- ⏳ Portfolio analytics
- ⏳ Corporation creation
- ⏳ Friends system

### Phase 3: Advanced Features
- ⏳ Prestige system
- ⏳ Events and quests
- ⏳ Achievements
- ⏳ Leaderboards

### Phase 4: Polish & Monetization
- ⏳ IAP implementation
- ⏳ Balance tuning
- ⏳ Performance optimization
- ⏳ Beta testing

## 📚 Documentation

- [Architecture Guide](docs/ARCHITECTURE.md)
- [API Documentation](docs/API.md)
- [Game Design Document](docs/GDD.md)
- [Contributing Guidelines](docs/CONTRIBUTING.md)

---

Built with ❤️ using Swift and SwiftUI
