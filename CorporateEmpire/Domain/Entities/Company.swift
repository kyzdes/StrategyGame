//
//  Company.swift
//  CorporateEmpire
//
//  Domain Entity - Company
//

import Foundation

struct Company: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let ticker: String
    let industry: Industry
    let logo: CompanyLogo
    let foundedDate: Date
    var ownerId: UUID

    var level: Int
    var experience: Int
    var revenue: Decimal
    var valuation: Decimal
    var lastRevenueCalculation: Date

    var upgrades: [UUID] // IDs of purchased upgrades
    var managers: [UUID] // IDs of hired managers
    var totalShares: Int
    var publicShares: Int // Shares available on market

    init(
        id: UUID = UUID(),
        name: String,
        ticker: String,
        industry: Industry,
        logo: CompanyLogo,
        foundedDate: Date = Date(),
        ownerId: UUID,
        level: Int = 1,
        experience: Int = 0,
        revenue: Decimal = 0,
        valuation: Decimal = 0,
        lastRevenueCalculation: Date = Date(),
        upgrades: [UUID] = [],
        managers: [UUID] = [],
        totalShares: Int = 1_000_000,
        publicShares: Int = 0
    ) {
        self.id = id
        self.name = name
        self.ticker = ticker
        self.industry = industry
        self.logo = logo
        self.foundedDate = foundedDate
        self.ownerId = ownerId
        self.level = level
        self.experience = experience
        self.revenue = revenue
        self.valuation = valuation
        self.lastRevenueCalculation = lastRevenueCalculation
        self.upgrades = upgrades
        self.managers = managers
        self.totalShares = totalShares
        self.publicShares = publicShares
    }

    /// Calculate revenue per second based on current level and multipliers
    func calculateRevenuePerSecond(
        upgradeMultiplier: Double = 1.0,
        managerMultiplier: Double = 1.0,
        prestigeBonus: Double = 1.0
    ) -> Decimal {
        let baseRevenue = Decimal(100) // Base $100/sec at level 1
        let levelMultiplier = pow(Double(level), 1.5)

        let totalMultiplier = levelMultiplier *
                             upgradeMultiplier *
                             managerMultiplier *
                             prestigeBonus *
                             industry.baseMultiplier

        return baseRevenue * Decimal(totalMultiplier)
    }

    /// Calculate experience needed for next level
    var experienceForNextLevel: Int {
        return level * 1000
    }

    /// Progress percentage to next level
    var levelProgress: Double {
        return Double(experience) / Double(experienceForNextLevel)
    }
}

// MARK: - Supporting Types

struct CompanyLogo: Codable, Equatable {
    let iconName: String
    let backgroundColor: String // Hex color
    let foregroundColor: String // Hex color

    static let `default` = CompanyLogo(
        iconName: "building.2",
        backgroundColor: "#007AFF",
        foregroundColor: "#FFFFFF"
    )
}

struct CompanyCreationRequest: Codable {
    let name: String
    let industry: Industry
    let ticker: String
    let initialCapital: Decimal
    let logo: CompanyLogo

    func validate() throws {
        guard name.count >= 3 && name.count <= 30 else {
            throw CompanyValidationError.invalidName
        }
        guard ticker.count >= 3 && ticker.count <= 5 else {
            throw CompanyValidationError.invalidTicker
        }
        guard ticker.allSatisfy({ $0.isLetter || $0.isNumber }) else {
            throw CompanyValidationError.invalidTicker
        }
    }
}

enum CompanyValidationError: LocalizedError {
    case invalidName
    case invalidTicker
    case insufficientCapital
    case duplicateName
    case duplicateTicker

    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Company name must be 3-30 characters"
        case .invalidTicker:
            return "Ticker must be 3-5 alphanumeric characters"
        case .insufficientCapital:
            return "Insufficient capital to create company"
        case .duplicateName:
            return "Company name already exists"
        case .duplicateTicker:
            return "Ticker symbol already in use"
        }
    }
}
