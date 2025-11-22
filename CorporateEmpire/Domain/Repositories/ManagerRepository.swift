//
//  ManagerRepository.swift
//  CorporateEmpire
//
//  Repository Protocol - Manager data access
//

import Foundation

protocol ManagerRepository {
    /// Get manager by ID
    func getManager(id: UUID) async throws -> Manager

    /// Get multiple managers by IDs
    func getManagers(ids: [UUID]) async throws -> [Manager]

    /// Get all available managers
    func getAllManagers() async throws -> [Manager]

    /// Get managers by rarity
    func getManagersByRarity(_ rarity: ManagerRarity) async throws -> [Manager]

    /// Get managers by specialization
    func getManagersByIndustry(_ industry: Industry) async throws -> [Manager]

    /// Get player's hired managers
    func getHiredManagers(playerId: UUID) async throws -> [Manager]

    /// Hire manager
    func hireManager(id: UUID, playerId: UUID) async throws

    /// Update manager (level up, assign to company)
    func updateManager(_ manager: Manager) async throws

    /// Assign manager to company
    func assignManager(managerId: UUID, companyId: UUID) async throws

    /// Unassign manager from company
    func unassignManager(managerId: UUID) async throws

    /// Upgrade manager level
    func upgradeManager(id: UUID) async throws -> Manager
}
