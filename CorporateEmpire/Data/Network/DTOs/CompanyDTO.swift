//
//  CompanyDTO.swift
//  CorporateEmpire
//
//  Data Transfer Object - Company
//

import Foundation

struct CompanyDTO: Codable {
    let id: String
    let name: String
    let ticker: String
    let industry: String
    let logo: CompanyLogoDTO
    let foundedDate: String
    let ownerId: String
    let level: Int
    let experience: Int
    let revenue: String
    let valuation: String
    let lastRevenueCalculation: String
    let upgrades: [String]
    let managers: [String]
    let totalShares: Int
    let publicShares: Int

    func toDomain() -> Company {
        let formatter = ISO8601DateFormatter()

        return Company(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            ticker: ticker,
            industry: Industry(rawValue: industry) ?? .technology,
            logo: logo.toDomain(),
            foundedDate: formatter.date(from: foundedDate) ?? Date(),
            ownerId: UUID(uuidString: ownerId) ?? UUID(),
            level: level,
            experience: experience,
            revenue: Decimal(string: revenue) ?? 0,
            valuation: Decimal(string: valuation) ?? 0,
            lastRevenueCalculation: formatter.date(from: lastRevenueCalculation) ?? Date(),
            upgrades: upgrades.compactMap { UUID(uuidString: $0) },
            managers: managers.compactMap { UUID(uuidString: $0) },
            totalShares: totalShares,
            publicShares: publicShares
        )
    }

    static func fromDomain(_ company: Company) -> CompanyDTO {
        let formatter = ISO8601DateFormatter()

        return CompanyDTO(
            id: company.id.uuidString,
            name: company.name,
            ticker: company.ticker,
            industry: company.industry.rawValue,
            logo: CompanyLogoDTO.fromDomain(company.logo),
            foundedDate: formatter.string(from: company.foundedDate),
            ownerId: company.ownerId.uuidString,
            level: company.level,
            experience: company.experience,
            revenue: "\(company.revenue)",
            valuation: "\(company.valuation)",
            lastRevenueCalculation: formatter.string(from: company.lastRevenueCalculation),
            upgrades: company.upgrades.map { $0.uuidString },
            managers: company.managers.map { $0.uuidString },
            totalShares: company.totalShares,
            publicShares: company.publicShares
        )
    }
}

struct CompanyLogoDTO: Codable {
    let iconName: String
    let backgroundColor: String
    let foregroundColor: String

    func toDomain() -> CompanyLogo {
        return CompanyLogo(
            iconName: iconName,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor
        )
    }

    static func fromDomain(_ logo: CompanyLogo) -> CompanyLogoDTO {
        return CompanyLogoDTO(
            iconName: logo.iconName,
            backgroundColor: logo.backgroundColor,
            foregroundColor: logo.foregroundColor
        )
    }
}
