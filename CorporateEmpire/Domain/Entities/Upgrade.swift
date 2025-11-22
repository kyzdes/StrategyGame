//
//  Upgrade.swift
//  CorporateEmpire
//
//  Domain Entity - Company Upgrades
//

import Foundation

protocol CompanyUpgrade {
    var id: UUID { get }
    var name: String { get }
    var description: String { get }
    var cost: Decimal { get }
    var revenueMultiplier: Double { get }
    var unlockLevel: Int { get }
    var category: UpgradeCategory { get }
}

struct Upgrade: CompanyUpgrade, Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    var cost: Decimal
    let revenueMultiplier: Double
    let unlockLevel: Int
    let category: UpgradeCategory
    let industry: Industry?

    var currentLevel: Int
    var maxLevel: Int

    var isPurchased: Bool {
        currentLevel > 0
    }

    var isMaxLevel: Bool {
        currentLevel >= maxLevel
    }

    /// Calculate cost for next level
    func costForLevel(_ level: Int) -> Decimal {
        let baseCost = cost
        let multiplier = pow(1.15, Double(level - 1))
        return baseCost * Decimal(multiplier)
    }

    /// Calculate total multiplier at current level
    var totalMultiplier: Double {
        guard isPurchased else { return 1.0 }
        return pow(revenueMultiplier, Double(currentLevel))
    }

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        cost: Decimal,
        revenueMultiplier: Double,
        unlockLevel: Int,
        category: UpgradeCategory,
        industry: Industry? = nil,
        currentLevel: Int = 0,
        maxLevel: Int = 100
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.cost = cost
        self.revenueMultiplier = revenueMultiplier
        self.unlockLevel = unlockLevel
        self.category = category
        self.industry = industry
        self.currentLevel = currentLevel
        self.maxLevel = maxLevel
    }
}

enum UpgradeCategory: String, Codable {
    case automation
    case efficiency
    case expansion
    case innovation
    case management

    var displayName: String {
        switch self {
        case .automation: return "Automation"
        case .efficiency: return "Efficiency"
        case .expansion: return "Expansion"
        case .innovation: return "Innovation"
        case .management: return "Management"
        }
    }

    var description: String {
        switch self {
        case .automation:
            return "Increases offline revenue generation"
        case .efficiency:
            return "Reduces production time and costs"
        case .expansion:
            return "Opens new revenue streams"
        case .innovation:
            return "Unique bonuses specific to your industry"
        case .management:
            return "Unlocks manager slots and bonuses"
        }
    }

    var iconName: String {
        switch self {
        case .automation: return "gearshape.2"
        case .efficiency: return "speedometer"
        case .expansion: return "arrow.up.right.square"
        case .innovation: return "lightbulb"
        case .management: return "person.2"
        }
    }
}

// MARK: - Upgrade Tiers

enum UpgradeTier: String, Codable {
    case basic      // Level 1-10
    case advanced   // Level 11-25
    case elite      // Level 26-50
    case prestige   // Level 51+

    var levelRange: ClosedRange<Int> {
        switch self {
        case .basic: return 1...10
        case .advanced: return 11...25
        case .elite: return 26...50
        case .prestige: return 51...100
        }
    }

    var multiplierBonus: Double {
        switch self {
        case .basic: return 1.0
        case .advanced: return 1.5
        case .elite: return 2.0
        case .prestige: return 3.0
        }
    }
}

// MARK: - Predefined Upgrades

extension Upgrade {
    static func automationUpgrades() -> [Upgrade] {
        return [
            Upgrade(
                name: "Auto-Collector",
                description: "Automatically collect revenue every hour",
                cost: 1_000,
                revenueMultiplier: 1.2,
                unlockLevel: 1,
                category: .automation,
                maxLevel: 10
            ),
            Upgrade(
                name: "Smart Algorithms",
                description: "AI-powered optimization increases offline earnings",
                cost: 10_000,
                revenueMultiplier: 1.5,
                unlockLevel: 5,
                category: .automation,
                maxLevel: 20
            ),
            Upgrade(
                name: "24/7 Operations",
                description: "Your company never sleeps",
                cost: 100_000,
                revenueMultiplier: 2.0,
                unlockLevel: 10,
                category: .automation,
                maxLevel: 15
            )
        ]
    }

    static func efficiencyUpgrades() -> [Upgrade] {
        return [
            Upgrade(
                name: "Lean Manufacturing",
                description: "Reduce waste, increase output",
                cost: 5_000,
                revenueMultiplier: 1.3,
                unlockLevel: 3,
                category: .efficiency,
                maxLevel: 15
            ),
            Upgrade(
                name: "Supply Chain Optimization",
                description: "Streamlined logistics boost profits",
                cost: 25_000,
                revenueMultiplier: 1.4,
                unlockLevel: 8,
                category: .efficiency,
                maxLevel: 20
            )
        ]
    }

    static func expansionUpgrades() -> [Upgrade] {
        return [
            Upgrade(
                name: "Market Expansion",
                description: "Enter new markets and demographics",
                cost: 50_000,
                revenueMultiplier: 1.5,
                unlockLevel: 10,
                category: .expansion,
                maxLevel: 10
            ),
            Upgrade(
                name: "International Division",
                description: "Go global with worldwide operations",
                cost: 500_000,
                revenueMultiplier: 2.0,
                unlockLevel: 20,
                category: .expansion,
                maxLevel: 5
            )
        ]
    }

    static func technologyInnovations() -> [Upgrade] {
        return [
            Upgrade(
                name: "Cloud Infrastructure",
                description: "Scalable tech infrastructure",
                cost: 15_000,
                revenueMultiplier: 1.6,
                unlockLevel: 5,
                category: .innovation,
                industry: .technology,
                maxLevel: 25
            ),
            Upgrade(
                name: "AI Research Lab",
                description: "Cutting-edge AI development",
                cost: 200_000,
                revenueMultiplier: 2.5,
                unlockLevel: 15,
                category: .innovation,
                industry: .technology,
                maxLevel: 10
            )
        ]
    }
}
