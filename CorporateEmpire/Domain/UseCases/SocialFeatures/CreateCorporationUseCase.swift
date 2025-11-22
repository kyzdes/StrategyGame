//
//  CreateCorporationUseCase.swift
//  CorporateEmpire
//
//  Use Case - Create a corporation
//

import Foundation

protocol CreateCorporationUseCase {
    func execute(request: CorporationCreationRequest, founderId: UUID) async throws -> Corporation
}

final class DefaultCreateCorporationUseCase: CreateCorporationUseCase {
    private let corporationRepository: CorporationRepository
    private let playerRepository: PlayerRepository
    private let creationCost: Decimal

    init(
        corporationRepository: CorporationRepository,
        playerRepository: PlayerRepository,
        creationCost: Decimal = 100_000
    ) {
        self.corporationRepository = corporationRepository
        self.playerRepository = playerRepository
        self.creationCost = creationCost
    }

    func execute(request: CorporationCreationRequest, founderId: UUID) async throws -> Corporation {
        // Validate request
        try request.validate()

        // Get player
        var player = try await playerRepository.getPlayer(id: founderId)

        // Check if player already in a corporation
        guard player.corporationId == nil else {
            throw CorporationError.alreadyInCorporation
        }

        // Check if player has enough funds
        guard player.canAfford(cash: creationCost) else {
            throw CorporationValidationError.insufficientFunds
        }

        // Check for duplicate names/tickers
        let allCorporations = try await corporationRepository.getAllCorporations()
        if allCorporations.contains(where: { $0.name == request.name }) {
            throw CorporationValidationError.duplicateName
        }
        if allCorporations.contains(where: { $0.ticker == request.ticker }) {
            throw CorporationValidationError.duplicateTicker
        }

        // Create founder member
        let founderMember = CorporationMember(
            playerId: founderId,
            playerName: player.username,
            role: .founder,
            shares: 1000 // Founder gets initial shares
        )

        // Create corporation
        let corporation = Corporation(
            name: request.name,
            ticker: request.ticker,
            logo: request.logo,
            founderId: founderId,
            members: [founderMember],
            policies: request.policies,
            treasury: creationCost // Initial treasury from creation cost
        )

        // Save corporation
        try await corporationRepository.createCorporation(corporation)

        // Update player
        player.cash -= creationCost
        player.corporationId = corporation.id
        try await playerRepository.updatePlayer(player)

        return corporation
    }
}

enum CorporationError: LocalizedError {
    case notFound
    case alreadyInCorporation
    case notMember
    case insufficientPermissions
    case corporationFull

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Corporation not found"
        case .alreadyInCorporation:
            return "Already in a corporation"
        case .notMember:
            return "Not a member of this corporation"
        case .insufficientPermissions:
            return "Insufficient permissions"
        case .corporationFull:
            return "Corporation has reached maximum members"
        }
    }
}
