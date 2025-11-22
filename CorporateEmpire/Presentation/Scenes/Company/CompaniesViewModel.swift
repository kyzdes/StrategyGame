//
//  CompaniesViewModel.swift
//  CorporateEmpire
//
//  Companies - View Model
//

import Foundation
import Combine

@MainActor
final class CompaniesViewModel: ObservableObject {
    @Published var companies: [Company] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let container: DependencyContainer
    private var cancellables = Set<AnyCancellable>()

    init(container: DependencyContainer) {
        self.container = container
    }

    func loadCompanies() async {
        isLoading = true

        do {
            let player = try await container.playerRepository.getCurrentPlayer()
            companies = try await container.companyRepository.getCompaniesByOwner(ownerId: player.id)
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }

    func createCompany(request: CompanyCreationRequest) async throws {
        let player = try await container.playerRepository.getCurrentPlayer()
        _ = try await container.createCompanyUseCase.execute(request: request, ownerId: player.id)
        await loadCompanies()
    }
}
