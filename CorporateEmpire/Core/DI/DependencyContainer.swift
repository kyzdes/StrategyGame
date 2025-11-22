//
//  DependencyContainer.swift
//  CorporateEmpire
//
//  Core - Dependency Injection Container
//

import Foundation

protocol DependencyContainer {
    // Core
    var apiClient: APIClient { get }
    var webSocketManager: WebSocketManager { get }
    var coreDataStack: CoreDataStack { get }
    var keychainManager: KeychainManager { get }

    // Repositories
    var playerRepository: PlayerRepository { get }
    var companyRepository: CompanyRepository { get }
    var stockRepository: StockRepository { get }
    var corporationRepository: CorporationRepository { get }
    var portfolioRepository: PortfolioRepository { get }
    var upgradeRepository: UpgradeRepository { get }
    var managerRepository: ManagerRepository { get }

    // Use Cases - Company Management
    var createCompanyUseCase: CreateCompanyUseCase { get }
    var purchaseUpgradeUseCase: PurchaseUpgradeUseCase { get }

    // Use Cases - Trading
    var placeOrderUseCase: PlaceOrderUseCase { get }

    // Use Cases - Social
    var createCorporationUseCase: CreateCorporationUseCase { get }

    // Use Cases - Idle Progress
    var calculateOfflineRevenueUseCase: CalculateOfflineRevenueUseCase { get }
}

final class DefaultDependencyContainer: DependencyContainer {
    static let shared = DefaultDependencyContainer()

    private init() {}

    // MARK: - Core

    lazy var apiClient: APIClient = {
        DefaultAPIClient(baseURL: EndpointConfiguration.baseURL)
    }()

    lazy var webSocketManager: WebSocketManager = {
        DefaultWebSocketManager(url: WebSocketConfiguration.url)
    }()

    lazy var coreDataStack: CoreDataStack = {
        DefaultCoreDataStack.shared
    }()

    lazy var keychainManager: KeychainManager = {
        DefaultKeychainManager()
    }()

    // MARK: - Repositories

    lazy var playerRepository: PlayerRepository = {
        DefaultPlayerRepository(
            apiClient: apiClient,
            coreDataStack: coreDataStack
        )
    }()

    lazy var companyRepository: CompanyRepository = {
        DefaultCompanyRepository(
            apiClient: apiClient,
            coreDataStack: coreDataStack
        )
    }()

    lazy var stockRepository: StockRepository = {
        DefaultStockRepository(
            apiClient: apiClient,
            webSocketManager: webSocketManager,
            coreDataStack: coreDataStack
        )
    }()

    lazy var corporationRepository: CorporationRepository = {
        DefaultCorporationRepository(
            apiClient: apiClient,
            coreDataStack: coreDataStack
        )
    }()

    lazy var portfolioRepository: PortfolioRepository = {
        DefaultPortfolioRepository(
            apiClient: apiClient,
            coreDataStack: coreDataStack
        )
    }()

    lazy var upgradeRepository: UpgradeRepository = {
        DefaultUpgradeRepository(
            apiClient: apiClient,
            coreDataStack: coreDataStack
        )
    }()

    lazy var managerRepository: ManagerRepository = {
        DefaultManagerRepository(
            apiClient: apiClient,
            coreDataStack: coreDataStack
        )
    }()

    // MARK: - Use Cases - Company Management

    lazy var createCompanyUseCase: CreateCompanyUseCase = {
        DefaultCreateCompanyUseCase(
            companyRepository: companyRepository,
            playerRepository: playerRepository
        )
    }()

    lazy var purchaseUpgradeUseCase: PurchaseUpgradeUseCase = {
        DefaultPurchaseUpgradeUseCase(
            companyRepository: companyRepository,
            playerRepository: playerRepository,
            upgradeRepository: upgradeRepository
        )
    }()

    // MARK: - Use Cases - Trading

    lazy var placeOrderUseCase: PlaceOrderUseCase = {
        DefaultPlaceOrderUseCase(
            stockRepository: stockRepository,
            playerRepository: playerRepository,
            portfolioRepository: portfolioRepository,
            tradingEngine: DefaultTradingEngine()
        )
    }()

    // MARK: - Use Cases - Social

    lazy var createCorporationUseCase: CreateCorporationUseCase = {
        DefaultCreateCorporationUseCase(
            corporationRepository: corporationRepository,
            playerRepository: playerRepository
        )
    }()

    // MARK: - Use Cases - Idle Progress

    lazy var calculateOfflineRevenueUseCase: CalculateOfflineRevenueUseCase = {
        DefaultCalculateOfflineRevenueUseCase(
            companyRepository: companyRepository,
            playerRepository: playerRepository,
            managerRepository: managerRepository,
            upgradeRepository: upgradeRepository
        )
    }()
}

// MARK: - Default Trading Engine

final class DefaultTradingEngine: TradingEngine {
    private let commissionRate: Double = 0.001 // 0.1% commission

    func calculateCommission(amount: Decimal) -> Decimal {
        return amount * Decimal(commissionRate)
    }

    func executeOrder(_ order: StockOrder) async throws -> OrderResult {
        // This would be implemented with actual trading logic
        // For now, return a placeholder
        fatalError("Not implemented")
    }
}
