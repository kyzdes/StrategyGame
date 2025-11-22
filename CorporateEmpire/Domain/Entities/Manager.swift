//
//  Manager.swift
//  CorporateEmpire
//
//  Domain Entity - Company Managers
//

import Foundation

struct Manager: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let biography: String
    let rarity: ManagerRarity
    let specialization: Industry?
    let portraitImageName: String

    var baseMultiplier: Double
    var skills: [ManagerSkill]
    let unlockCost: Decimal
    var currentLevel: Int
    let maxLevel: Int

    var isHired: Bool
    var assignedCompanyId: UUID?

    /// Calculate total multiplier including level bonuses
    var totalMultiplier: Double {
        let levelBonus = 1.0 + (Double(currentLevel) * 0.1)
        let skillBonus = skills.reduce(1.0) { $0 * $1.multiplier }
        return baseMultiplier * levelBonus * skillBonus
    }

    /// Cost to upgrade to next level
    func upgradeCost(forLevel level: Int) -> Decimal {
        let baseCost = unlockCost * 0.5
        return baseCost * Decimal(pow(1.2, Double(level)))
    }

    var canBeUpgraded: Bool {
        isHired && currentLevel < maxLevel
    }

    init(
        id: UUID = UUID(),
        name: String,
        biography: String,
        rarity: ManagerRarity,
        specialization: Industry? = nil,
        portraitImageName: String,
        baseMultiplier: Double,
        skills: [ManagerSkill] = [],
        unlockCost: Decimal,
        currentLevel: Int = 1,
        maxLevel: Int = 50,
        isHired: Bool = false,
        assignedCompanyId: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.biography = biography
        self.rarity = rarity
        self.specialization = specialization
        self.portraitImageName = portraitImageName
        self.baseMultiplier = baseMultiplier
        self.skills = skills
        self.unlockCost = unlockCost
        self.currentLevel = currentLevel
        self.maxLevel = maxLevel
        self.isHired = isHired
        self.assignedCompanyId = assignedCompanyId
    }
}

// MARK: - Manager Rarity

enum ManagerRarity: String, Codable, CaseIterable {
    case common
    case rare
    case epic
    case legendary

    var displayName: String {
        rawValue.capitalized
    }

    var baseMultiplier: Double {
        switch self {
        case .common: return 1.5
        case .rare: return 2.0
        case .epic: return 3.0
        case .legendary: return 5.0
        }
    }

    var color: String {
        switch self {
        case .common: return "#9E9E9E"      // Gray
        case .rare: return "#2196F3"        // Blue
        case .epic: return "#9C27B0"        // Purple
        case .legendary: return "#FF9800"   // Orange
        }
    }

    var dropRate: Double {
        switch self {
        case .common: return 0.60      // 60%
        case .rare: return 0.25        // 25%
        case .epic: return 0.12        // 12%
        case .legendary: return 0.03   // 3%
        }
    }
}

// MARK: - Manager Skill

struct ManagerSkill: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let multiplier: Double
    let unlockLevel: Int

    var iconName: String {
        switch name {
        case "Automation Expert": return "gearshape.2.fill"
        case "Cost Reducer": return "dollarsign.circle.fill"
        case "Innovation Driver": return "lightbulb.fill"
        case "Market Analyst": return "chart.line.uptrend.xyaxis"
        default: return "star.fill"
        }
    }

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        multiplier: Double,
        unlockLevel: Int
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.multiplier = multiplier
        self.unlockLevel = unlockLevel
    }
}

// MARK: - Manager Upgrade

struct ManagerUpgrade: Identifiable, Codable, Equatable {
    let id: UUID
    let level: Int
    let cost: Decimal
    let bonusMultiplier: Double
    let unlockedSkill: ManagerSkill?

    init(
        id: UUID = UUID(),
        level: Int,
        cost: Decimal,
        bonusMultiplier: Double,
        unlockedSkill: ManagerSkill? = nil
    ) {
        self.id = id
        self.level = level
        self.cost = cost
        self.bonusMultiplier = bonusMultiplier
        self.unlockedSkill = unlockedSkill
    }
}

// MARK: - Predefined Managers

extension Manager {
    static func commonManagers() -> [Manager] {
        return [
            Manager(
                name: "Alex Johnson",
                biography: "A reliable operations manager with 10 years of experience",
                rarity: .common,
                portraitImageName: "manager_common_1",
                baseMultiplier: 1.5,
                skills: [
                    ManagerSkill(
                        name: "Efficiency Boost",
                        description: "+20% production speed",
                        multiplier: 1.2,
                        unlockLevel: 1
                    )
                ],
                unlockCost: 5_000
            ),
            Manager(
                name: "Sarah Chen",
                biography: "Detail-oriented finance professional",
                rarity: .common,
                portraitImageName: "manager_common_2",
                baseMultiplier: 1.5,
                skills: [
                    ManagerSkill(
                        name: "Cost Reducer",
                        description: "Reduces operational costs by 15%",
                        multiplier: 1.15,
                        unlockLevel: 1
                    )
                ],
                unlockCost: 5_000
            )
        ]
    }

    static func rareManagers() -> [Manager] {
        return [
            Manager(
                name: "Dr. Marcus Lee",
                biography: "Visionary leader with multiple successful startups",
                rarity: .rare,
                specialization: .technology,
                portraitImageName: "manager_rare_1",
                baseMultiplier: 2.0,
                skills: [
                    ManagerSkill(
                        name: "Innovation Driver",
                        description: "+50% tech development speed",
                        multiplier: 1.5,
                        unlockLevel: 1
                    ),
                    ManagerSkill(
                        name: "Team Synergy",
                        description: "Boosts all manager effectiveness by 25%",
                        multiplier: 1.25,
                        unlockLevel: 10
                    )
                ],
                unlockCost: 50_000
            )
        ]
    }

    static func epicManagers() -> [Manager] {
        return [
            Manager(
                name: "Victoria Blackwood",
                biography: "Former Fortune 500 CEO, industry legend",
                rarity: .epic,
                specialization: .finance,
                portraitImageName: "manager_epic_1",
                baseMultiplier: 3.0,
                skills: [
                    ManagerSkill(
                        name: "Market Mastery",
                        description: "Triples revenue from financial operations",
                        multiplier: 3.0,
                        unlockLevel: 1
                    ),
                    ManagerSkill(
                        name: "Golden Touch",
                        description: "Increases all company revenue by 50%",
                        multiplier: 1.5,
                        unlockLevel: 15
                    ),
                    ManagerSkill(
                        name: "Risk Management",
                        description: "Reduces market volatility impact",
                        multiplier: 1.3,
                        unlockLevel: 25
                    )
                ],
                unlockCost: 500_000
            )
        ]
    }

    static func legendaryManagers() -> [Manager] {
        return [
            Manager(
                name: "Phoenix Wright",
                biography: "Mythical business titan, builder of empires",
                rarity: .legendary,
                portraitImageName: "manager_legendary_1",
                baseMultiplier: 5.0,
                skills: [
                    ManagerSkill(
                        name: "Empire Builder",
                        description: "5x multiplier to all revenue sources",
                        multiplier: 5.0,
                        unlockLevel: 1
                    ),
                    ManagerSkill(
                        name: "Automation Expert",
                        description: "Doubles offline earnings",
                        multiplier: 2.0,
                        unlockLevel: 10
                    ),
                    ManagerSkill(
                        name: "Universal Genius",
                        description: "Works perfectly in any industry",
                        multiplier: 2.5,
                        unlockLevel: 20
                    ),
                    ManagerSkill(
                        name: "Prestige Mastery",
                        description: "Increases prestige point gains by 100%",
                        multiplier: 2.0,
                        unlockLevel: 30
                    )
                ],
                unlockCost: 10_000_000
            )
        ]
    }

    static func allPredefinedManagers() -> [Manager] {
        return commonManagers() + rareManagers() + epicManagers() + legendaryManagers()
    }
}
