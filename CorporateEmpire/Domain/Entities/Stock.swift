//
//  Stock.swift
//  CorporateEmpire
//
//  Domain Entity - Stock & Trading
//

import Foundation

struct Stock: Identifiable, Codable, Equatable {
    let id: UUID
    let ticker: String
    let companyId: UUID
    let companyName: String
    let industry: Industry

    var currentPrice: Decimal
    var previousClose: Decimal
    var openPrice: Decimal
    var highPrice24h: Decimal
    var lowPrice24h: Decimal

    var volume24h: Int
    var marketCap: Decimal
    var totalShares: Int
    var floatingShares: Int

    var peRatio: Double?
    var dividendYield: Double?
    var lastUpdate: Date

    /// Price change in dollars
    var priceChange: Decimal {
        currentPrice - previousClose
    }

    /// Price change percentage
    var priceChangePercent: Double {
        guard previousClose > 0 else { return 0 }
        return Double(truncating: ((currentPrice - previousClose) / previousClose * 100) as NSDecimalNumber)
    }

    /// Is the stock price increasing
    var isIncreasing: Bool {
        currentPrice >= previousClose
    }
}

// MARK: - Stock Update

struct StockUpdate: Codable, Equatable {
    let ticker: String
    let currentPrice: Decimal
    let change24h: Double
    let volume24h: Int
    let marketCap: Decimal
    let peRatio: Double?
    let dividendYield: Double?
    let timestamp: Date
}

// MARK: - Stock Order

struct StockOrder: Identifiable, Codable, Equatable {
    let id: UUID
    let playerId: UUID
    let ticker: String
    let type: OrderType
    let side: OrderSide
    let quantity: Int
    let price: Decimal? // nil for market orders
    let status: OrderStatus
    let createdAt: Date
    let expiresAt: Date?
    var filledAt: Date?
    var filledQuantity: Int

    init(
        id: UUID = UUID(),
        playerId: UUID,
        ticker: String,
        type: OrderType,
        side: OrderSide,
        quantity: Int,
        price: Decimal? = nil,
        status: OrderStatus = .pending,
        createdAt: Date = Date(),
        expiresAt: Date? = nil,
        filledAt: Date? = nil,
        filledQuantity: Int = 0
    ) {
        self.id = id
        self.playerId = playerId
        self.ticker = ticker
        self.type = type
        self.side = side
        self.quantity = quantity
        self.price = price
        self.status = status
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.filledAt = filledAt
        self.filledQuantity = filledQuantity
    }

    var isFullyFilled: Bool {
        filledQuantity >= quantity
    }

    var isPartiallyFilled: Bool {
        filledQuantity > 0 && filledQuantity < quantity
    }
}

enum OrderType: String, Codable {
    case market      // Execute immediately at current market price
    case limit       // Execute when price reaches specified level
    case stopLoss    // Sell when price drops to stop level
    case takeProfit  // Sell when price rises to target level
}

enum OrderSide: String, Codable {
    case buy
    case sell
}

enum OrderStatus: String, Codable {
    case pending
    case partiallyFilled
    case filled
    case cancelled
    case expired
    case rejected
}

// MARK: - Order Result

struct OrderResult: Codable, Equatable {
    let orderId: UUID
    let status: OrderStatus
    let filledQuantity: Int
    let averagePrice: Decimal?
    let totalCost: Decimal
    let commission: Decimal
    let message: String?
}

// MARK: - Portfolio

struct Portfolio: Codable, Equatable {
    let holdings: [StockHolding]
    let totalValue: Decimal
    let totalCost: Decimal
    let unrealizedPL: Decimal
    let realizedPL: Decimal
    let dividendIncome: Decimal

    /// Portfolio beta (market risk)
    var portfolioBeta: Double

    /// Sharpe ratio (risk-adjusted returns)
    var sharpeRatio: Double

    /// Diversification score (0-100)
    var diversificationScore: Double

    /// Total profit/loss
    var totalPL: Decimal {
        unrealizedPL + realizedPL
    }

    /// Total profit/loss percentage
    var totalPLPercent: Double {
        guard totalCost > 0 else { return 0 }
        return Double(truncating: (totalPL / totalCost * 100) as NSDecimalNumber)
    }
}

// MARK: - Stock Holding

struct StockHolding: Identifiable, Codable, Equatable {
    let id: UUID
    let ticker: String
    let companyName: String
    let quantity: Int
    let averageCost: Decimal
    let currentPrice: Decimal
    let totalCost: Decimal
    let currentValue: Decimal

    var unrealizedPL: Decimal {
        currentValue - totalCost
    }

    var plPercentage: Double {
        guard totalCost > 0 else { return 0 }
        return Double(truncating: (unrealizedPL / totalCost * 100) as NSDecimalNumber)
    }

    /// Percentage of portfolio this holding represents
    var allocation: Double

    var isProfit: Bool {
        unrealizedPL >= 0
    }

    init(
        id: UUID = UUID(),
        ticker: String,
        companyName: String,
        quantity: Int,
        averageCost: Decimal,
        currentPrice: Decimal,
        allocation: Double = 0
    ) {
        self.id = id
        self.ticker = ticker
        self.companyName = companyName
        self.quantity = quantity
        self.averageCost = averageCost
        self.currentPrice = currentPrice
        self.totalCost = averageCost * Decimal(quantity)
        self.currentValue = currentPrice * Decimal(quantity)
        self.allocation = allocation
    }
}

// MARK: - Market Conditions

struct MarketConditions: Codable, Equatable {
    let industryTrend: Double // 0.5 - 2.0 multiplier
    let overallSentiment: MarketSentiment
    let volatilityIndex: Double // 0-100
    let activeTraders: Int
    let timestamp: Date
}

enum MarketSentiment: String, Codable {
    case bullish    // Strong positive
    case positive   // Moderate positive
    case neutral    // Stable
    case negative   // Moderate negative
    case bearish    // Strong negative

    var multiplier: Double {
        switch self {
        case .bullish: return 1.3
        case .positive: return 1.1
        case .neutral: return 1.0
        case .negative: return 0.9
        case .bearish: return 0.7
        }
    }
}
