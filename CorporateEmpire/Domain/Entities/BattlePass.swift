//
//  BattlePass.swift
//  CorporateEmpire
//
//  Domain Entity - Battle Pass & Seasonal System (v2.0)
//

import Foundation

// MARK: - Season

struct Season: Identifiable, Codable, Equatable {
    let id: UUID
    let number: Int
    let name: String
    let theme: SeasonTheme
    let description: String

    let startDate: Date
    let endDate: Date

    let battlePass: BattlePass
    let events: [SeasonEvent]
    let challenges: [SeasonChallenge]

    var isActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }

    var daysRemaining: Int {
        let remaining = endDate.timeIntervalSinceNow
        return max(0, Int(remaining / 86400))
    }

    init(
        id: UUID = UUID(),
        number: Int,
        name: String,
        theme: SeasonTheme,
        description: String,
        startDate: Date,
        endDate: Date,
        battlePass: BattlePass,
        events: [SeasonEvent] = [],
        challenges: [SeasonChallenge] = []
    ) {
        self.id = id
        self.number = number
        self.name = name
        self.theme = theme
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.battlePass = battlePass
        self.events = events
        self.challenges = challenges
    }
}

enum SeasonTheme: String, Codable {
    case techBoom
    case globalExpansion
    case financialCrisis
    case holidayShopping

    var displayName: String {
        switch self {
        case .techBoom: return "Tech Boom"
        case .globalExpansion: return "Global Expansion"
        case .financialCrisis: return "Financial Crisis"
        case .holidayShopping: return "Holiday Shopping"
        }
    }

    var description: String {
        switch self {
        case .techBoom:
            return "Technology stocks soar! Triple gains in tech industry."
        case .globalExpansion:
            return "Go global! International markets unlock new opportunities."
        case .financialCrisis:
            return "Economic chaos! Survive the crash and profit from recovery."
        case .holidayShopping:
            return "Retail boom! Consumer spending reaches record highs."
        }
    }

    var modifier: IndustryModifier {
        switch self {
        case .techBoom:
            return IndustryModifier(industry: .technology, multiplier: 3.0)
        case .globalExpansion:
            return IndustryModifier(industry: .transportation, multiplier: 2.0)
        case .financialCrisis:
            return IndustryModifier(industry: .finance, multiplier: 0.5)
        case .holidayShopping:
            return IndustryModifier(industry: .retail, multiplier: 2.5)
        }
    }
}

struct IndustryModifier: Codable, Equatable {
    let industry: Industry
    let multiplier: Double
}

// MARK: - Battle Pass

struct BattlePass: Codable, Equatable {
    let seasonId: UUID
    let freeTrack: [BattlePassTier]
    let premiumTrack: [BattlePassTier]
    let price: Decimal

    init(
        seasonId: UUID,
        freeTrack: [BattlePassTier],
        premiumTrack: [BattlePassTier],
        price: Decimal = 9.99
    ) {
        self.seasonId = seasonId
        self.freeTrack = freeTrack
        self.premiumTrack = premiumTrack
        self.price = price
    }
}

struct BattlePassTier: Identifiable, Codable, Equatable {
    let id: UUID
    let tier: Int
    let xpRequired: Int
    let rewards: [BattlePassReward]

    init(
        id: UUID = UUID(),
        tier: Int,
        xpRequired: Int,
        rewards: [BattlePassReward]
    ) {
        self.id = id
        self.tier = tier
        self.xpRequired = xpRequired
        self.rewards = rewards
    }
}

struct BattlePassReward: Identifiable, Codable, Equatable {
    let id: UUID
    let type: RewardType
    let amount: Int
    let item: RewardItem?

    enum RewardType: String, Codable {
        case cash
        case gems
        case prestigePoints
        case manager
        case cosmetic
        case boost
        case researchPoints
    }

    enum RewardItem: Codable, Equatable {
        case manager(managerId: UUID)
        case skin(skinId: String)
        case emote(emoteId: String)
        case boost(boostType: BoostType, duration: TimeInterval)
    }

    init(
        id: UUID = UUID(),
        type: RewardType,
        amount: Int,
        item: RewardItem? = nil
    ) {
        self.id = id
        self.type = type
        self.amount = amount
        self.item = item
    }
}

struct BattlePassProgress: Codable, Equatable {
    let seasonId: UUID
    let playerId: UUID
    var isPremium: Bool

    var currentTier: Int
    var currentXP: Int
    var totalXP: Int

    var claimedTiers: Set<Int>
    var claimedPremiumTiers: Set<Int>

    mutating func addXP(_ amount: Int) {
        currentXP += amount
        totalXP += amount
        // Calculate new tier
        // Would need tier XP requirements
    }

    init(
        seasonId: UUID,
        playerId: UUID,
        isPremium: Bool = false,
        currentTier: Int = 0,
        currentXP: Int = 0,
        totalXP: Int = 0,
        claimedTiers: Set<Int> = [],
        claimedPremiumTiers: Set<Int> = []
    ) {
        self.seasonId = seasonId
        self.playerId = playerId
        self.isPremium = isPremium
        self.currentTier = currentTier
        self.currentXP = currentXP
        self.totalXP = totalXP
        self.claimedTiers = claimedTiers
        self.claimedPremiumTiers = claimedPremiumTiers
    }
}

// MARK: - Season Event

struct SeasonEvent: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let type: EventType
    let startTime: Date
    let endTime: Date
    var isActive: Bool

    let rewards: [EventReward]
    let objectives: [EventObjective]

    enum EventType: String, Codable {
        case marketCrash
        case ipoFrenzy
        case mergerMania
        case tradingCompetition
        case corporationWar
        case doubleXP
    }

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        type: EventType,
        startTime: Date,
        endTime: Date,
        isActive: Bool = false,
        rewards: [EventReward] = [],
        objectives: [EventObjective] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.type = type
        self.startTime = startTime
        self.endTime = endTime
        self.isActive = isActive
        self.rewards = rewards
        self.objectives = objectives
    }
}

struct EventReward: Codable, Equatable {
    let cash: Decimal?
    let gems: Int?
    let prestigePoints: Int?
    let exclusive: String? // Exclusive item ID
}

struct EventObjective: Identifiable, Codable, Equatable {
    let id: UUID
    let description: String
    let target: Int
    var progress: Int
    let reward: EventReward

    var isCompleted: Bool {
        progress >= target
    }

    init(
        id: UUID = UUID(),
        description: String,
        target: Int,
        progress: Int = 0,
        reward: EventReward
    ) {
        self.id = id
        self.description = description
        self.target = target
        self.progress = progress
        self.reward = reward
    }
}

// MARK: - Season Challenge

struct SeasonChallenge: Identifiable, Codable, Equatable {
    let id: UUID
    let period: ChallengePeriod
    let name: String
    let description: String
    let difficulty: ChallengeDifficulty

    let objectives: [ChallengeObjective]
    let reward: ChallengeReward
    let xpReward: Int

    var expiresAt: Date

    enum ChallengePeriod: String, Codable {
        case daily
        case weekly
        case seasonal
    }

    enum ChallengeDifficulty: String, Codable {
        case easy
        case medium
        case hard
        case epic

        var color: String {
            switch self {
            case .easy: return "#34C759"
            case .medium: return "#FFD700"
            case .hard: return "#FF9500"
            case .epic: return "#9C27B0"
            }
        }
    }

    init(
        id: UUID = UUID(),
        period: ChallengePeriod,
        name: String,
        description: String,
        difficulty: ChallengeDifficulty,
        objectives: [ChallengeObjective],
        reward: ChallengeReward,
        xpReward: Int,
        expiresAt: Date
    ) {
        self.id = id
        self.period = period
        self.name = name
        self.description = description
        self.difficulty = difficulty
        self.objectives = objectives
        self.reward = reward
        self.xpReward = xpReward
        self.expiresAt = expiresAt
    }
}

struct ChallengeObjective: Identifiable, Codable, Equatable {
    let id: UUID
    let type: ObjectiveType
    let description: String
    let target: Int
    var progress: Int

    var isCompleted: Bool {
        progress >= target
    }

    var progressPercentage: Double {
        Double(progress) / Double(target) * 100
    }

    enum ObjectiveType: String, Codable {
        case earnMoney
        case makeTrades
        case winArenas
        case upgradeCompanies
        case research
        case joinCorporation
        case helpFriends
    }

    init(
        id: UUID = UUID(),
        type: ObjectiveType,
        description: String,
        target: Int,
        progress: Int = 0
    ) {
        self.id = id
        self.type = type
        self.description = description
        self.target = target
        self.progress = progress
    }
}

struct ChallengeReward: Codable, Equatable {
    let cash: Decimal?
    let gems: Int?
    let prestigePoints: Int?
    let researchPoints: Int?
}
