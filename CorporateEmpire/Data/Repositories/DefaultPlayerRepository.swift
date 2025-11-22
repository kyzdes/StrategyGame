//
//  DefaultPlayerRepository.swift
//  CorporateEmpire
//
//  Repository Implementation - Player
//

import Foundation
import Combine
import CoreData

final class DefaultPlayerRepository: PlayerRepository {
    private let apiClient: APIClient
    private let coreDataStack: CoreDataStack

    init(apiClient: APIClient, coreDataStack: CoreDataStack) {
        self.apiClient = apiClient
        self.coreDataStack = coreDataStack
    }

    func getPlayer(id: UUID) async throws -> Player {
        // Try to fetch from local cache first
        if let cached = try? fetchPlayerFromCache(id: id) {
            return cached
        }

        // Fetch from API
        let endpoint = PlayerEndpoint.getPlayer(id: id.uuidString)
        let dto: PlayerDTO = try await apiClient.request(endpoint)
        let player = dto.toDomain()

        // Cache the result
        try? cachePlayer(player)

        return player
    }

    func getCurrentPlayer() async throws -> Player {
        let endpoint = PlayerEndpoint.getCurrentPlayer
        let dto: PlayerDTO = try await apiClient.request(endpoint)
        let player = dto.toDomain()

        try? cachePlayer(player)

        return player
    }

    func updatePlayer(_ player: Player) async throws {
        let dto = PlayerDTO.fromDomain(player)
        let endpoint = PlayerEndpoint.updatePlayer(dto)
        try await apiClient.request(endpoint)

        // Update cache
        try? cachePlayer(player)
    }

    func createPlayer(_ player: Player) async throws {
        let dto = PlayerDTO.fromDomain(player)
        let endpoint = PlayerEndpoint.createPlayer(dto)
        try await apiClient.request(endpoint)

        try? cachePlayer(player)
    }

    func deletePlayer(id: UUID) async throws {
        let endpoint = PlayerEndpoint.deletePlayer(id: id.uuidString)
        try await apiClient.request(endpoint)

        // Remove from cache
        try? deletePlayerFromCache(id: id)
    }

    func getPlayerProfile(id: UUID) async throws -> PlayerProfile {
        let endpoint = PlayerEndpoint.getPlayerProfile(id: id.uuidString)
        let dto: PlayerProfileDTO = try await apiClient.request(endpoint)
        return dto.toDomain()
    }

    func searchPlayers(query: String) async throws -> [PlayerProfile] {
        let endpoint = PlayerEndpoint.searchPlayers(query: query)
        let dtos: [PlayerProfileDTO] = try await apiClient.request(endpoint)
        return dtos.map { $0.toDomain() }
    }

    func getPlayers(ids: [UUID]) async throws -> [Player] {
        let endpoint = PlayerEndpoint.getPlayers(ids: ids.map { $0.uuidString })
        let dtos: [PlayerDTO] = try await apiClient.request(endpoint)
        return dtos.map { $0.toDomain() }
    }

    func observePlayer(id: UUID) -> AnyPublisher<Player, Error> {
        // This would implement real-time updates via WebSocket
        // For now, return an empty publisher
        return Empty<Player, Error>().eraseToAnyPublisher()
    }

    // MARK: - Private Cache Methods

    private func fetchPlayerFromCache(id: UUID) throws -> Player? {
        let request: NSFetchRequest<PlayerEntity> = PlayerEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        let results = try coreDataStack.fetch(request)
        return results.first?.toDomain()
    }

    private func cachePlayer(_ player: Player) throws {
        let context = coreDataStack.viewContext

        // Try to find existing entity
        let request: NSFetchRequest<PlayerEntity> = PlayerEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", player.id as CVarArg)
        request.fetchLimit = 1

        let entity: PlayerEntity
        if let existing = try? context.fetch(request).first {
            entity = existing
        } else {
            entity = PlayerEntity(context: context)
            entity.id = player.id
        }

        // Update properties
        entity.username = player.username
        entity.email = player.email
        entity.level = Int32(player.level)
        entity.experience = Int64(player.experience)
        entity.cash = NSDecimalNumber(decimal: player.cash)
        entity.gems = Int32(player.gems)
        entity.createdAt = player.createdAt
        entity.lastSyncAt = player.lastSyncAt

        try coreDataStack.saveContext()
    }

    private func deletePlayerFromCache(id: UUID) throws {
        let request: NSFetchRequest<PlayerEntity> = PlayerEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        if let entity = try? coreDataStack.fetch(request).first {
            try coreDataStack.delete(entity)
        }
    }
}

// MARK: - Player Endpoints

enum PlayerEndpoint: APIEndpoint {
    case getPlayer(id: String)
    case getCurrentPlayer
    case updatePlayer(PlayerDTO)
    case createPlayer(PlayerDTO)
    case deletePlayer(id: String)
    case getPlayerProfile(id: String)
    case searchPlayers(query: String)
    case getPlayers(ids: [String])

    var path: String {
        switch self {
        case .getPlayer(let id):
            return "/api/v1/players/\(id)"
        case .getCurrentPlayer:
            return "/api/v1/players/me"
        case .updatePlayer:
            return "/api/v1/players/me"
        case .createPlayer:
            return "/api/v1/players"
        case .deletePlayer(let id):
            return "/api/v1/players/\(id)"
        case .getPlayerProfile(let id):
            return "/api/v1/players/\(id)/profile"
        case .searchPlayers:
            return "/api/v1/players/search"
        case .getPlayers:
            return "/api/v1/players/batch"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getPlayer, .getCurrentPlayer, .getPlayerProfile, .searchPlayers:
            return .get
        case .createPlayer, .getPlayers:
            return .post
        case .updatePlayer:
            return .put
        case .deletePlayer:
            return .delete
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }

    var parameters: [String: Any]? {
        switch self {
        case .searchPlayers(let query):
            return ["query": query]
        case .getPlayers(let ids):
            return ["ids": ids]
        default:
            return nil
        }
    }
}

// MARK: - PlayerEntity Extension

extension PlayerEntity {
    func toDomain() -> Player {
        return Player(
            id: id ?? UUID(),
            username: username ?? "",
            email: email ?? "",
            level: Int(level),
            experience: Int(experience),
            cash: cash as Decimal? ?? 0,
            gems: Int(gems),
            createdAt: createdAt ?? Date(),
            lastSyncAt: lastSyncAt ?? Date()
        )
    }
}

// MARK: - Player Profile DTO

struct PlayerProfileDTO: Codable {
    let id: String
    let username: String
    let avatarURL: String?
    let level: Int
    let netWorth: String
    let corporationId: String?
    let statistics: PlayerStatisticsDTO

    func toDomain() -> PlayerProfile {
        return PlayerProfile(
            id: UUID(uuidString: id) ?? UUID(),
            username: username,
            avatarURL: avatarURL,
            level: level,
            netWorth: Decimal(string: netWorth) ?? 0,
            corporationId: corporationId.flatMap { UUID(uuidString: $0) },
            statistics: statistics.toDomain()
        )
    }
}
