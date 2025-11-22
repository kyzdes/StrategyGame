//
//  SocialViewModel.swift
//  CorporateEmpire
//
//  Social - View Model
//

import Foundation

@MainActor
final class SocialViewModel: ObservableObject {
    @Published var corporation: Corporation?
    @Published var friends: [PlayerProfile] = []

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func loadData() async {
        // Load corporation and friends data
    }
}
