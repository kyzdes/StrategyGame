//
//  PurchaseUpgradeUseCase.swift
//  CorporateEmpire
//
//  Use Case - Purchase company upgrade
//

import Foundation

protocol PurchaseUpgradeUseCase {
    func execute(companyId: UUID, upgradeId: UUID, playerId: UUID) async throws -> (Company, Upgrade)
}

final class DefaultPurchaseUpgradeUseCase: PurchaseUpgradeUseCase {
    private let companyRepository: CompanyRepository
    private let playerRepository: PlayerRepository
    private let upgradeRepository: UpgradeRepository

    init(
        companyRepository: CompanyRepository,
        playerRepository: PlayerRepository,
        upgradeRepository: UpgradeRepository
    ) {
        self.companyRepository = companyRepository
        self.playerRepository = playerRepository
        self.upgradeRepository = upgradeRepository
    }

    func execute(companyId: UUID, upgradeId: UUID, playerId: UUID) async throws -> (Company, Upgrade) {
        // Get entities
        var company = try await companyRepository.getCompany(id: companyId)
        var player = try await playerRepository.getPlayer(id: playerId)
        var upgrade = try await upgradeRepository.getUpgrade(id: upgradeId)

        // Validate ownership
        guard company.ownerId == playerId else {
            throw CompanyError.notOwner
        }

        // Check level requirement
        guard company.level >= upgrade.unlockLevel else {
            throw UpgradeError.levelRequirementNotMet
        }

        // Check if already at max level
        guard !upgrade.isMaxLevel else {
            throw UpgradeError.maxLevelReached
        }

        // Calculate cost for next level
        let nextLevel = upgrade.currentLevel + 1
        let cost = upgrade.costForLevel(nextLevel)

        // Check if player can afford
        guard player.canAfford(cash: cost) else {
            throw UpgradeError.insufficientFunds
        }

        // Purchase upgrade
        player.cash -= cost
        upgrade.currentLevel = nextLevel

        // Add to company's upgrades if first purchase
        if !company.upgrades.contains(upgradeId) {
            company.upgrades.append(upgradeId)
        }

        // Save changes
        try await playerRepository.updatePlayer(player)
        try await upgradeRepository.updateUpgrade(upgrade)
        try await companyRepository.updateCompany(company)

        return (company, upgrade)
    }
}

enum CompanyError: LocalizedError {
    case notFound
    case notOwner
    case insufficientLevel

    var errorDescription: String? {
        switch self {
        case .notFound: return "Company not found"
        case .notOwner: return "You don't own this company"
        case .insufficientLevel: return "Company level too low"
        }
    }
}

enum UpgradeError: LocalizedError {
    case notFound
    case levelRequirementNotMet
    case insufficientFunds
    case maxLevelReached
    case alreadyPurchased

    var errorDescription: String? {
        switch self {
        case .notFound: return "Upgrade not found"
        case .levelRequirementNotMet: return "Company level requirement not met"
        case .insufficientFunds: return "Insufficient funds"
        case .maxLevelReached: return "Upgrade at maximum level"
        case .alreadyPurchased: return "Upgrade already purchased"
        }
    }
}
