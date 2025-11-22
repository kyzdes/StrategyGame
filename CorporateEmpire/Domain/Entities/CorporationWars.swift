//
//  CorporationWars.swift
//  CorporateEmpire
//
//  Domain Entity - Corporation Wars System (v2.0)
//

import Foundation

// MARK: - Corporation War

struct CorporationWar: Identifiable, Codable, Equatable {
    let id: UUID
    let attackerId: UUID
    let defenderId: UUID

    var attackerName: String
    var defenderName: String

    let startDate: Date
    let endDate: Date
    var status: WarStatus

    var attackerScore: Int
    var defenderScore: Int

    let warChest: WarChest
    let stakes: WarStakes
    let battlefronts: [Battlefront]

    var declaredAt: Date
    var votedMembers: [UUID] // Members who voted to declare war

    var winner: UUID?
    var rewards: WarRewards?

    init(
        id: UUID = UUID(),
        attackerId: UUID,
        defenderId: UUID,
        attackerName: String,
        defenderName: String,
        startDate: Date,
        endDate: Date,
        status: WarStatus = .declared,
        attackerScore: Int = 0,
        defenderScore: Int = 0,
        warChest: WarChest,
        stakes: WarStakes,
        battlefronts: [Battlefront],
        declaredAt: Date = Date(),
        votedMembers: [UUID] = [],
        winner: UUID? = nil,
        rewards: WarRewards? = nil
    ) {
        self.id = id
        self.attackerId = attackerId
        self.defenderId = defenderId
        self.attackerName = attackerName
        self.defenderName = defenderName
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.attackerScore = attackerScore
        self.defenderScore = defenderScore
        self.warChest = warChest
        self.stakes = stakes
        self.battlefronts = battlefronts
        self.declaredAt = declaredAt
        self.votedMembers = votedMembers
        self.winner = winner
        self.rewards = rewards
    }

    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }

    var remainingTime: TimeInterval {
        max(0, endDate.timeIntervalSinceNow)
    }

    var isActive: Bool {
        status == .active && Date() < endDate
    }
}

enum WarStatus: String, Codable {
    case declared      // War declared, preparing
    case active        // War in progress
    case finished      // War ended
    case cancelled     // War cancelled

    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - War Chest

struct WarChest: Codable, Equatable {
    var attackerFunds: Decimal
    var defenderFunds: Decimal

    let minimumContribution: Decimal
    var contributions: [WarContribution]

    mutating func addContribution(_ contribution: WarContribution, side: WarSide) {
        contributions.append(contribution)
        switch side {
        case .attacker:
            attackerFunds += contribution.amount
        case .defender:
            defenderFunds += contribution.amount
        }
    }

    init(
        attackerFunds: Decimal = 0,
        defenderFunds: Decimal = 0,
        minimumContribution: Decimal = 10_000,
        contributions: [WarContribution] = []
    ) {
        self.attackerFunds = attackerFunds
        self.defenderFunds = defenderFunds
        self.minimumContribution = minimumContribution
        self.contributions = contributions
    }
}

struct WarContribution: Identifiable, Codable, Equatable {
    let id: UUID
    let playerId: UUID
    let playerName: String
    let amount: Decimal
    let timestamp: Date

    init(
        id: UUID = UUID(),
        playerId: UUID,
        playerName: String,
        amount: Decimal,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.playerId = playerId
        self.playerName = playerName
        self.amount = amount
        self.timestamp = timestamp
    }
}

enum WarSide: String, Codable {
    case attacker
    case defender
}

// MARK: - War Stakes

struct WarStakes: Codable, Equatable {
    let territories: [Territory]
    let resources: WarResources
    let prestigePoints: Int
    let winnerBonus: WinnerBonus

    struct WarResources: Codable, Equatable {
        let cash: Decimal
        let gems: Int
        let researchPoints: Int
    }

    struct WinnerBonus: Codable, Equatable {
        let cashMultiplier: Double    // e.g., 1.5x for 7 days
        let bonusDuration: TimeInterval
        let territoryControl: Int      // Number of territories
        let exclusivePerk: String?     // Perk ID
    }

    init(
        territories: [Territory],
        resources: WarResources,
        prestigePoints: Int,
        winnerBonus: WinnerBonus
    ) {
        self.territories = territories
        self.resources = resources
        self.prestigePoints = prestigePoints
        self.winnerBonus = winnerBonus
    }
}

// MARK: - Territory

struct Territory: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let region: WorldRegion
    let description: String

    var controller: UUID? // Corporation ID
    let bonuses: [TerritoryBonus]

    let captureRequirement: Int // Points needed to capture

    init(
        id: UUID = UUID(),
        name: String,
        region: WorldRegion,
        description: String,
        controller: UUID? = nil,
        bonuses: [TerritoryBonus],
        captureRequirement: Int
    ) {
        self.id = id
        self.name = name
        self.region = region
        self.description = description
        self.controller = controller
        self.bonuses = bonuses
        self.captureRequirement = captureRequirement
    }
}

enum WorldRegion: String, Codable {
    case northAmerica
    case southAmerica
    case europe
    case asia
    case africa
    case oceania

    var displayName: String {
        switch self {
        case .northAmerica: return "North America"
        case .southAmerica: return "South America"
        case .europe: return "Europe"
        case .asia: return "Asia"
        case .africa: return "Africa"
        case .oceania: return "Oceania"
        }
    }
}

struct TerritoryBonus: Codable, Equatable {
    let type: BonusType
    let value: Double

    enum BonusType: String, Codable {
        case revenueBoost
        case tradingDiscount
        case researchSpeed
        case recruitmentBonus
        case prestigeBonus
    }
}

// MARK: - Battlefront

struct Battlefront: Identifiable, Codable, Equatable {
    let id: UUID
    let type: BattlefrontType
    let name: String
    let description: String

    var attackerProgress: Int
    var defenderProgress: Int
    let targetProgress: Int

    var winner: WarSide?
    var pointsAwarded: Int

    init(
        id: UUID = UUID(),
        type: BattlefrontType,
        name: String,
        description: String,
        attackerProgress: Int = 0,
        defenderProgress: Int = 0,
        targetProgress: Int,
        winner: WarSide? = nil,
        pointsAwarded: Int = 0
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.description = description
        self.attackerProgress = attackerProgress
        self.defenderProgress = defenderProgress
        self.targetProgress = targetProgress
        self.winner = winner
        self.pointsAwarded = pointsAwarded
    }
}

enum BattlefrontType: String, Codable {
    case economicWarfare   // Generate most revenue
    case stockManipulation // Control stock prices
    case recruitment       // Recruit most members
    case trading           // Most profitable trades
    case espionage         // Complete spy missions

    var displayName: String {
        switch self {
        case .economicWarfare: return "Economic Warfare"
        case .stockManipulation: return "Stock Manipulation"
        case .recruitment: return "Recruitment"
        case .trading: return "Trading Competition"
        case .espionage: return "Espionage"
        }
    }

    var icon: String {
        switch self {
        case .economicWarfare: return "dollarsign.circle.fill"
        case .stockManipulation: return "chart.line.uptrend.xyaxis"
        case .recruitment: return "person.3.fill"
        case .trading: return "arrow.left.arrow.right"
        case .espionage: return "eye.slash.fill"
        }
    }
}

// MARK: - War Action

struct WarAction: Identifiable, Codable, Equatable {
    let id: UUID
    let warId: UUID
    let playerId: UUID
    let playerName: String
    let side: WarSide

    let action: ActionType
    let battlefrontId: UUID?
    let pointsEarned: Int

    let timestamp: Date

    enum ActionType: String, Codable {
        case earnedRevenue
        case completedTrade
        case recruitedMember
        case completedMission
        case donatedFunds
        case capturedTerritory
    }

    init(
        id: UUID = UUID(),
        warId: UUID,
        playerId: UUID,
        playerName: String,
        side: WarSide,
        action: ActionType,
        battlefrontId: UUID? = nil,
        pointsEarned: Int,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.warId = warId
        self.playerId = playerId
        self.playerName = playerName
        self.side = side
        self.action = action
        self.battlefrontId = battlefrontId
        self.pointsEarned = pointsEarned
        self.timestamp = timestamp
    }
}

// MARK: - War Rewards

struct WarRewards: Codable, Equatable {
    let winnerCash: Decimal
    let winnerGems: Int
    let winnerPrestigePoints: Int
    let territories: [UUID] // Territory IDs
    let perk: String? // Exclusive perk ID

    let loserConsolation: ConsolationRewards

    struct ConsolationRewards: Codable, Equatable {
        let cash: Decimal
        let gems: Int
        let prestigePoints: Int
    }

    init(
        winnerCash: Decimal,
        winnerGems: Int,
        winnerPrestigePoints: Int,
        territories: [UUID],
        perk: String?,
        loserConsolation: ConsolationRewards
    ) {
        self.winnerCash = winnerCash
        self.winnerGems = winnerGems
        self.winnerPrestigePoints = winnerPrestigePoints
        self.territories = territories
        self.perk = perk
        self.loserConsolation = loserConsolation
    }
}

// MARK: - War Statistics

struct WarStatistics: Codable, Equatable {
    let corporationId: UUID
    var warsParticipated: Int
    var warsWon: Int
    var warsLost: Int
    var territoriesControlled: Int
    var totalPointsEarned: Int
    var mvpCount: Int // Times player was MVP

    var winRate: Double {
        let total = warsWon + warsLost
        guard total > 0 else { return 0 }
        return Double(warsWon) / Double(total) * 100
    }

    init(
        corporationId: UUID,
        warsParticipated: Int = 0,
        warsWon: Int = 0,
        warsLost: Int = 0,
        territoriesControlled: Int = 0,
        totalPointsEarned: Int = 0,
        mvpCount: Int = 0
    ) {
        self.corporationId = corporationId
        self.warsParticipated = warsParticipated
        self.warsWon = warsWon
        self.warsLost = warsLost
        self.territoriesControlled = territoriesControlled
        self.totalPointsEarned = totalPointsEarned
        self.mvpCount = mvpCount
    }
}
