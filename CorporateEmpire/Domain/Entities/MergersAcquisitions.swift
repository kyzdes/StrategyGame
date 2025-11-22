//
//  MergersAcquisitions.swift
//  CorporateEmpire
//
//  Domain Entity - M&A System (v2.0)
//

import Foundation

// MARK: - M&A Deal

struct MergerAcquisitionDeal: Identifiable, Codable, Equatable {
    let id: UUID
    let type: DealType
    let status: DealStatus

    // Parties
    let acquirer: DealParty
    let target: DealParty

    // Deal terms
    let offerPrice: Decimal
    let shareStructure: ShareStructure?
    let conditions: [DealCondition]

    // Timeline
    let proposedAt: Date
    var acceptedAt: Date?
    var completedAt: Date?
    var expiresAt: Date

    // Due diligence
    var dueDiligenceComplete: Bool
    var approvals: [Approval]

    init(
        id: UUID = UUID(),
        type: DealType,
        status: DealStatus = .proposed,
        acquirer: DealParty,
        target: DealParty,
        offerPrice: Decimal,
        shareStructure: ShareStructure? = nil,
        conditions: [DealCondition] = [],
        proposedAt: Date = Date(),
        acceptedAt: Date? = nil,
        completedAt: Date? = nil,
        expiresAt: Date,
        dueDiligenceComplete: Bool = false,
        approvals: [Approval] = []
    ) {
        self.id = id
        self.type = type
        self.status = status
        self.acquirer = acquirer
        self.target = target
        self.offerPrice = offerPrice
        self.shareStructure = shareStructure
        self.conditions = conditions
        self.proposedAt = proposedAt
        self.acceptedAt = acceptedAt
        self.completedAt = completedAt
        self.expiresAt = expiresAt
        self.dueDiligenceComplete = dueDiligenceComplete
        self.approvals = approvals
    }
}

enum DealType: String, Codable {
    case friendlyMerger      // Both parties agree
    case acquisition         // One buys other
    case hostileTakeover     // Forced acquisition
    case merger              // Equals merge
    case assetPurchase       // Buy specific assets

    var displayName: String {
        switch self {
        case .friendlyMerger: return "Friendly Merger"
        case .acquisition: return "Acquisition"
        case .hostileTakeover: return "Hostile Takeover"
        case .merger: return "Merger"
        case .assetPurchase: return "Asset Purchase"
        }
    }

    var requiresApproval: Bool {
        switch self {
        case .hostileTakeover: return false
        default: return true
        }
    }
}

enum DealStatus: String, Codable {
    case proposed
    case underReview
    case dueDiligence
    case approved
    case rejected
    case completed
    case cancelled

    var displayName: String {
        rawValue.capitalized
    }
}

struct DealParty: Codable, Equatable {
    let playerId: UUID
    let companyId: UUID
    let companyName: String
    let valuation: Decimal
    let ownershipPercentage: Double
}

struct ShareStructure: Codable, Equatable {
    let cashPortion: Decimal
    let stockPortion: Int // Number of shares
    let newOwnershipSplit: OwnershipSplit
}

struct OwnershipSplit: Codable, Equatable {
    let acquirerPercentage: Double
    let targetPercentage: Double
}

struct DealCondition: Identifiable, Codable, Equatable {
    let id: UUID
    let description: String
    var isMet: Bool

    init(
        id: UUID = UUID(),
        description: String,
        isMet: Bool = false
    ) {
        self.id = id
        self.description = description
        self.isMet = isMet
    }
}

struct Approval: Codable, Equatable {
    let approverType: ApproverType
    var approved: Bool?
    let approvedAt: Date?

    enum ApproverType: String, Codable {
        case targetOwner
        case targetCorporation
        case regulatoryBody
        case shareholders
    }

    init(
        approverType: ApproverType,
        approved: Bool? = nil,
        approvedAt: Date? = nil
    ) {
        self.approverType = approverType
        self.approved = approved
        self.approvedAt = approvedAt
    }
}

// MARK: - Company Listing

struct CompanyListing: Identifiable, Codable, Equatable {
    let id: UUID
    let companyId: UUID
    let sellerId: UUID
    let sellerName: String

    let company: CompanyInfo
    let askingPrice: Decimal
    let listingType: ListingType

    let listedAt: Date
    var expiresAt: Date
    var status: ListingStatus

    var bids: [Bid]
    var watchers: [UUID] // Player IDs watching

    init(
        id: UUID = UUID(),
        companyId: UUID,
        sellerId: UUID,
        sellerName: String,
        company: CompanyInfo,
        askingPrice: Decimal,
        listingType: ListingType,
        listedAt: Date = Date(),
        expiresAt: Date,
        status: ListingStatus = .active,
        bids: [Bid] = [],
        watchers: [UUID] = []
    ) {
        self.id = id
        self.companyId = companyId
        self.sellerId = sellerId
        self.sellerName = sellerName
        self.company = company
        self.askingPrice = askingPrice
        self.listingType = listingType
        self.listedAt = listedAt
        self.expiresAt = expiresAt
        self.status = status
        self.bids = bids
        self.watchers = watchers
    }
}

struct CompanyInfo: Codable, Equatable {
    let name: String
    let ticker: String
    let industry: Industry
    let level: Int
    let revenue: Decimal
    let valuation: Decimal
    let managers: [String] // Manager names
    let upgrades: Int
}

enum ListingType: String, Codable {
    case fixedPrice
    case auction
    case negotiable

    var displayName: String {
        switch self {
        case .fixedPrice: return "Fixed Price"
        case .auction: return "Auction"
        case .negotiable: return "Negotiable"
        }
    }
}

enum ListingStatus: String, Codable {
    case active
    case sold
    case cancelled
    case expired
}

struct Bid: Identifiable, Codable, Equatable {
    let id: UUID
    let bidderId: UUID
    let bidderName: String
    let amount: Decimal
    let timestamp: Date
    var isWinning: Bool

    init(
        id: UUID = UUID(),
        bidderId: UUID,
        bidderName: String,
        amount: Decimal,
        timestamp: Date = Date(),
        isWinning: Bool = false
    ) {
        self.id = id
        self.bidderId = bidderId
        self.bidderName = bidderName
        self.amount = amount
        self.timestamp = timestamp
        self.isWinning = isWinning
    }
}

// MARK: - Investment Banking

struct InvestmentBankingDeal: Identifiable, Codable, Equatable {
    let id: UUID
    let bankerId: UUID
    let bankerName: String

    let dealType: IBDealType
    let clientId: UUID
    let targetId: UUID?

    let dealValue: Decimal
    let commission: Decimal
    let commissionRate: Double

    let startedAt: Date
    var completedAt: Date?
    var status: IBDealStatus

    var reputation: Int // Points earned for successful deals

    enum IBDealType: String, Codable {
        case advisory      // M&A advisory
        case fairness     // Fairness opinion
        case valuation    // Company valuation
        case ipo          // IPO underwriting
    }

    enum IBDealStatus: String, Codable {
        case active
        case completed
        case failed
    }

    init(
        id: UUID = UUID(),
        bankerId: UUID,
        bankerName: String,
        dealType: IBDealType,
        clientId: UUID,
        targetId: UUID? = nil,
        dealValue: Decimal,
        commission: Decimal,
        commissionRate: Double,
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        status: IBDealStatus = .active,
        reputation: Int = 0
    ) {
        self.id = id
        self.bankerId = bankerId
        self.bankerName = bankerName
        self.dealType = dealType
        self.clientId = clientId
        self.targetId = targetId
        self.dealValue = dealValue
        self.commission = commission
        self.commissionRate = commissionRate
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.status = status
        self.reputation = reputation
    }
}

struct BankerProfile: Codable, Equatable {
    let playerId: UUID
    var reputation: Int
    var dealsCompleted: Int
    var totalCommission: Decimal
    var successRate: Double
    var tier: BankerTier

    enum BankerTier: String, Codable {
        case analyst
        case associate
        case vicePresident
        case director
        case managingDirector

        var minReputation: Int {
            switch self {
            case .analyst: return 0
            case .associate: return 1000
            case .vicePresident: return 5000
            case .director: return 15000
            case .managingDirector: return 50000
            }
        }

        var commissionBonus: Double {
            switch self {
            case .analyst: return 1.0
            case .associate: return 1.1
            case .vicePresident: return 1.25
            case .director: return 1.5
            case .managingDirector: return 2.0
            }
        }
    }

    init(
        playerId: UUID,
        reputation: Int = 0,
        dealsCompleted: Int = 0,
        totalCommission: Decimal = 0,
        successRate: Double = 0,
        tier: BankerTier = .analyst
    ) {
        self.playerId = playerId
        self.reputation = reputation
        self.dealsCompleted = dealsCompleted
        self.totalCommission = totalCommission
        self.successRate = successRate
        self.tier = tier
    }
}
