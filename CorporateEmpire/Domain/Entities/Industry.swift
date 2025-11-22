//
//  Industry.swift
//  CorporateEmpire
//
//  Domain Entity - Industry Types
//

import Foundation

enum Industry: String, CaseIterable, Codable {
    case technology
    case finance
    case retail
    case energy
    case healthcare
    case manufacturing
    case entertainment
    case transportation
    case realEstate
    case agriculture

    var displayName: String {
        switch self {
        case .technology: return "Technology"
        case .finance: return "Finance"
        case .retail: return "Retail"
        case .energy: return "Energy"
        case .healthcare: return "Healthcare"
        case .manufacturing: return "Manufacturing"
        case .entertainment: return "Entertainment"
        case .transportation: return "Transportation"
        case .realEstate: return "Real Estate"
        case .agriculture: return "Agriculture"
        }
    }

    var description: String {
        switch self {
        case .technology:
            return "Innovation-driven companies focused on software, hardware, and digital services"
        case .finance:
            return "Banking, investment, and financial services institutions"
        case .retail:
            return "Consumer-facing businesses selling products directly to customers"
        case .energy:
            return "Power generation, oil & gas, and renewable energy companies"
        case .healthcare:
            return "Medical services, pharmaceuticals, and health technology"
        case .manufacturing:
            return "Production and industrial companies creating physical goods"
        case .entertainment:
            return "Media, gaming, and entertainment content providers"
        case .transportation:
            return "Logistics, shipping, and passenger transport services"
        case .realEstate:
            return "Property development and real estate investment"
        case .agriculture:
            return "Farming, food production, and agricultural technology"
        }
    }

    /// Base revenue multiplier for this industry
    var baseMultiplier: Double {
        switch self {
        case .technology: return 1.5
        case .finance: return 1.3
        case .retail: return 1.0
        case .energy: return 1.4
        case .healthcare: return 1.2
        case .manufacturing: return 1.1
        case .entertainment: return 1.3
        case .transportation: return 1.0
        case .realEstate: return 1.4
        case .agriculture: return 0.9
        }
    }
}
