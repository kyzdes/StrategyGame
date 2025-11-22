//
//  PlaceOrderUseCase.swift
//  CorporateEmpire
//
//  Use Case - Place a stock order
//

import Foundation

protocol PlaceOrderUseCase {
    func execute(order: StockOrder) async throws -> OrderResult
}

final class DefaultPlaceOrderUseCase: PlaceOrderUseCase {
    private let stockRepository: StockRepository
    private let playerRepository: PlayerRepository
    private let portfolioRepository: PortfolioRepository
    private let tradingEngine: TradingEngine

    init(
        stockRepository: StockRepository,
        playerRepository: PlayerRepository,
        portfolioRepository: PortfolioRepository,
        tradingEngine: TradingEngine
    ) {
        self.stockRepository = stockRepository
        self.playerRepository = playerRepository
        self.portfolioRepository = portfolioRepository
        self.tradingEngine = tradingEngine
    }

    func execute(order: StockOrder) async throws -> OrderResult {
        // Get player
        var player = try await playerRepository.getPlayer(id: order.playerId)

        // Get stock
        let stock = try await stockRepository.getStock(ticker: order.ticker)

        // Validate order
        try validateOrder(order: order, stock: stock, player: player)

        // Process order based on type
        let result: OrderResult

        switch order.type {
        case .market:
            result = try await processMarketOrder(order: order, stock: stock, player: &player)

        case .limit, .stopLoss, .takeProfit:
            result = try await processLimitOrder(order: order, stock: stock, player: &player)
        }

        // Update player statistics
        if result.status == .filled || result.status == .partiallyFilled {
            player.statistics.totalTradesExecuted += 1
            try await playerRepository.updatePlayer(player)
        }

        return result
    }

    private func validateOrder(order: StockOrder, stock: Stock, player: Player) throws {
        // Validate quantity
        guard order.quantity > 0 else {
            throw TradingError.invalidQuantity
        }

        // Validate based on order side
        switch order.side {
        case .buy:
            // Check if player has enough cash
            let estimatedCost = stock.currentPrice * Decimal(order.quantity)
            let commission = tradingEngine.calculateCommission(amount: estimatedCost)
            let totalCost = estimatedCost + commission

            guard player.canAfford(cash: totalCost) else {
                throw TradingError.insufficientFunds
            }

        case .sell:
            // Check if player owns enough shares
            let portfolio = try await portfolioRepository.getPortfolio(playerId: player.id)
            guard let holding = portfolio.holdings.first(where: { $0.ticker == order.ticker }),
                  holding.quantity >= order.quantity else {
                throw TradingError.insufficientShares
            }
        }

        // Validate limit price
        if let limitPrice = order.price {
            guard limitPrice > 0 else {
                throw TradingError.invalidPrice
            }
        }
    }

    private func processMarketOrder(
        order: StockOrder,
        stock: Stock,
        player: inout Player
    ) async throws -> OrderResult {
        let currentPrice = stock.currentPrice
        let totalAmount = currentPrice * Decimal(order.quantity)
        let commission = tradingEngine.calculateCommission(amount: totalAmount)

        var updatedOrder = order
        updatedOrder.status = .filled
        updatedOrder.filledQuantity = order.quantity
        updatedOrder.filledAt = Date()

        switch order.side {
        case .buy:
            // Deduct cash
            let totalCost = totalAmount + commission
            player.cash -= totalCost

            // Add to portfolio
            try await portfolioRepository.addHolding(
                playerId: player.id,
                ticker: order.ticker,
                quantity: order.quantity,
                price: currentPrice
            )

        case .sell:
            // Add cash
            let totalProceeds = totalAmount - commission
            player.cash += totalProceeds

            // Remove from portfolio
            try await portfolioRepository.removeHolding(
                playerId: player.id,
                ticker: order.ticker,
                quantity: order.quantity,
                price: currentPrice
            )
        }

        // Save order
        try await stockRepository.saveOrder(updatedOrder)

        // Update player
        try await playerRepository.updatePlayer(player)

        return OrderResult(
            orderId: order.id,
            status: .filled,
            filledQuantity: order.quantity,
            averagePrice: currentPrice,
            totalCost: totalAmount,
            commission: commission,
            message: "Order executed successfully"
        )
    }

    private func processLimitOrder(
        order: StockOrder,
        stock: Stock,
        player: inout Player
    ) async throws -> OrderResult {
        // For limit orders, we just save them and they'll be executed by the trading engine
        var updatedOrder = order
        updatedOrder.status = .pending

        // For buy orders, reserve the funds
        if order.side == .buy, let limitPrice = order.price {
            let estimatedCost = limitPrice * Decimal(order.quantity)
            let commission = tradingEngine.calculateCommission(amount: estimatedCost)
            let totalCost = estimatedCost + commission

            // Reserve funds (this would be tracked separately in a real implementation)
            guard player.canAfford(cash: totalCost) else {
                throw TradingError.insufficientFunds
            }
        }

        // Save order
        try await stockRepository.saveOrder(updatedOrder)

        return OrderResult(
            orderId: order.id,
            status: .pending,
            filledQuantity: 0,
            averagePrice: nil,
            totalCost: 0,
            commission: 0,
            message: "Order placed and pending execution"
        )
    }
}

// MARK: - Trading Engine Protocol

protocol TradingEngine {
    func calculateCommission(amount: Decimal) -> Decimal
    func executeOrder(_ order: StockOrder) async throws -> OrderResult
}

// MARK: - Errors

enum TradingError: LocalizedError {
    case invalidQuantity
    case invalidPrice
    case insufficientFunds
    case insufficientShares
    case stockNotFound
    case marketClosed
    case orderExpired

    var errorDescription: String? {
        switch self {
        case .invalidQuantity:
            return "Invalid order quantity"
        case .invalidPrice:
            return "Invalid order price"
        case .insufficientFunds:
            return "Insufficient funds to complete order"
        case .insufficientShares:
            return "Insufficient shares to sell"
        case .stockNotFound:
            return "Stock not found"
        case .marketClosed:
            return "Market is currently closed"
        case .orderExpired:
            return "Order has expired"
        }
    }
}
