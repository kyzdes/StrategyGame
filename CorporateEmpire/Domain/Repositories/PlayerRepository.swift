//
//  PlayerRepository.swift
//  CorporateEmpire
//
//  Repository Protocol - Player data access
//

import Foundation
import Combine

protocol PlayerRepository {
    /// Get player by ID
    func getPlayer(id: UUID) async throws -> Player

    /// Get current authenticated player
    func getCurrentPlayer() async throws -> Player

    /// Update player data
    func updatePlayer(_ player: Player) async throws

    /// Create new player
    func createPlayer(_ player: Player) async throws

    /// Delete player
    func deletePlayer(id: UUID) async throws

    /// Get player profile (public view)
    func getPlayerProfile(id: UUID) async throws -> PlayerProfile

    /// Search players by username
    func searchPlayers(query: String) async throws -> [PlayerProfile]

    /// Get multiple players by IDs
    func getPlayers(ids: [UUID]) async throws -> [Player]

    /// Observe player changes (real-time updates)
    func observePlayer(id: UUID) -> AnyPublisher<Player, Error>
}
