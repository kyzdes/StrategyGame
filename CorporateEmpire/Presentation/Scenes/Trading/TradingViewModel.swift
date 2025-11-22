//
//  TradingViewModel.swift
//  CorporateEmpire
//
//  Trading - View Model
//

import Foundation
import Combine

@MainActor
final class TradingViewModel: ObservableObject {
    @Published var stocks: [Stock] = []
    @Published var portfolio: Portfolio?
    @Published var isLoading = false

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func loadStocks() async {
        isLoading = true

        do {
            stocks = try await container.stockRepository.getAllStocks()
            let player = try await container.playerRepository.getCurrentPlayer()
            portfolio = try await container.portfolioRepository.getPortfolio(playerId: player.id)
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}
