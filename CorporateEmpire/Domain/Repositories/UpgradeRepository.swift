//
//  UpgradeRepository.swift
//  CorporateEmpire
//
//  Repository Protocol - Upgrade data access
//

import Foundation

protocol UpgradeRepository {
    /// Get upgrade by ID
    func getUpgrade(id: UUID) async throws -> Upgrade

    /// Get multiple upgrades by IDs
    func getUpgrades(ids: [UUID]) async throws -> [Upgrade]

    /// Get all available upgrades
    func getAllUpgrades() async throws -> [Upgrade]

    /// Get upgrades by category
    func getUpgradesByCategory(_ category: UpgradeCategory) async throws -> [Upgrade]

    /// Get upgrades available for company level
    func getAvailableUpgrades(forLevel level: Int) async throws -> [Upgrade]

    /// Get upgrades for specific industry
    func getIndustryUpgrades(_ industry: Industry) async throws -> [Upgrade]

    /// Update upgrade (typically to increase level)
    func updateUpgrade(_ upgrade: Upgrade) async throws

    /// Get player's purchased upgrades for a company
    func getPurchasedUpgrades(companyId: UUID) async throws -> [Upgrade]
}
