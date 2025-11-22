//
//  ProfileViewModel.swift
//  CorporateEmpire
//
//  Profile - View Model
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var player: Player?

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func loadProfile() async {
        do {
            player = try await container.playerRepository.getCurrentPlayer()
        } catch {
            print("Failed to load profile: \(error)")
        }
    }
}
