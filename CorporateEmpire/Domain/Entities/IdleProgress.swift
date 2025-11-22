//
//  IdleProgress.swift
//  CorporateEmpire
//
//  Domain Entity - Idle Game Mechanics
//

import Foundation

struct IdleRevenueResult: Codable, Equatable {
    let totalRevenue: Decimal
    let breakdown: [RevenueSource]
    let missedOpportunities: [Opportunity]
    let offlineDuration: TimeInterval
    let effectivenessPenalty: Double?

    init(
        totalRevenue: Decimal,
        breakdown: [RevenueSource],
        missedOpportunities: [Opportunity] = [],
        offlineDuration: TimeInterval,
        effectivenessPenalty: Double? = nil
    ) {
        self.totalRevenue = totalRevenue
        self.breakdown = breakdown
        self.missedOpportunities = missedOpportunities
        self.offlineDuration = offlineDuration
        self.effectivenessPenalty = effectivenessPenalty
    }

    var formattedDuration: String {
        let hours = Int(offlineDuration / 3600)
        let minutes = Int((offlineDuration.truncatingRemainder(dividingBy: 3600)) / 60)

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct RevenueSource: Codable, Equatable, Identifiable {
    let id: UUID
    let companyId: UUID
    let companyName: String
    let amount: Decimal
    let revenuePerSecond: Decimal
    let duration: TimeInterval

    init(
        id: UUID = UUID(),
        companyId: UUID,
        companyName: String,
        amount: Decimal,
        revenuePerSecond: Decimal,
        duration: TimeInterval
    ) {
        self.id = id
        self.companyId = companyId
        self.companyName = companyName
        self.amount = amount
        self.revenuePerSecond = revenuePerSecond
        self.duration = duration
    }
}

struct Opportunity: Codable, Equatable, Identifiable {
    let id: UUID
    let type: OpportunityType
    let description: String
    let potentialValue: Decimal
    let missedAt: Date

    init(
        id: UUID = UUID(),
        type: OpportunityType,
        description: String,
        potentialValue: Decimal,
        missedAt: Date
    ) {
        self.id = id
        self.type = type
        self.description = description
        self.potentialValue = potentialValue
        self.missedAt = missedAt
    }
}

enum OpportunityType: String, Codable {
    case marketEvent        // Special market conditions
    case tradeSignal        // Stock trading opportunity
    case limitedUpgrade     // Temporary upgrade discount
    case corporationProject // Corporation project deadline
    case dailyBonus         // Daily login reward

    var iconName: String {
        switch self {
        case .marketEvent: return "chart.line.uptrend.xyaxis"
        case .tradeSignal: return "dollarsign.circle"
        case .limitedUpgrade: return "tag.fill"
        case .corporationProject: return "building.2"
        case .dailyBonus: return "gift.fill"
        }
    }
}

// MARK: - Idle Configuration

struct IdleConfiguration: Codable, Equatable {
    /// Maximum offline time before effectiveness penalty (48 hours)
    let maxEffectiveOfflineTime: TimeInterval = 48 * 3600

    /// Time before effectiveness starts degrading (12 hours)
    let gracePeriod: TimeInterval = 12 * 3600

    /// Minimum effectiveness multiplier (never goes below 50%)
    let minEffectiveness: Double = 0.5

    /// Calculate effectiveness multiplier based on offline duration
    func calculateEffectiveness(duration: TimeInterval) -> Double {
        guard duration > gracePeriod else { return 1.0 }

        let overtimeDuration = duration - gracePeriod
        let maxOvertime = maxEffectiveOfflineTime - gracePeriod

        // Linear degradation from 1.0 to minEffectiveness
        let degradation = (overtimeDuration / maxOvertime) * (1.0 - minEffectiveness)
        return max(minEffectiveness, 1.0 - degradation)
    }

    /// Whether the offline period should show missed opportunities
    func shouldShowMissedOpportunities(duration: TimeInterval) -> Bool {
        return duration > gracePeriod
    }
}

// MARK: - Prestige System

struct PrestigeResult: Codable, Equatable {
    let prestigePoints: Int
    let unlockedPerks: [PrestigePerk]
    let permanentMultipliers: [PermanentMultiplier]
    let resetProgress: ResetProgress

    var totalPrestigeBonus: Double {
        permanentMultipliers.reduce(1.0) { $0 * $1.multiplier }
    }
}

struct PrestigePerk: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let effect: PerkEffect
    let cost: Int // Prestige points
    let tier: PrestigeTier
    let iconName: String
    var isUnlocked: Bool

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        effect: PerkEffect,
        cost: Int,
        tier: PrestigeTier,
        iconName: String,
        isUnlocked: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.effect = effect
        self.cost = cost
        self.tier = tier
        self.iconName = iconName
        self.isUnlocked = isUnlocked
    }
}

enum PrestigeTier: String, Codable {
    case bronze
    case silver
    case gold
    case platinum
    case diamond

    var displayName: String {
        rawValue.capitalized
    }

    var color: String {
        switch self {
        case .bronze: return "#CD7F32"
        case .silver: return "#C0C0C0"
        case .gold: return "#FFD700"
        case .platinum: return "#E5E4E2"
        case .diamond: return "#B9F2FF"
        }
    }

    var minimumPrestigeCount: Int {
        switch self {
        case .bronze: return 1
        case .silver: return 5
        case .gold: return 10
        case .platinum: return 25
        case .diamond: return 50
        }
    }
}

struct PermanentMultiplier: Identifiable, Codable, Equatable {
    let id: UUID
    let source: String
    let multiplier: Double
    let type: MultiplierType

    enum MultiplierType: String, Codable {
        case revenue
        case offlineEarnings
        case experience
        case prestigePoints
    }

    init(
        id: UUID = UUID(),
        source: String,
        multiplier: Double,
        type: MultiplierType
    ) {
        self.id = id
        self.source = source
        self.multiplier = multiplier
        self.type = type
    }
}

struct ResetProgress: Codable, Equatable {
    let previousNetWorth: Decimal
    let previousLevel: Int
    let companiesCreated: Int
    let achievementsKept: [UUID]
    let managersKept: [UUID]
}

// MARK: - Daily Rewards

struct DailyReward: Codable, Equatable, Identifiable {
    let id: UUID
    let day: Int
    let reward: Reward
    var isClaimed: Bool
    let claimDate: Date?

    init(
        id: UUID = UUID(),
        day: Int,
        reward: Reward,
        isClaimed: Bool = false,
        claimDate: Date? = nil
    ) {
        self.id = id
        self.day = day
        self.reward = reward
        self.isClaimed = isClaimed
        self.claimDate = claimDate
    }
}

struct Reward: Codable, Equatable {
    let type: RewardType
    let amount: Int
    let description: String

    enum RewardType: String, Codable {
        case cash
        case gems
        case manager
        case boost
        case prestigePoints
    }
}

// MARK: - Boost

struct Boost: Identifiable, Codable, Equatable {
    let id: UUID
    let type: BoostType
    let multiplier: Double
    let duration: TimeInterval
    let startedAt: Date
    var isActive: Bool

    var endsAt: Date {
        startedAt.addingTimeInterval(duration)
    }

    var remainingTime: TimeInterval {
        max(0, endsAt.timeIntervalSinceNow)
    }

    var progress: Double {
        let elapsed = Date().timeIntervalSince(startedAt)
        return min(1.0, elapsed / duration)
    }

    init(
        id: UUID = UUID(),
        type: BoostType,
        multiplier: Double,
        duration: TimeInterval,
        startedAt: Date = Date(),
        isActive: Bool = true
    ) {
        self.id = id
        self.type = type
        self.multiplier = multiplier
        self.duration = duration
        self.startedAt = startedAt
        self.isActive = isActive
    }
}

enum BoostType: String, Codable {
    case revenue
    case offline
    case experience
    case trading

    var displayName: String {
        switch self {
        case .revenue: return "Revenue Boost"
        case .offline: return "Offline Boost"
        case .experience: return "Experience Boost"
        case .trading: return "Trading Boost"
        }
    }

    var iconName: String {
        switch self {
        case .revenue: return "chart.line.uptrend.xyaxis"
        case .offline: return "moon.fill"
        case .experience: return "star.fill"
        case .trading: return "dollarsign.circle.fill"
        }
    }
}
