//
//  PlayerDTO.swift
//  CorporateEmpire
//
//  Data Transfer Object - Player
//

import Foundation

struct PlayerDTO: Codable {
    let id: String
    let username: String
    let email: String
    let avatarURL: String?
    let level: Int
    let experience: Int
    let cash: String // Decimal as String for precision
    let gems: Int
    let prestigePoints: Int
    let createdAt: String
    let lastLoginAt: String
    let lastSyncAt: String
    let companies: [String] // UUID strings
    let corporationId: String?
    let friends: [String] // UUID strings
    let settings: PlayerSettingsDTO
    let statistics: PlayerStatisticsDTO

    // MARK: - Mapping

    func toDomain() -> Player {
        return Player(
            id: UUID(uuidString: id) ?? UUID(),
            username: username,
            email: email,
            avatarURL: avatarURL,
            level: level,
            experience: experience,
            cash: Decimal(string: cash) ?? 0,
            gems: gems,
            prestigePoints: prestigePoints,
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date(),
            lastLoginAt: ISO8601DateFormatter().date(from: lastLoginAt) ?? Date(),
            lastSyncAt: ISO8601DateFormatter().date(from: lastSyncAt) ?? Date(),
            companies: companies.compactMap { UUID(uuidString: $0) },
            corporationId: corporationId.flatMap { UUID(uuidString: $0) },
            friends: friends.compactMap { UUID(uuidString: $0) },
            settings: settings.toDomain(),
            statistics: statistics.toDomain()
        )
    }

    static func fromDomain(_ player: Player) -> PlayerDTO {
        let formatter = ISO8601DateFormatter()

        return PlayerDTO(
            id: player.id.uuidString,
            username: player.username,
            email: player.email,
            avatarURL: player.avatarURL,
            level: player.level,
            experience: player.experience,
            cash: "\(player.cash)",
            gems: player.gems,
            prestigePoints: player.prestigePoints,
            createdAt: formatter.string(from: player.createdAt),
            lastLoginAt: formatter.string(from: player.lastLoginAt),
            lastSyncAt: formatter.string(from: player.lastSyncAt),
            companies: player.companies.map { $0.uuidString },
            corporationId: player.corporationId?.uuidString,
            friends: player.friends.map { $0.uuidString },
            settings: PlayerSettingsDTO.fromDomain(player.settings),
            statistics: PlayerStatisticsDTO.fromDomain(player.statistics)
        )
    }
}

struct PlayerSettingsDTO: Codable {
    let notificationsEnabled: Bool
    let soundEnabled: Bool
    let musicEnabled: Bool
    let hapticEnabled: Bool
    let pushNotificationsEnabled: Bool
    let privacyLevel: String

    func toDomain() -> PlayerSettings {
        return PlayerSettings(
            notificationsEnabled: notificationsEnabled,
            soundEnabled: soundEnabled,
            musicEnabled: musicEnabled,
            hapticEnabled: hapticEnabled,
            pushNotificationsEnabled: pushNotificationsEnabled,
            privacyLevel: PrivacyLevel(rawValue: privacyLevel) ?? .public
        )
    }

    static func fromDomain(_ settings: PlayerSettings) -> PlayerSettingsDTO {
        return PlayerSettingsDTO(
            notificationsEnabled: settings.notificationsEnabled,
            soundEnabled: settings.soundEnabled,
            musicEnabled: settings.musicEnabled,
            hapticEnabled: settings.hapticEnabled,
            pushNotificationsEnabled: settings.pushNotificationsEnabled,
            privacyLevel: settings.privacyLevel.rawValue
        )
    }
}

struct PlayerStatisticsDTO: Codable {
    let totalCompaniesCreated: Int
    let totalTradesExecuted: Int
    let totalRevenueEarned: String
    let totalDividendsReceived: String
    let prestigeCount: Int
    let achievementsUnlocked: Int
    let daysPlayed: Int

    func toDomain() -> PlayerStatistics {
        return PlayerStatistics(
            totalCompaniesCreated: totalCompaniesCreated,
            totalTradesExecuted: totalTradesExecuted,
            totalRevenueEarned: Decimal(string: totalRevenueEarned) ?? 0,
            totalDividendsReceived: Decimal(string: totalDividendsReceived) ?? 0,
            prestigeCount: prestigeCount,
            achievementsUnlocked: achievementsUnlocked,
            daysPlayed: daysPlayed
        )
    }

    static func fromDomain(_ stats: PlayerStatistics) -> PlayerStatisticsDTO {
        return PlayerStatisticsDTO(
            totalCompaniesCreated: stats.totalCompaniesCreated,
            totalTradesExecuted: stats.totalTradesExecuted,
            totalRevenueEarned: "\(stats.totalRevenueEarned)",
            totalDividendsReceived: "\(stats.totalDividendsReceived)",
            prestigeCount: stats.prestigeCount,
            achievementsUnlocked: stats.achievementsUnlocked,
            daysPlayed: stats.daysPlayed
        )
    }
}
