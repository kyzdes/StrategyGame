//
//  ResearchRepository.swift
//  CorporateEmpire
//
//  Repository Protocol - Research & Tech Tree data access (v2.0)
//

import Foundation
import Combine

protocol ResearchRepository {
    /// Get all research nodes
    func getAllNodes() async throws -> [ResearchNode]

    /// Get single research node
    func getResearchNode(id: UUID) async throws -> ResearchNode

    /// Get nodes by branch
    func getNodesByBranch(_ branch: ResearchBranch) async throws -> [ResearchNode]

    /// Update research node
    func updateNode(_ node: ResearchNode) async throws

    /// Get player's research progress
    func getResearchProgress(playerId: UUID) async throws -> ResearchProgress

    /// Update research progress
    func updateProgress(_ progress: ResearchProgress) async throws

    /// Award research points
    func awardPoints(playerId: UUID, points: Int) async throws

    /// Complete research node
    func completeResearch(nodeId: UUID, playerId: UUID) async throws

    /// Get active multipliers for player
    func getActiveMultipliers(playerId: UUID) async throws -> [MultiplierType: Double]

    /// Check if feature is unlocked
    func isFeatureUnlocked(playerId: UUID, feature: FeatureUnlock) async throws -> Bool

    /// Observe research progress
    func observeProgress(playerId: UUID) -> AnyPublisher<ResearchProgress, Error>
}
