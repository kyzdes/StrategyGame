//
//  CorporationRepository.swift
//  CorporateEmpire
//
//  Repository Protocol - Corporation data access
//

import Foundation
import Combine

protocol CorporationRepository {
    /// Get corporation by ID
    func getCorporation(id: UUID) async throws -> Corporation

    /// Get all corporations
    func getAllCorporations() async throws -> [Corporation]

    /// Create new corporation
    func createCorporation(_ corporation: Corporation) async throws

    /// Update corporation
    func updateCorporation(_ corporation: Corporation) async throws

    /// Delete corporation
    func deleteCorporation(id: UUID) async throws

    /// Search corporations
    func searchCorporations(query: String) async throws -> [Corporation]

    /// Get top corporations by level
    func getTopCorporations(limit: Int) async throws -> [Corporation]

    /// Add member to corporation
    func addMember(corporationId: UUID, member: CorporationMember) async throws

    /// Remove member from corporation
    func removeMember(corporationId: UUID, memberId: UUID) async throws

    /// Update member role
    func updateMemberRole(corporationId: UUID, memberId: UUID, role: MemberRole) async throws

    /// Get corporation projects
    func getProjects(corporationId: UUID) async throws -> [CorporationProject]

    /// Create project
    func createProject(corporationId: UUID, project: CorporationProject) async throws

    /// Update project
    func updateProject(_ project: CorporationProject) async throws

    /// Contribute to project
    func contributeToProject(projectId: UUID, playerId: UUID, amount: Decimal) async throws

    /// Get available perks
    func getAvailablePerks(corporationId: UUID) async throws -> [CorporationPerk]

    /// Unlock perk
    func unlockPerk(corporationId: UUID, perkId: UUID) async throws

    /// Observe corporation changes
    func observeCorporation(id: UUID) -> AnyPublisher<Corporation, Error>
}
