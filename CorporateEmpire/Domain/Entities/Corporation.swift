//
//  Corporation.swift
//  CorporateEmpire
//
//  Domain Entity - Corporation (Guild System)
//

import Foundation

struct Corporation: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var ticker: String
    var logo: CorporationLogo
    let foundedDate: Date
    let founderId: UUID

    var level: Int
    var experience: Int
    var treasury: Decimal

    var members: [CorporationMember]
    var policies: CorporationPolicies
    var perks: [UUID] // Active perk IDs
    var headquarters: CorporationHeadquarters?

    var isPubliclyTraded: Bool
    var stockDetails: CorporationStock?

    init(
        id: UUID = UUID(),
        name: String,
        ticker: String,
        logo: CorporationLogo,
        foundedDate: Date = Date(),
        founderId: UUID,
        level: Int = 1,
        experience: Int = 0,
        treasury: Decimal = 0,
        members: [CorporationMember] = [],
        policies: CorporationPolicies = CorporationPolicies(),
        perks: [UUID] = [],
        headquarters: CorporationHeadquarters? = nil,
        isPubliclyTraded: Bool = false,
        stockDetails: CorporationStock? = nil
    ) {
        self.id = id
        self.name = name
        self.ticker = ticker
        self.logo = logo
        self.foundedDate = foundedDate
        self.founderId = founderId
        self.level = level
        self.experience = experience
        self.treasury = treasury
        self.members = members
        self.policies = policies
        self.perks = perks
        self.headquarters = headquarters
        self.isPubliclyTraded = isPubliclyTraded
        self.stockDetails = stockDetails
    }

    var memberCount: Int {
        members.count
    }

    var experienceForNextLevel: Int {
        level * 10_000
    }

    func member(withId id: UUID) -> CorporationMember? {
        members.first { $0.playerId == id }
    }

    func canManageMembers(playerId: UUID) -> Bool {
        guard let member = member(withId: playerId) else { return false }
        return [.founder, .ceo].contains(member.role)
    }

    func canManageTreasury(playerId: UUID) -> Bool {
        guard let member = member(withId: playerId) else { return false }
        return [.founder, .ceo, .cfo].contains(member.role)
    }
}

// MARK: - Corporation Member

struct CorporationMember: Identifiable, Codable, Equatable {
    let id: UUID
    let playerId: UUID
    let playerName: String
    var role: MemberRole
    let joinedDate: Date
    var contribution: Decimal
    var shares: Int

    var contributionRank: Int?

    init(
        id: UUID = UUID(),
        playerId: UUID,
        playerName: String,
        role: MemberRole,
        joinedDate: Date = Date(),
        contribution: Decimal = 0,
        shares: Int = 0,
        contributionRank: Int? = nil
    ) {
        self.id = id
        self.playerId = playerId
        self.playerName = playerName
        self.role = role
        self.joinedDate = joinedDate
        self.contribution = contribution
        self.shares = shares
        self.contributionRank = contributionRank
    }
}

enum MemberRole: String, Codable {
    case founder
    case ceo
    case cfo
    case member
    case investor

    var displayName: String {
        switch self {
        case .founder: return "Founder"
        case .ceo: return "CEO"
        case .cfo: return "CFO"
        case .member: return "Member"
        case .investor: return "Investor"
        }
    }

    var permissions: [Permission] {
        switch self {
        case .founder:
            return Permission.allCases
        case .ceo:
            return [.manageMembers, .managePolicies, .startProjects, .chat]
        case .cfo:
            return [.manageTreasury, .startProjects, .chat]
        case .member:
            return [.contribute, .chat, .vote]
        case .investor:
            return [.receiveDividends]
        }
    }

    enum Permission: CaseIterable {
        case manageMembers
        case managePolicies
        case manageTreasury
        case startProjects
        case contribute
        case chat
        case vote
        case receiveDividends
    }
}

// MARK: - Corporation Policies

struct CorporationPolicies: Codable, Equatable {
    var isOpenToJoin: Bool
    var minimumLevelToJoin: Int
    var minimumContribution: Decimal
    var dividendDistribution: DividendPolicy
    var votingSystem: VotingSystem

    init(
        isOpenToJoin: Bool = false,
        minimumLevelToJoin: Int = 1,
        minimumContribution: Decimal = 0,
        dividendDistribution: DividendPolicy = .equalShare,
        votingSystem: VotingSystem = .democratic
    ) {
        self.isOpenToJoin = isOpenToJoin
        self.minimumLevelToJoin = minimumLevelToJoin
        self.minimumContribution = minimumContribution
        self.dividendDistribution = dividendDistribution
        self.votingSystem = votingSystem
    }
}

enum DividendPolicy: String, Codable {
    case equalShare         // Split evenly among all members
    case contributionBased  // Based on total contribution
    case shareBased         // Based on share ownership
    case none              // No dividends
}

enum VotingSystem: String, Codable {
    case democratic        // One vote per member
    case shareholderBased  // Votes proportional to shares
    case leadershipOnly    // Only founder/CEO/CFO vote
}

// MARK: - Corporation Logo

struct CorporationLogo: Codable, Equatable {
    let iconName: String
    let backgroundColor: String
    let foregroundColor: String

    static let `default` = CorporationLogo(
        iconName: "building.columns",
        backgroundColor: "#007AFF",
        foregroundColor: "#FFFFFF"
    )
}

// MARK: - Corporation Headquarters

struct CorporationHeadquarters: Codable, Equatable {
    let level: Int
    let bonuses: [HeadquartersBonus]
    let upgradeCost: Decimal

    var nextLevelBonuses: [HeadquartersBonus] {
        // Return bonuses for next level
        []
    }
}

struct HeadquartersBonus: Codable, Equatable {
    let type: BonusType
    let value: Double

    enum BonusType: String, Codable {
        case memberCapacity
        case treasuryBonus
        case experienceMultiplier
        case projectSpeedBoost
    }
}

// MARK: - Corporation Stock (if IPO'd)

struct CorporationStock: Codable, Equatable {
    let totalShares: Int
    let publicShares: Int
    let currentPrice: Decimal
    let ipoDate: Date
    let lockupPeriod: TimeInterval

    var isLockupActive: Bool {
        Date().timeIntervalSince(ipoDate) < lockupPeriod
    }
}

// MARK: - Corporation Perk

struct CorporationPerk: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let effect: PerkEffect
    let level: Int
    let unlockCost: Decimal
    let isUnlocked: Bool

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        effect: PerkEffect,
        level: Int,
        unlockCost: Decimal,
        isUnlocked: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.effect = effect
        self.level = level
        self.unlockCost = unlockCost
        self.isUnlocked = isUnlocked
    }
}

enum PerkEffect: Codable, Equatable {
    case revenueBoost(Double)
    case tradingFeeDiscount(Double)
    case fastTrack(Double)
    case dividendBonus(Double)
    case memberCapacityIncrease(Int)

    var displayValue: String {
        switch self {
        case .revenueBoost(let percent):
            return "+\(Int(percent * 100))% Revenue"
        case .tradingFeeDiscount(let percent):
            return "\(Int(percent * 100))% Fee Discount"
        case .fastTrack(let percent):
            return "+\(Int(percent * 100))% Speed"
        case .dividendBonus(let percent):
            return "+\(Int(percent * 100))% Dividends"
        case .memberCapacityIncrease(let count):
            return "+\(count) Member Slots"
        }
    }
}

// MARK: - Corporation Project

struct CorporationProject: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let requiredContribution: Decimal
    var currentContribution: Decimal
    let deadline: Date
    let reward: ProjectReward
    var participants: [UUID] // Player IDs who contributed
    var status: ProjectStatus

    var progress: Double {
        guard requiredContribution > 0 else { return 0 }
        return Double(truncating: (currentContribution / requiredContribution) as NSDecimalNumber)
    }

    var isCompleted: Bool {
        currentContribution >= requiredContribution
    }

    var isExpired: Bool {
        Date() > deadline && !isCompleted
    }
}

enum ProjectStatus: String, Codable {
    case active
    case completed
    case failed
    case cancelled
}

struct ProjectReward: Codable, Equatable {
    let type: RewardType
    let duration: TimeInterval?
    let value: Double

    enum RewardType: String, Codable {
        case productionBoost
        case marketInfluence
        case experienceBonus
        case treasuryBonus
        case unlockPerk
    }
}

// MARK: - Corporation Creation

struct CorporationCreationRequest: Codable {
    let name: String
    let ticker: String
    let logo: CorporationLogo
    let policies: CorporationPolicies

    func validate() throws {
        guard name.count >= 3 && name.count <= 30 else {
            throw CorporationValidationError.invalidName
        }
        guard ticker.count >= 3 && ticker.count <= 6 else {
            throw CorporationValidationError.invalidTicker
        }
    }
}

enum CorporationValidationError: LocalizedError {
    case invalidName
    case invalidTicker
    case duplicateName
    case duplicateTicker
    case insufficientFunds

    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Corporation name must be 3-30 characters"
        case .invalidTicker:
            return "Ticker must be 3-6 characters"
        case .duplicateName:
            return "Corporation name already exists"
        case .duplicateTicker:
            return "Ticker already in use"
        case .insufficientFunds:
            return "Insufficient funds to create corporation"
        }
    }
}
