//
//  CompanyRepository.swift
//  CorporateEmpire
//
//  Repository Protocol - Company data access
//

import Foundation
import Combine

protocol CompanyRepository {
    /// Get company by ID
    func getCompany(id: UUID) async throws -> Company

    /// Get all companies owned by a player
    func getCompaniesByOwner(ownerId: UUID) async throws -> [Company]

    /// Get all companies (for market view)
    func getAllCompanies() async throws -> [Company]

    /// Create new company
    func createCompany(_ company: Company) async throws

    /// Update company
    func updateCompany(_ company: Company) async throws

    /// Delete company
    func deleteCompany(id: UUID) async throws

    /// Search companies by name or ticker
    func searchCompanies(query: String) async throws -> [Company]

    /// Get companies by industry
    func getCompaniesByIndustry(_ industry: Industry) async throws -> [Company]

    /// Observe company changes
    func observeCompany(id: UUID) -> AnyPublisher<Company, Error>

    /// Get top companies by valuation
    func getTopCompanies(limit: Int) async throws -> [Company]
}
