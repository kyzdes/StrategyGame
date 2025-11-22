//
//  StockRepository.swift
//  CorporateEmpire
//
//  Repository Protocol - Stock and Trading data access
//

import Foundation
import Combine

protocol StockRepository {
    /// Get stock by ticker
    func getStock(ticker: String) async throws -> Stock

    /// Get multiple stocks
    func getStocks(tickers: [String]) async throws -> [Stock]

    /// Get all available stocks
    func getAllStocks() async throws -> [Stock]

    /// Get stocks by industry
    func getStocksByIndustry(_ industry: Industry) async throws -> [Stock]

    /// Save/update stock data
    func updateStock(_ stock: Stock) async throws

    /// Get stock price history
    func getStockHistory(ticker: String, period: TimePeriod) async throws -> [StockDataPoint]

    /// Save order
    func saveOrder(_ order: StockOrder) async throws

    /// Get order by ID
    func getOrder(id: UUID) async throws -> StockOrder

    /// Get player's orders
    func getOrders(playerId: UUID, status: OrderStatus?) async throws -> [StockOrder]

    /// Cancel order
    func cancelOrder(id: UUID) async throws

    /// Get market conditions
    func getMarketConditions() async throws -> MarketConditions

    /// Subscribe to real-time stock updates
    func subscribeToStockUpdates(tickers: [String]) -> AnyPublisher<StockUpdate, Never>

    /// Get top movers (gainers/losers)
    func getTopMovers(limit: Int) async throws -> TopMovers
}

// MARK: - Supporting Types

enum TimePeriod: String {
    case day = "1D"
    case week = "1W"
    case month = "1M"
    case year = "1Y"
    case all = "ALL"
}

struct StockDataPoint: Codable, Equatable {
    let timestamp: Date
    let price: Decimal
    let volume: Int
}

struct TopMovers: Codable, Equatable {
    let gainers: [Stock]
    let losers: [Stock]
    let mostActive: [Stock]
}
