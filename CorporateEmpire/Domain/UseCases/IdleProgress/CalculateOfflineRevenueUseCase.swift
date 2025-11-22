//
//  CalculateOfflineRevenueUseCase.swift
//  CorporateEmpire
//
//  Use Case - Calculate offline/idle revenue
//

import Foundation

protocol CalculateOfflineRevenueUseCase {
    func execute(playerId: UUID) async throws -> IdleRevenueResult
}

final class DefaultCalculateOfflineRevenueUseCase: CalculateOfflineRevenueUseCase {
    private let companyRepository: CompanyRepository
    private let playerRepository: PlayerRepository
    private let managerRepository: ManagerRepository
    private let upgradeRepository: UpgradeRepository
    private let idleConfig: IdleConfiguration

    init(
        companyRepository: CompanyRepository,
        playerRepository: PlayerRepository,
        managerRepository: ManagerRepository,
        upgradeRepository: UpgradeRepository,
        idleConfig: IdleConfiguration = IdleConfiguration()
    ) {
        self.companyRepository = companyRepository
        self.playerRepository = playerRepository
        self.managerRepository = managerRepository
        self.upgradeRepository = upgradeRepository
        self.idleConfig = idleConfig
    }

    func execute(playerId: UUID) async throws -> IdleRevenueResult {
        let player = try await playerRepository.getPlayer(id: playerId)
        let companies = try await companyRepository.getCompaniesByOwner(ownerId: playerId)

        // Calculate offline duration
        let now = Date()
        let offlineDuration = now.timeIntervalSince(player.lastSyncAt)

        // Calculate effectiveness based on duration
        let effectiveness = idleConfig.calculateEffectiveness(duration: offlineDuration)

        var breakdown: [RevenueSource] = []
        var totalRevenue: Decimal = 0
        var missedOpportunities: [Opportunity] = []

        // Calculate revenue for each company
        for var company in companies {
            // Get company's upgrades
            let upgrades = try await upgradeRepository.getUpgrades(ids: company.upgrades)
            let upgradeMultiplier = upgrades.reduce(1.0) { result, upgrade in
                result * upgrade.totalMultiplier
            }

            // Get company's managers
            let managers = try await managerRepository.getManagers(ids: company.managers)
            let managerMultiplier = managers.reduce(1.0) { result, manager in
                result * manager.totalMultiplier
            }

            // Get prestige bonus (would come from player's prestige perks)
            let prestigeBonus = calculatePrestigeBonus(player: player)

            // Calculate revenue per second
            let revenuePerSecond = company.calculateRevenuePerSecond(
                upgradeMultiplier: upgradeMultiplier,
                managerMultiplier: managerMultiplier,
                prestigeBonus: prestigeBonus
            )

            // Apply offline duration and effectiveness
            let effectiveDuration = offlineDuration * effectiveness
            let companyRevenue = revenuePerSecond * Decimal(effectiveDuration)

            totalRevenue += companyRevenue

            breakdown.append(RevenueSource(
                companyId: company.id,
                companyName: company.name,
                amount: companyRevenue,
                revenuePerSecond: revenuePerSecond,
                duration: effectiveDuration
            ))

            // Update company's last calculation time
            company.lastRevenueCalculation = now
            try await companyRepository.updateCompany(company)
        }

        // Check for missed opportunities
        if idleConfig.shouldShowMissedOpportunities(duration: offlineDuration) {
            missedOpportunities = generateMissedOpportunities(
                offlineDuration: offlineDuration,
                player: player
            )
        }

        // Update player's cash and sync time
        var updatedPlayer = player
        updatedPlayer.cash += totalRevenue
        updatedPlayer.lastSyncAt = now
        updatedPlayer.statistics.totalRevenueEarned += totalRevenue
        try await playerRepository.updatePlayer(updatedPlayer)

        return IdleRevenueResult(
            totalRevenue: totalRevenue,
            breakdown: breakdown,
            missedOpportunities: missedOpportunities,
            offlineDuration: offlineDuration,
            effectivenessPenalty: effectiveness < 1.0 ? effectiveness : nil
        )
    }

    private func calculatePrestigeBonus(player: Player) -> Double {
        // Calculate total prestige bonus from player's unlocked perks
        // This would be implemented based on player's prestige perks
        return 1.0 + Double(player.prestigePoints) * 0.01
    }

    private func generateMissedOpportunities(
        offlineDuration: TimeInterval,
        player: Player
    ) -> [Opportunity] {
        var opportunities: [Opportunity] = []

        // Example: Daily bonus
        let daysMissed = Int(offlineDuration / (24 * 3600))
        if daysMissed > 0 {
            opportunities.append(Opportunity(
                type: .dailyBonus,
                description: "Missed \(daysMissed) daily login bonus(es)",
                potentialValue: Decimal(daysMissed * 1000),
                missedAt: Date().addingTimeInterval(-offlineDuration)
            ))
        }

        // Example: Limited time events
        if offlineDuration > 12 * 3600 {
            opportunities.append(Opportunity(
                type: .limitedUpgrade,
                description: "Flash sale on premium upgrades",
                potentialValue: Decimal(5000),
                missedAt: Date().addingTimeInterval(-offlineDuration / 2)
            ))
        }

        return opportunities
    }
}
