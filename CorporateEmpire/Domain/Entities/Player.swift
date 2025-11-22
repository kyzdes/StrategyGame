//
//  Player.swift
//  CorporateEmpire
//
//  Domain Entity - Player
//

import Foundation

struct Player: Identifiable, Codable, Equatable {
    let id: UUID
    var username: String
    var email: String
    var avatarURL: String?

    var level: Int
    var experience: Int
    var cash: Decimal
    var gems: Int
    var prestigePoints: Int

    var createdAt: Date
    var lastLoginAt: Date
    var lastSyncAt: Date

    var companies: [UUID] // Company IDs owned by player
    var corporationId: UUID? // Corporation membership
    var friends: [UUID] // Friend player IDs

    var settings: PlayerSettings
    var statistics: PlayerStatistics

    init(
        id: UUID = UUID(),
        username: String,
        email: String,
        avatarURL: String? = nil,
        level: Int = 1,
        experience: Int = 0,
        cash: Decimal = 10_000, // Starting capital
        gems: Int = 100, // Starting premium currency
        prestigePoints: Int = 0,
        createdAt: Date = Date(),
        lastLoginAt: Date = Date(),
        lastSyncAt: Date = Date(),
        companies: [UUID] = [],
        corporationId: UUID? = nil,
        friends: [UUID] = [],
        settings: PlayerSettings = PlayerSettings(),
        statistics: PlayerStatistics = PlayerStatistics()
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.avatarURL = avatarURL
        self.level = level
        self.experience = experience
        self.cash = cash
        self.gems = gems
        self.prestigePoints = prestigePoints
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
        self.lastSyncAt = lastSyncAt
        self.companies = companies
        self.corporationId = corporationId
        self.friends = friends
        self.settings = settings
        self.statistics = statistics
    }

    /// Total net worth including cash, stocks, and company valuations
    func calculateNetWorth(
        companyValuations: Decimal,
        stockHoldingsValue: Decimal
    ) -> Decimal {
        return cash + companyValuations + stockHoldingsValue
    }

    /// Experience needed for next level
    var experienceForNextLevel: Int {
        return level * 5000
    }

    /// Progress to next level
    var levelProgress: Double {
        return Double(experience) / Double(experienceForNextLevel)
    }

    /// Check if player can afford a purchase
    func canAfford(cash amount: Decimal) -> Bool {
        return self.cash >= amount
    }

    func canAfford(gems amount: Int) -> Bool {
        return self.gems >= amount
    }
}

// MARK: - Player Settings

struct PlayerSettings: Codable, Equatable {
    var notificationsEnabled: Bool
    var soundEnabled: Bool
    var musicEnabled: Bool
    var hapticEnabled: Bool
    var pushNotificationsEnabled: Bool
    var privacyLevel: PrivacyLevel

    init(
        notificationsEnabled: Bool = true,
        soundEnabled: Bool = true,
        musicEnabled: Bool = true,
        hapticEnabled: Bool = true,
        pushNotificationsEnabled: Bool = true,
        privacyLevel: PrivacyLevel = .public
    ) {
        self.notificationsEnabled = notificationsEnabled
        self.soundEnabled = soundEnabled
        self.musicEnabled = musicEnabled
        self.hapticEnabled = hapticEnabled
        self.pushNotificationsEnabled = pushNotificationsEnabled
        self.privacyLevel = privacyLevel
    }
}

enum PrivacyLevel: String, Codable {
    case `public` // Profile visible to all
    case friendsOnly // Profile visible to friends
    case `private` // Profile hidden
}

// MARK: - Player Statistics

struct PlayerStatistics: Codable, Equatable {
    var totalCompaniesCreated: Int
    var totalTradesExecuted: Int
    var totalRevenuEarned: Decimal
    var totalDividendsReceived: Decimal
    var prestigeCount: Int
    var achievementsUnlocked: Int
    var daysPlayed: Int

    init(
        totalCompaniesCreated: Int = 0,
        totalTradesExecuted: Int = 0,
        totalRevenueEarned: Decimal = 0,
        totalDividendsReceived: Decimal = 0,
        prestigeCount: Int = 0,
        achievementsUnlocked: Int = 0,
        daysPlayed: Int = 0
    ) {
        self.totalCompaniesCreated = totalCompaniesCreated
        self.totalTradesExecuted = totalTradesExecuted
        self.totalRevenueEarned = totalRevenueEarned
        self.totalDividendsReceived = totalDividendsReceived
        self.prestigeCount = prestigeCount
        self.achievementsUnlocked = achievementsUnlocked
        self.daysPlayed = daysPlayed
    }
}

// MARK: - Player Profile (Public View)

struct PlayerProfile: Codable, Equatable {
    let id: UUID
    let username: String
    let avatarURL: String?
    let level: Int
    let netWorth: Decimal
    let corporationId: UUID?
    let statistics: PlayerStatistics
}
