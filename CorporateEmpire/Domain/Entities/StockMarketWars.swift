//
//  StockMarketWars.swift
//  CorporateEmpire
//
//  Domain Entity - Stock Market Wars PvP System (v2.0)
//

import Foundation

// MARK: - Trading Arena

struct TradingArena: Identifiable, Codable, Equatable {
    let id: UUID
    let type: ArenaType
    let startTime: Date
    let endTime: Date
    var status: ArenaStatus

    var participants: [ArenaParticipant]
    var maxParticipants: Int

    let prizePool: ArenaPrizePool
    let entryFee: ArenaEntry?

    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    var remainingTime: TimeInterval {
        max(0, endTime.timeIntervalSinceNow)
    }

    var isActive: Bool {
        status == .active && Date() < endTime
    }

    init(
        id: UUID = UUID(),
        type: ArenaType,
        startTime: Date,
        endTime: Date,
        status: ArenaStatus = .waiting,
        participants: [ArenaParticipant] = [],
        maxParticipants: Int,
        prizePool: ArenaPrizePool,
        entryFee: ArenaEntry? = nil
    ) {
        self.id = id
        self.type = type
        self.startTime = startTime
        self.endTime = endTime
        self.status = status
        self.participants = participants
        self.maxParticipants = maxParticipants
        self.prizePool = prizePool
        self.entryFee = entryFee
    }
}

enum ArenaType: String, Codable {
    case quickBattle // 5 minutes
    case speedTrading // 15 minutes
    case marathon // 1 hour
    case ranked // Competitive ranked
    case tournament // Special event

    var displayName: String {
        switch self {
        case .quickBattle: return "Quick Battle"
        case .speedTrading: return "Speed Trading"
        case .marathon: return "Marathon"
        case .ranked: return "Ranked Match"
        case .tournament: return "Tournament"
        }
    }

    var duration: TimeInterval {
        switch self {
        case .quickBattle: return 300 // 5 min
        case .speedTrading: return 900 // 15 min
        case .marathon: return 3600 // 1 hour
        case .ranked: return 600 // 10 min
        case .tournament: return 1800 // 30 min
        }
    }

    var maxParticipants: Int {
        switch self {
        case .quickBattle: return 8
        case .speedTrading: return 16
        case .marathon: return 32
        case .ranked: return 8
        case .tournament: return 64
        }
    }
}

enum ArenaStatus: String, Codable {
    case waiting
    case starting
    case active
    case finished
    case cancelled
}

// MARK: - Arena Participant

struct ArenaParticipant: Identifiable, Codable, Equatable {
    let id: UUID
    let playerId: UUID
    let playerName: String
    let playerLevel: Int
    let rank: CompetitiveRank?

    var startingCash: Decimal
    var currentCash: Decimal
    var netProfit: Decimal
    var trades: [ArenaTrade]

    var position: Int?
    var reward: ArenaReward?

    var profitPercentage: Double {
        guard startingCash > 0 else { return 0 }
        return Double(truncating: ((currentCash - startingCash) / startingCash * 100) as NSDecimalNumber)
    }

    var tradeCount: Int {
        trades.count
    }

    var winRate: Double {
        guard !trades.isEmpty else { return 0 }
        let profitableTrades = trades.filter { $0.profit > 0 }.count
        return Double(profitableTrades) / Double(trades.count) * 100
    }

    init(
        id: UUID = UUID(),
        playerId: UUID,
        playerName: String,
        playerLevel: Int,
        rank: CompetitiveRank? = nil,
        startingCash: Decimal,
        currentCash: Decimal? = nil,
        netProfit: Decimal = 0,
        trades: [ArenaTrade] = [],
        position: Int? = nil,
        reward: ArenaReward? = nil
    ) {
        self.id = id
        self.playerId = playerId
        self.playerName = playerName
        self.playerLevel = playerLevel
        self.rank = rank
        self.startingCash = startingCash
        self.currentCash = currentCash ?? startingCash
        self.netProfit = netProfit
        self.trades = trades
        self.position = position
        self.reward = reward
    }
}

// MARK: - Arena Trade

struct ArenaTrade: Identifiable, Codable, Equatable {
    let id: UUID
    let ticker: String
    let type: OrderSide
    let quantity: Int
    let buyPrice: Decimal
    let sellPrice: Decimal?
    let profit: Decimal
    let timestamp: Date

    init(
        id: UUID = UUID(),
        ticker: String,
        type: OrderSide,
        quantity: Int,
        buyPrice: Decimal,
        sellPrice: Decimal? = nil,
        profit: Decimal = 0,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.ticker = ticker
        self.type = type
        self.quantity = quantity
        self.buyPrice = buyPrice
        self.sellPrice = sellPrice
        self.profit = profit
        self.timestamp = timestamp
    }
}

// MARK: - Prize Pool

struct ArenaPrizePool: Codable, Equatable {
    let totalCash: Decimal
    let totalGems: Int
    let distribution: [PrizeDistribution]
    let specialRewards: [SpecialReward]?

    struct PrizeDistribution: Codable, Equatable {
        let position: Int
        let cashReward: Decimal
        let gemsReward: Int
        let prestigePoints: Int
    }

    struct SpecialReward: Codable, Equatable {
        let name: String
        let description: String
        let icon: String
    }
}

struct ArenaEntry: Codable, Equatable {
    let cash: Decimal?
    let gems: Int?
    let minLevel: Int?
    let minRank: CompetitiveRank?
}

struct ArenaReward: Codable, Equatable {
    let cash: Decimal
    let gems: Int
    let prestigePoints: Int
    let rankPoints: Int?
    let specialRewards: [String]?
}

// MARK: - Competitive Ranking

enum CompetitiveRank: String, Codable, CaseIterable {
    case bronze
    case silver
    case gold
    case platinum
    case diamond
    case master
    case grandmaster

    var displayName: String {
        rawValue.capitalized
    }

    var color: String {
        switch self {
        case .bronze: return "#CD7F32"
        case .silver: return "#C0C0C0"
        case .gold: return "#FFD700"
        case .platinum: return "#E5E4E2"
        case .diamond: return "#B9F2FF"
        case .master: return "#FF1493"
        case .grandmaster: return "#9400D3"
        }
    }

    var minPoints: Int {
        switch self {
        case .bronze: return 0
        case .silver: return 1000
        case .gold: return 2500
        case .platinum: return 5000
        case .diamond: return 10000
        case .master: return 20000
        case .grandmaster: return 40000
        }
    }

    var icon: String {
        switch self {
        case .bronze: return "shield.fill"
        case .silver: return "shield.lefthalf.filled"
        case .gold: return "shield.checkered"
        case .platinum: return "crown.fill"
        case .diamond: return "diamond.fill"
        case .master: return "star.fill"
        case .grandmaster: return "sparkles"
        }
    }
}

struct CompetitiveProfile: Codable, Equatable {
    let playerId: UUID
    var rank: CompetitiveRank
    var rankPoints: Int
    var season: Int

    var matchesPlayed: Int
    var matchesWon: Int
    var totalProfit: Decimal
    var averageProfit: Decimal
    var bestProfit: Decimal
    var winStreak: Int
    var currentStreak: Int

    var winRate: Double {
        guard matchesPlayed > 0 else { return 0 }
        return Double(matchesWon) / Double(matchesPlayed) * 100
    }

    init(
        playerId: UUID,
        rank: CompetitiveRank = .bronze,
        rankPoints: Int = 0,
        season: Int = 1,
        matchesPlayed: Int = 0,
        matchesWon: Int = 0,
        totalProfit: Decimal = 0,
        averageProfit: Decimal = 0,
        bestProfit: Decimal = 0,
        winStreak: Int = 0,
        currentStreak: Int = 0
    ) {
        self.playerId = playerId
        self.rank = rank
        self.rankPoints = rankPoints
        self.season = season
        self.matchesPlayed = matchesPlayed
        self.matchesWon = matchesWon
        self.totalProfit = totalProfit
        self.averageProfit = averageProfit
        self.bestProfit = bestProfit
        self.winStreak = winStreak
        self.currentStreak = currentStreak
    }
}

// MARK: - Tournament

struct Tournament: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let startTime: Date
    let endTime: Date

    let rounds: [TournamentRound]
    var currentRound: Int
    var status: TournamentStatus

    let prizePool: TournamentPrizePool
    let entryRequirement: TournamentEntry

    var participants: [UUID] // Player IDs
    var bracket: TournamentBracket?

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        startTime: Date,
        endTime: Date,
        rounds: [TournamentRound],
        currentRound: Int = 0,
        status: TournamentStatus = .upcoming,
        prizePool: TournamentPrizePool,
        entryRequirement: TournamentEntry,
        participants: [UUID] = [],
        bracket: TournamentBracket? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
        self.rounds = rounds
        self.currentRound = currentRound
        self.status = status
        self.prizePool = prizePool
        self.entryRequirement = entryRequirement
        self.participants = participants
        self.bracket = bracket
    }
}

enum TournamentStatus: String, Codable {
    case upcoming
    case registration
    case active
    case finished
}

struct TournamentRound: Codable, Equatable {
    let roundNumber: Int
    let name: String
    let duration: TimeInterval
    var matches: [TournamentMatch]
}

struct TournamentMatch: Identifiable, Codable, Equatable {
    let id: UUID
    let player1: UUID
    let player2: UUID
    var winner: UUID?
    var arenaId: UUID?

    init(
        id: UUID = UUID(),
        player1: UUID,
        player2: UUID,
        winner: UUID? = nil,
        arenaId: UUID? = nil
    ) {
        self.id = id
        self.player1 = player1
        self.player2 = player2
        self.winner = winner
        self.arenaId = arenaId
    }
}

struct TournamentBracket: Codable, Equatable {
    let rounds: Int
    var matches: [[TournamentMatch]]
}

struct TournamentPrizePool: Codable, Equatable {
    let firstPlace: ArenaReward
    let secondPlace: ArenaReward
    let thirdPlace: ArenaReward
    let top8: ArenaReward?
    let top16: ArenaReward?
}

struct TournamentEntry: Codable, Equatable {
    let gems: Int
    let minRank: CompetitiveRank
    let minLevel: Int
}

// MARK: - Leaderboard

struct ArenaLeaderboard: Codable, Equatable {
    let type: LeaderboardType
    let period: LeaderboardPeriod
    let entries: [LeaderboardEntry]
    let lastUpdate: Date

    enum LeaderboardType: String, Codable {
        case profit
        case winRate
        case trades
        case rankPoints
    }

    enum LeaderboardPeriod: String, Codable {
        case daily
        case weekly
        case monthly
        case allTime
    }

    struct LeaderboardEntry: Identifiable, Codable, Equatable {
        let id: UUID
        let playerId: UUID
        let playerName: String
        let rank: CompetitiveRank
        let position: Int
        let value: Decimal
        let change: Int? // Position change from previous period
    }
}
