//
//  AIAdvisor.swift
//  CorporateEmpire
//
//  Domain Entity - AI Advisor System (v2.0)
//

import Foundation

// MARK: - AI Advisor

struct AIAdvisor: Codable, Equatable {
    let playerId: UUID
    var name: String
    var personality: AdvisorPersonality
    var avatar: String

    var learningData: LearningData
    var recommendations: [Recommendation]
    var predictions: [Prediction]

    var isEnabled: Bool
    var lastUpdate: Date

    init(
        playerId: UUID,
        name: String = "Ada",
        personality: AdvisorPersonality = .balanced,
        avatar: String = "ai_advisor_default",
        learningData: LearningData = LearningData(),
        recommendations: [Recommendation] = [],
        predictions: [Prediction] = [],
        isEnabled: Bool = true,
        lastUpdate: Date = Date()
    ) {
        self.playerId = playerId
        self.name = name
        self.personality = personality
        self.avatar = avatar
        self.learningData = learningData
        self.recommendations = recommendations
        self.predictions = predictions
        self.isEnabled = isEnabled
        self.lastUpdate = lastUpdate
    }
}

// MARK: - Advisor Personality

enum AdvisorPersonality: String, Codable, CaseIterable {
    case conservative
    case balanced
    case aggressive
    case datadriven

    var displayName: String {
        switch self {
        case .conservative: return "Conservative"
        case .balanced: return "Balanced"
        case .aggressive: return "Aggressive"
        case .datadriven: return "Data-Driven"
        }
    }

    var description: String {
        switch self {
        case .conservative:
            return "Focus on safe, steady growth. Lower risk, consistent returns."
        case .balanced:
            return "Mix of growth and stability. Moderate risk tolerance."
        case .aggressive:
            return "High-risk, high-reward strategies. Maximum growth potential."
        case .datadriven:
            return "Pure analytics. Emotion-free, algorithm-based decisions."
        }
    }

    var riskTolerance: Double {
        switch self {
        case .conservative: return 0.3
        case .balanced: return 0.5
        case .aggressive: return 0.8
        case .datadriven: return 0.6
        }
    }
}

// MARK: - Learning Data

struct LearningData: Codable, Equatable {
    var favoriteIndustries: [Industry: Double] // Industry -> preference score
    var tradingPatterns: TradingPatterns
    var playstyle: PlaystyleAnalysis
    var successRates: [String: Double]

    var totalInteractions: Int
    var feedbackScore: Double // 0-1, how often player follows advice

    init(
        favoriteIndustries: [Industry: Double] = [:],
        tradingPatterns: TradingPatterns = TradingPatterns(),
        playstyle: PlaystyleAnalysis = PlaystyleAnalysis(),
        successRates: [String: Double] = [:],
        totalInteractions: Int = 0,
        feedbackScore: Double = 0.5
    ) {
        self.favoriteIndustries = favoriteIndustries
        self.tradingPatterns = tradingPatterns
        self.playstyle = playstyle
        self.successRates = successRates
        self.totalInteractions = totalInteractions
        self.feedbackScore = feedbackScore
    }
}

struct TradingPatterns: Codable, Equatable {
    var averageHoldTime: TimeInterval
    var preferredTradeSize: Decimal
    var dayTrader: Bool // Quick trades vs long-term holds
    var sectorFocus: [Industry]

    init(
        averageHoldTime: TimeInterval = 0,
        preferredTradeSize: Decimal = 0,
        dayTrader: Bool = false,
        sectorFocus: [Industry] = []
    ) {
        self.averageHoldTime = averageHoldTime
        self.preferredTradeSize = preferredTradeSize
        self.dayTrader = dayTrader
        self.sectorFocus = sectorFocus
    }
}

struct PlaystyleAnalysis: Codable, Equatable {
    var activePlayer: Bool // Plays frequently vs passive
    var competitivePlayer: Bool // Joins PvP vs solo
    var socialPlayer: Bool // Corporation member, friends
    var collectorPlayer: Bool // Unlocks everything, completionist

    init(
        activePlayer: Bool = false,
        competitivePlayer: Bool = false,
        socialPlayer: Bool = false,
        collectorPlayer: Bool = false
    ) {
        self.activePlayer = activePlayer
        self.competitivePlayer = competitivePlayer
        self.socialPlayer = socialPlayer
        self.collectorPlayer = collectorPlayer
    }
}

// MARK: - Recommendation

struct Recommendation: Identifiable, Codable, Equatable {
    let id: UUID
    let type: RecommendationType
    let priority: RecommendationPriority
    let title: String
    let description: String
    let reasoning: String

    let action: RecommendedAction
    let expectedOutcome: String
    let confidence: Double // 0-1

    let createdAt: Date
    var expiresAt: Date?
    var wasFollowed: Bool?
    var actualOutcome: String?

    init(
        id: UUID = UUID(),
        type: RecommendationType,
        priority: RecommendationPriority,
        title: String,
        description: String,
        reasoning: String,
        action: RecommendedAction,
        expectedOutcome: String,
        confidence: Double,
        createdAt: Date = Date(),
        expiresAt: Date? = nil,
        wasFollowed: Bool? = nil,
        actualOutcome: String? = nil
    ) {
        self.id = id
        self.type = type
        self.priority = priority
        self.title = title
        self.description = description
        self.reasoning = reasoning
        self.action = action
        self.expectedOutcome = expectedOutcome
        self.confidence = confidence
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.wasFollowed = wasFollowed
        self.actualOutcome = actualOutcome
    }
}

enum RecommendationType: String, Codable {
    case trade
    case upgrade
    case research
    case prestige
    case corporation
    case event

    var icon: String {
        switch self {
        case .trade: return "chart.line.uptrend.xyaxis"
        case .upgrade: return "arrow.up.circle.fill"
        case .research: return "brain"
        case .prestige: return "star.fill"
        case .corporation: return "building.2.fill"
        case .event: return "calendar.badge.exclamationmark"
        }
    }
}

enum RecommendationPriority: String, Codable {
    case critical
    case high
    case medium
    case low

    var color: String {
        switch self {
        case .critical: return "#FF3B30" // Red
        case .high: return "#FF9500" // Orange
        case .medium: return "#FFD700" // Yellow
        case .low: return "#34C759" // Green
        }
    }
}

enum RecommendedAction: Codable, Equatable {
    case buyStock(ticker: String, quantity: Int, price: Decimal)
    case sellStock(ticker: String, quantity: Int, reason: String)
    case upgradeCompany(companyId: UUID, upgradeId: UUID)
    case researchNode(nodeId: UUID)
    case prestigeNow(reason: String)
    case joinArena(arenaType: ArenaType)
    case completeCampaign(chapterId: Int)
    case joinCorporation(corporationId: UUID)

    var actionText: String {
        switch self {
        case .buyStock(let ticker, let quantity, let price):
            return "Buy \(quantity) shares of \(ticker) at $\(price)"
        case .sellStock(let ticker, let quantity, _):
            return "Sell \(quantity) shares of \(ticker)"
        case .upgradeCompany:
            return "Upgrade company"
        case .researchNode:
            return "Research technology"
        case .prestigeNow:
            return "Prestige now"
        case .joinArena(let type):
            return "Join \(type.displayName)"
        case .completeCampaign:
            return "Continue campaign"
        case .joinCorporation:
            return "Join corporation"
        }
    }
}

// MARK: - Prediction

struct Prediction: Identifiable, Codable, Equatable {
    let id: UUID
    let type: PredictionType
    let subject: String // Stock ticker or entity ID
    let prediction: String
    let timeframe: TimeInterval
    let confidence: Double

    let createdAt: Date
    let validUntil: Date

    var wasAccurate: Bool?

    init(
        id: UUID = UUID(),
        type: PredictionType,
        subject: String,
        prediction: String,
        timeframe: TimeInterval,
        confidence: Double,
        createdAt: Date = Date(),
        validUntil: Date,
        wasAccurate: Bool? = nil
    ) {
        self.id = id
        self.type = type
        self.subject = subject
        self.prediction = prediction
        self.timeframe = timeframe
        self.confidence = confidence
        self.createdAt = createdAt
        self.validUntil = validUntil
        self.wasAccurate = wasAccurate
    }
}

enum PredictionType: String, Codable {
    case stockPrice
    case marketTrend
    case companyGrowth
    case prestigeRecommendation

    var displayName: String {
        switch self {
        case .stockPrice: return "Stock Price"
        case .marketTrend: return "Market Trend"
        case .companyGrowth: return "Company Growth"
        case .prestigeRecommendation: return "Prestige Timing"
        }
    }
}

// MARK: - Auto-Optimization Settings

struct AutoOptimizationSettings: Codable, Equatable {
    var autoAssignManagers: Bool
    var autoUpgrade: Bool
    var autoTrade: Bool
    var autoCollect: Bool
    var autoPrestige: Bool

    // Auto-trade limits
    var maxTradeAmount: Decimal
    var maxDailyTrades: Int
    var onlyFollowHighConfidence: Bool // Only trades with >70% confidence

    // Auto-upgrade settings
    var priorityCategory: UpgradeCategory?
    var maxUpgradeSpend: Decimal?

    init(
        autoAssignManagers: Bool = false,
        autoUpgrade: Bool = false,
        autoTrade: Bool = false,
        autoCollect: Bool = true,
        autoPrestige: Bool = false,
        maxTradeAmount: Decimal = 10000,
        maxDailyTrades: Int = 10,
        onlyFollowHighConfidence: Bool = true,
        priorityCategory: UpgradeCategory? = nil,
        maxUpgradeSpend: Decimal? = nil
    ) {
        self.autoAssignManagers = autoAssignManagers
        self.autoUpgrade = autoUpgrade
        self.autoTrade = autoTrade
        self.autoCollect = autoCollect
        self.autoPrestige = autoPrestige
        self.maxTradeAmount = maxTradeAmount
        self.maxDailyTrades = maxDailyTrades
        self.onlyFollowHighConfidence = onlyFollowHighConfidence
        self.priorityCategory = priorityCategory
        self.maxUpgradeSpend = maxUpgradeSpend
    }
}

// MARK: - Insight

struct AIInsight: Identifiable, Codable, Equatable {
    let id: UUID
    let category: InsightCategory
    let title: String
    let message: String
    let icon: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        category: InsightCategory,
        title: String,
        message: String,
        icon: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.message = message
        self.icon = icon
        self.createdAt = createdAt
    }
}

enum InsightCategory: String, Codable {
    case achievement
    case warning
    case tip
    case milestone

    var color: String {
        switch self {
        case .achievement: return "#FFD700"
        case .warning: return "#FF9500"
        case .tip: return "#007AFF"
        case .milestone: return "#9C27B0"
        }
    }
}
