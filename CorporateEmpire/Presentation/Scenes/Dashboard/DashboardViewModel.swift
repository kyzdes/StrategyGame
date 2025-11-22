//
//  DashboardViewModel.swift
//  CorporateEmpire
//
//  Dashboard - View Model
//

import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var player: Player?
    @Published var companies: [Company] = []
    @Published var portfolio: Portfolio?
    @Published var netWorth: Decimal = 0
    @Published var change24h: Double = 0
    @Published var isLoading = false
    @Published var error: Error?

    private let container: DependencyContainer
    private var cancellables = Set<AnyCancellable>()

    init(container: DependencyContainer) {
        self.container = container
        setupBindings()
    }

    func loadData() async {
        isLoading = true
        error = nil

        do {
            // Load player data
            player = try await container.playerRepository.getCurrentPlayer()

            // Load companies
            if let playerId = player?.id {
                companies = try await container.companyRepository.getCompaniesByOwner(ownerId: playerId)
                portfolio = try await container.portfolioRepository.getPortfolio(playerId: playerId)
            }

            // Calculate net worth
            calculateNetWorth()

            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }

    func refresh() async {
        await loadData()
    }

    func collectIncome() {
        // TODO: Implement manual income collection
        print("Collecting income...")
    }

    private func setupBindings() {
        // Auto-refresh every 60 seconds
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.refresh()
                }
            }
            .store(in: &cancellables)
    }

    private func calculateNetWorth() {
        guard let player = player else { return }

        let companyValuations = companies.reduce(Decimal(0)) { $0 + $1.valuation }
        let stockValue = portfolio?.totalValue ?? 0

        netWorth = player.calculateNetWorth(
            companyValuations: companyValuations,
            stockHoldingsValue: stockValue
        )

        // Calculate 24h change (mock for now)
        change24h = Double.random(in: -5...15)
    }
}
