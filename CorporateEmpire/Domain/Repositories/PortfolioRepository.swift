//
//  PortfolioRepository.swift
//  CorporateEmpire
//
//  Repository Protocol - Portfolio data access
//

import Foundation
import Combine

protocol PortfolioRepository {
    /// Get player's portfolio
    func getPortfolio(playerId: UUID) async throws -> Portfolio

    /// Add stock holding to portfolio
    func addHolding(playerId: UUID, ticker: String, quantity: Int, price: Decimal) async throws

    /// Remove stock holding from portfolio
    func removeHolding(playerId: UUID, ticker: String, quantity: Int, price: Decimal) async throws

    /// Get holding for specific stock
    func getHolding(playerId: UUID, ticker: String) async throws -> StockHolding?

    /// Update portfolio analytics
    func updatePortfolioAnalytics(playerId: UUID) async throws

    /// Get portfolio history
    func getPortfolioHistory(playerId: UUID, period: TimePeriod) async throws -> [PortfolioSnapshot]

    /// Observe portfolio changes
    func observePortfolio(playerId: UUID) -> AnyPublisher<Portfolio, Error>
}

struct PortfolioSnapshot: Codable, Equatable {
    let timestamp: Date
    let totalValue: Decimal
    let unrealizedPL: Decimal
}
