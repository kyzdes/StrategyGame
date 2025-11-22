//
//  CreateCompanyUseCase.swift
//  CorporateEmpire
//
//  Use Case - Create a new company
//

import Foundation

protocol CreateCompanyUseCase {
    func execute(request: CompanyCreationRequest, ownerId: UUID) async throws -> Company
}

final class DefaultCreateCompanyUseCase: CreateCompanyUseCase {
    private let companyRepository: CompanyRepository
    private let playerRepository: PlayerRepository

    init(
        companyRepository: CompanyRepository,
        playerRepository: PlayerRepository
    ) {
        self.companyRepository = companyRepository
        self.playerRepository = playerRepository
    }

    func execute(request: CompanyCreationRequest, ownerId: UUID) async throws -> Company {
        // Validate request
        try request.validate()

        // Get player
        let player = try await playerRepository.getPlayer(id: ownerId)

        // Check if player has enough capital
        guard player.canAfford(cash: request.initialCapital) else {
            throw CompanyValidationError.insufficientCapital
        }

        // Check for duplicate name/ticker
        let existingCompanies = try await companyRepository.getAllCompanies()
        if existingCompanies.contains(where: { $0.name == request.name }) {
            throw CompanyValidationError.duplicateName
        }
        if existingCompanies.contains(where: { $0.ticker == request.ticker }) {
            throw CompanyValidationError.duplicateTicker
        }

        // Create company
        let company = Company(
            name: request.name,
            ticker: request.ticker,
            industry: request.industry,
            logo: request.logo,
            ownerId: ownerId,
            valuation: request.initialCapital
        )

        // Save company
        try await companyRepository.createCompany(company)

        // Deduct capital from player
        var updatedPlayer = player
        updatedPlayer.cash -= request.initialCapital
        updatedPlayer.companies.append(company.id)
        updatedPlayer.statistics.totalCompaniesCreated += 1
        try await playerRepository.updatePlayer(updatedPlayer)

        return company
    }
}
