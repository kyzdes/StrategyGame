//
//  StartResearchUseCase.swift
//  CorporateEmpire
//
//  Use Case - Start researching a technology node (v2.0)
//

import Foundation

protocol StartResearchUseCase {
    func execute(nodeId: UUID, playerId: UUID) async throws -> ResearchNode
}

final class DefaultStartResearchUseCase: StartResearchUseCase {
    private let researchRepository: ResearchRepository
    private let playerRepository: PlayerRepository

    init(
        researchRepository: ResearchRepository,
        playerRepository: PlayerRepository
    ) {
        self.researchRepository = researchRepository
        self.playerRepository = playerRepository
    }

    func execute(nodeId: UUID, playerId: UUID) async throws -> ResearchNode {
        // Get research progress
        var progress = try await researchRepository.getResearchProgress(playerId: playerId)

        // Get the node
        var node = try await researchRepository.getResearchNode(id: nodeId)

        // Validate can research
        guard node.canBeResearched else {
            throw ResearchError.alreadyUnlocked
        }

        // Check prerequisites
        let prerequisites = node.prerequisites
        let unlockedNodes = progress.unlockedNodes

        for prerequisiteId in prerequisites {
            guard unlockedNodes.contains(prerequisiteId) else {
                throw ResearchError.prerequisitesNotMet
            }
        }

        // Check if can afford
        guard progress.availablePoints >= node.cost.points else {
            throw ResearchError.insufficientPoints
        }

        if let cash = node.cost.cash {
            let player = try await playerRepository.getPlayer(id: playerId)
            guard player.canAfford(cash: cash) else {
                throw ResearchError.insufficientFunds
            }

            // Deduct cash
            var updatedPlayer = player
            updatedPlayer.cash -= cash
            try await playerRepository.updatePlayer(updatedPlayer)
        }

        if let gems = node.cost.gems {
            let player = try await playerRepository.getPlayer(id: playerId)
            guard player.canAfford(gems: gems) else {
                throw ResearchError.insufficientGems
            }

            // Deduct gems
            var updatedPlayer = player
            updatedPlayer.gems -= gems
            try await playerRepository.updatePlayer(updatedPlayer)
        }

        // Start research
        node.isResearching = true
        progress.currentResearch = nodeId

        // Save
        try await researchRepository.updateNode(node)
        try await researchRepository.updateProgress(progress)

        return node
    }
}

enum ResearchError: LocalizedError {
    case nodeNotFound
    case alreadyUnlocked
    case prerequisitesNotMet
    case insufficientPoints
    case insufficientFunds
    case insufficientGems
    case alreadyResearching

    var errorDescription: String? {
        switch self {
        case .nodeNotFound:
            return "Research node not found"
        case .alreadyUnlocked:
            return "This research is already unlocked"
        case .prerequisitesNotMet:
            return "Prerequisites not met"
        case .insufficientPoints:
            return "Not enough research points"
        case .insufficientFunds:
            return "Insufficient cash"
        case .insufficientGems:
            return "Insufficient gems"
        case .alreadyResearching:
            return "Already researching another node"
        }
    }
}
