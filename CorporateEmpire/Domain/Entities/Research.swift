//
//  Research.swift
//  CorporateEmpire
//
//  Domain Entity - Research & Technology Tree (v2.0)
//

import Foundation

// MARK: - Research Node

struct ResearchNode: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let branch: ResearchBranch
    let tier: Int // 1-5
    let position: NodePosition // For UI layout

    var cost: ResearchCost
    var isUnlocked: Bool
    var isResearching: Bool
    var progress: Double // 0.0 - 1.0
    var completedAt: Date?

    let prerequisites: [UUID] // Required nodes
    let unlocks: [ResearchUnlock]
    let icon: String

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        branch: ResearchBranch,
        tier: Int,
        position: NodePosition,
        cost: ResearchCost,
        isUnlocked: Bool = false,
        isResearching: Bool = false,
        progress: Double = 0,
        completedAt: Date? = nil,
        prerequisites: [UUID] = [],
        unlocks: [ResearchUnlock],
        icon: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.branch = branch
        self.tier = tier
        self.position = position
        self.cost = cost
        self.isUnlocked = isUnlocked
        self.isResearching = isResearching
        self.progress = progress
        self.completedAt = completedAt
        self.prerequisites = prerequisites
        self.unlocks = unlocks
        self.icon = icon
    }

    var isCompleted: Bool {
        completedAt != nil
    }

    var canBeResearched: Bool {
        !isCompleted && !isUnlocked && !isResearching
    }

    var remainingTime: TimeInterval? {
        guard isResearching else { return nil }
        let total = cost.timeRequired
        let elapsed = total * progress
        return total - elapsed
    }
}

struct NodePosition: Codable, Equatable {
    let x: Int // Column
    let y: Int // Row
}

// MARK: - Research Branch

enum ResearchBranch: String, Codable, CaseIterable {
    case automation
    case intelligence
    case expansion
    case innovation
    case influence

    var displayName: String {
        switch self {
        case .automation: return "Automation"
        case .intelligence: return "Intelligence"
        case .expansion: return "Expansion"
        case .innovation: return "Innovation"
        case .influence: return "Influence"
        }
    }

    var description: String {
        switch self {
        case .automation:
            return "Automate your empire. Unlock offline bonuses and idle efficiency."
        case .intelligence:
            return "Gain market insights. Predict trends and make smarter decisions."
        case .expansion:
            return "Grow your reach. Unlock new industries and global markets."
        case .innovation:
            return "Revolutionary tech. Game-changing abilities and unique mechanics."
        case .influence:
            return "Social power. Corporation bonuses and competitive advantages."
        }
    }

    var color: String {
        switch self {
        case .automation: return "#4CAF50" // Green
        case .intelligence: return "#2196F3" // Blue
        case .expansion: return "#FF9800" // Orange
        case .innovation: return "#9C27B0" // Purple
        case .influence: return "#F44336" // Red
        }
    }

    var icon: String {
        switch self {
        case .automation: return "gearshape.2.fill"
        case .intelligence: return "brain.head.profile"
        case .expansion: return "arrow.up.right.square.fill"
        case .innovation: return "lightbulb.fill"
        case .influence: return "person.3.fill"
        }
    }
}

// MARK: - Research Cost

struct ResearchCost: Codable, Equatable {
    let points: Int
    let cash: Decimal?
    let gems: Int?
    let timeRequired: TimeInterval // in seconds

    init(
        points: Int,
        cash: Decimal? = nil,
        gems: Int? = nil,
        timeRequired: TimeInterval
    ) {
        self.points = points
        self.cash = cash
        self.gems = gems
        self.timeRequired = timeRequired
    }
}

// MARK: - Research Unlock

enum ResearchUnlock: Codable, Equatable {
    case multiplier(MultiplierType, Double)
    case feature(FeatureUnlock)
    case capacity(CapacityType, Int)
    case ability(AbilityUnlock)

    var displayText: String {
        switch self {
        case .multiplier(let type, let value):
            return "+\(Int(value * 100))% \(type.displayName)"
        case .feature(let feature):
            return "Unlock: \(feature.displayName)"
        case .capacity(let type, let amount):
            return "+\(amount) \(type.displayName)"
        case .ability(let ability):
            return "Gain: \(ability.displayName)"
        }
    }
}

enum MultiplierType: String, Codable {
    case offlineEarnings
    case activeEarnings
    case researchSpeed
    case upgradeCost
    case managerEfficiency
    case tradingProfit
    case corporationBonus

    var displayName: String {
        switch self {
        case .offlineEarnings: return "Offline Earnings"
        case .activeEarnings: return "Active Earnings"
        case .researchSpeed: return "Research Speed"
        case .upgradeCost: return "Upgrade Cost Reduction"
        case .managerEfficiency: return "Manager Efficiency"
        case .tradingProfit: return "Trading Profit"
        case .corporationBonus: return "Corporation Bonus"
        }
    }
}

enum FeatureUnlock: String, Codable {
    case autoCollect
    case aiAdvisor
    case stockPredictions
    case autoUpgrade
    case advancedAnalytics
    case customization
    case multiCompanies
    case globalMarkets
    case stockShortSelling
    case corporationWars
    case mergersAcquisitions
    case miniGames

    var displayName: String {
        switch self {
        case .autoCollect: return "Auto-Collect"
        case .aiAdvisor: return "AI Advisor"
        case .stockPredictions: return "Stock Predictions"
        case .autoUpgrade: return "Auto-Upgrade"
        case .advancedAnalytics: return "Advanced Analytics"
        case .customization: return "Customization"
        case .multiCompanies: return "Multiple Companies"
        case .globalMarkets: return "Global Markets"
        case .stockShortSelling: return "Short Selling"
        case .corporationWars: return "Corporation Wars"
        case .mergersAcquisitions: return "M&A System"
        case .miniGames: return "Mini-Games"
        }
    }
}

enum CapacityType: String, Codable {
    case companySlots
    case managerSlots
    case corporationMembers
    case portfolioSize

    var displayName: String {
        switch self {
        case .companySlots: return "Company Slots"
        case .managerSlots: return "Manager Slots"
        case .corporationMembers: return "Corporation Members"
        case .portfolioSize: return "Portfolio Size"
        }
    }
}

enum AbilityUnlock: String, Codable {
    case marketManipulation
    case insiderTrading
    case hostileTakeover
    case fastPrestige
    case luckyBonus
    case criticalUpgrade

    var displayName: String {
        switch self {
        case .marketManipulation: return "Market Manipulation"
        case .insiderTrading: return "Insider Trading"
        case .hostileTakeover: return "Hostile Takeover"
        case .fastPrestige: return "Fast Prestige"
        case .luckyBonus: return "Lucky Bonus"
        case .criticalUpgrade: return "Critical Upgrade"
        }
    }

    var description: String {
        switch self {
        case .marketManipulation:
            return "Temporarily influence stock prices in your favor"
        case .insiderTrading:
            return "Get early info on stock movements (30sec advantage)"
        case .hostileTakeover:
            return "Force acquire other players' companies"
        case .fastPrestige:
            return "Prestige with 50% more points"
        case .luckyBonus:
            return "10% chance for 2x rewards"
        case .criticalUpgrade:
            return "5% chance upgrades cost 50% less"
        }
    }
}

// MARK: - Research Progress

struct ResearchProgress: Codable, Equatable {
    let playerId: UUID
    var totalPoints: Int
    var spentPoints: Int
    var availablePoints: Int

    var unlockedNodes: Set<UUID>
    var currentResearch: UUID?

    // Branch completion
    var automationTier: Int
    var intelligenceTier: Int
    var expansionTier: Int
    var innovationTier: Int
    var influenceTier: Int

    mutating func unlockNode(_ nodeId: UUID, cost: Int) {
        unlockedNodes.insert(nodeId)
        spentPoints += cost
        availablePoints -= cost
    }

    var completionPercentage: Double {
        Double(unlockedNodes.count) / Double(ResearchTreeFactory.totalNodes)
    }

    init(
        playerId: UUID,
        totalPoints: Int = 0,
        spentPoints: Int = 0,
        availablePoints: Int = 0,
        unlockedNodes: Set<UUID> = [],
        currentResearch: UUID? = nil,
        automationTier: Int = 0,
        intelligenceTier: Int = 0,
        expansionTier: Int = 0,
        innovationTier: Int = 0,
        influenceTier: Int = 0
    ) {
        self.playerId = playerId
        self.totalPoints = totalPoints
        self.spentPoints = spentPoints
        self.availablePoints = availablePoints
        self.unlockedNodes = unlockedNodes
        self.currentResearch = currentResearch
        self.automationTier = automationTier
        self.intelligenceTier = intelligenceTier
        self.expansionTier = expansionTier
        self.innovationTier = innovationTier
        self.influenceTier = influenceTier
    }
}

// MARK: - Research Tree Factory

struct ResearchTreeFactory {
    static let totalNodes = 125 // 25 nodes per branch

    static func createFullTree() -> [ResearchNode] {
        return automationBranch() +
               intelligenceBranch() +
               expansionBranch() +
               innovationBranch() +
               influenceBranch()
    }

    // MARK: - Automation Branch

    static func automationBranch() -> [ResearchNode] {
        return [
            // Tier 1
            ResearchNode(
                name: "Basic Automation",
                description: "Enable auto-collect for offline earnings",
                branch: .automation,
                tier: 1,
                position: NodePosition(x: 0, y: 0),
                cost: ResearchCost(points: 10, timeRequired: 300),
                unlocks: [.feature(.autoCollect)],
                icon: "arrow.triangle.2.circlepath"
            ),

            ResearchNode(
                name: "Efficient Idle",
                description: "Increase offline earnings by 25%",
                branch: .automation,
                tier: 1,
                position: NodePosition(x: 1, y: 0),
                cost: ResearchCost(points: 15, timeRequired: 600),
                unlocks: [.multiplier(.offlineEarnings, 0.25)],
                icon: "moon.stars.fill"
            ),

            // Tier 2
            ResearchNode(
                name: "Smart Collect",
                description: "Auto-collect every 5 minutes",
                branch: .automation,
                tier: 2,
                position: NodePosition(x: 0, y: 1),
                cost: ResearchCost(points: 25, cash: 100_000, timeRequired: 1800),
                unlocks: [.multiplier(.offlineEarnings, 0.5)],
                icon: "timer"
            ),

            ResearchNode(
                name: "Manager AI",
                description: "Managers work 30% more efficiently",
                branch: .automation,
                tier: 2,
                position: NodePosition(x: 1, y: 1),
                cost: ResearchCost(points: 30, timeRequired: 3600),
                unlocks: [.multiplier(.managerEfficiency, 0.3)],
                icon: "brain"
            ),

            // Tier 3
            ResearchNode(
                name: "Auto-Upgrade",
                description: "Automatically purchase optimal upgrades",
                branch: .automation,
                tier: 3,
                position: NodePosition(x: 0, y: 2),
                cost: ResearchCost(points: 50, cash: 1_000_000, timeRequired: 7200),
                unlocks: [.feature(.autoUpgrade)],
                icon: "sparkles"
            )
        ]
    }

    // MARK: - Intelligence Branch

    static func intelligenceBranch() -> [ResearchNode] {
        return [
            ResearchNode(
                name: "Market Analysis",
                description: "Basic stock market insights",
                branch: .intelligence,
                tier: 1,
                position: NodePosition(x: 0, y: 0),
                cost: ResearchCost(points: 10, timeRequired: 300),
                unlocks: [.multiplier(.tradingProfit, 0.1)],
                icon: "chart.line.uptrend.xyaxis"
            ),

            ResearchNode(
                name: "AI Advisor",
                description: "Unlock your personal AI trading advisor",
                branch: .intelligence,
                tier: 2,
                position: NodePosition(x: 1, y: 0),
                cost: ResearchCost(points: 30, timeRequired: 1800),
                unlocks: [.feature(.aiAdvisor)],
                icon: "person.fill.checkmark"
            ),

            ResearchNode(
                name: "Predictive Models",
                description: "70% accurate stock predictions",
                branch: .intelligence,
                tier: 3,
                position: NodePosition(x: 2, y: 0),
                cost: ResearchCost(points: 50, cash: 500_000, timeRequired: 5400),
                unlocks: [.feature(.stockPredictions)],
                icon: "crystal.ball.fill"
            ),

            ResearchNode(
                name: "Insider Info",
                description: "Get 30-second advance stock updates",
                branch: .intelligence,
                tier: 4,
                position: NodePosition(x: 3, y: 0),
                cost: ResearchCost(points: 100, gems: 50, timeRequired: 10800),
                unlocks: [.ability(.insiderTrading)],
                icon: "eye.fill"
            )
        ]
    }

    // MARK: - Expansion Branch

    static func expansionBranch() -> [ResearchNode] {
        return [
            ResearchNode(
                name: "Multi-Company",
                description: "Run up to 3 companies simultaneously",
                branch: .expansion,
                tier: 1,
                position: NodePosition(x: 0, y: 0),
                cost: ResearchCost(points: 20, timeRequired: 600),
                unlocks: [.capacity(.companySlots, 2)],
                icon: "building.2.fill"
            ),

            ResearchNode(
                name: "Global Markets",
                description: "Access international stock markets",
                branch: .expansion,
                tier: 2,
                position: NodePosition(x: 1, y: 0),
                cost: ResearchCost(points: 40, cash: 250_000, timeRequired: 3600),
                unlocks: [.feature(.globalMarkets)],
                icon: "globe"
            ),

            ResearchNode(
                name: "M&A Basics",
                description: "Unlock mergers and acquisitions",
                branch: .expansion,
                tier: 3,
                position: NodePosition(x: 2, y: 0),
                cost: ResearchCost(points: 75, cash: 1_000_000, timeRequired: 7200),
                unlocks: [.feature(.mergersAcquisitions)],
                icon: "arrow.triangle.merge"
            )
        ]
    }

    // MARK: - Innovation Branch

    static func innovationBranch() -> [ResearchNode] {
        return [
            ResearchNode(
                name: "Lucky Streak",
                description: "10% chance for double rewards",
                branch: .innovation,
                tier: 1,
                position: NodePosition(x: 0, y: 0),
                cost: ResearchCost(points: 25, timeRequired: 900),
                unlocks: [.ability(.luckyBonus)],
                icon: "star.fill"
            ),

            ResearchNode(
                name: "Critical Thinking",
                description: "5% chance upgrades cost 50% less",
                branch: .innovation,
                tier: 2,
                position: NodePosition(x: 1, y: 0),
                cost: ResearchCost(points: 50, timeRequired: 3600),
                unlocks: [.ability(.criticalUpgrade)],
                icon: "bolt.fill"
            )
        ]
    }

    // MARK: - Influence Branch

    static func influenceBranch() -> [ResearchNode] {
        return [
            ResearchNode(
                name: "Social Network",
                description: "Unlock corporation features",
                branch: .influence,
                tier: 1,
                position: NodePosition(x: 0, y: 0),
                cost: ResearchCost(points: 15, timeRequired: 600),
                unlocks: [.multiplier(.corporationBonus, 0.1)],
                icon: "person.3.fill"
            ),

            ResearchNode(
                name: "War Economy",
                description: "Enable corporation wars",
                branch: .influence,
                tier: 3,
                position: NodePosition(x: 2, y: 0),
                cost: ResearchCost(points: 100, cash: 5_000_000, timeRequired: 14400),
                unlocks: [.feature(.corporationWars)],
                icon: "shield.fill"
            )
        ]
    }
}
