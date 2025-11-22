# Architecture Documentation

## Overview

Corporate Empire follows **Clean Architecture** principles combined with **MVVM** pattern and **Coordinator** pattern for navigation. This architecture ensures:

- **Separation of Concerns**: Each layer has a single responsibility
- **Testability**: Business logic is independent of frameworks
- **Maintainability**: Changes in one layer don't affect others
- **Scalability**: Easy to add new features

## Architecture Layers

```
┌─────────────────────────────────────────┐
│      Presentation Layer (SwiftUI)       │
│  Views, ViewModels, Coordinators        │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Domain Layer (Business)         │
│  Entities, Use Cases, Repositories      │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│          Data Layer (Services)          │
│  DTOs, Repository Impls, Network        │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│       Core Layer (Infrastructure)       │
│  API Client, Storage, DI Container      │
└─────────────────────────────────────────┘
```

## Layer Details

### 1. Presentation Layer

**Responsibility**: Display data and handle user interaction

**Components**:
- **Views** (SwiftUI): UI components that display data
- **ViewModels**: Presentation logic, state management
- **Coordinators**: Navigation flow management

**Example Flow**:
```swift
DashboardView → DashboardViewModel → Use Cases → Repositories
```

**Key Principles**:
- Views are dumb - they only display data
- ViewModels contain presentation logic
- ViewModels communicate with Domain layer via Use Cases
- Coordinators handle navigation

### 2. Domain Layer

**Responsibility**: Core business logic, independent of frameworks

**Components**:
- **Entities**: Core business models (Player, Company, Stock, etc.)
- **Use Cases**: Business operations (CreateCompany, PlaceOrder, etc.)
- **Repository Protocols**: Data access interfaces

**Key Principles**:
- No dependencies on UI or frameworks
- Pure Swift models (Codable, Equatable)
- Business rules are enforced here
- Repository protocols define data access, not implementation

**Example Entity**:
```swift
struct Company: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let industry: Industry
    var level: Int
    var revenue: Decimal

    func calculateRevenuePerSecond(
        upgradeMultiplier: Double,
        managerMultiplier: Double,
        prestigeBonus: Double
    ) -> Decimal {
        // Business logic here
    }
}
```

**Example Use Case**:
```swift
protocol CreateCompanyUseCase {
    func execute(request: CompanyCreationRequest, ownerId: UUID) async throws -> Company
}

final class DefaultCreateCompanyUseCase: CreateCompanyUseCase {
    private let companyRepository: CompanyRepository
    private let playerRepository: PlayerRepository

    func execute(request: CompanyCreationRequest, ownerId: UUID) async throws -> Company {
        // Validate
        try request.validate()

        // Check funds
        let player = try await playerRepository.getPlayer(id: ownerId)
        guard player.canAfford(cash: request.initialCapital) else {
            throw CompanyValidationError.insufficientCapital
        }

        // Create company
        let company = Company(...)
        try await companyRepository.createCompany(company)

        // Update player
        player.cash -= request.initialCapital
        try await playerRepository.updatePlayer(player)

        return company
    }
}
```

### 3. Data Layer

**Responsibility**: Data access and transformation

**Components**:
- **DTOs**: Data Transfer Objects for API communication
- **Repository Implementations**: Concrete implementations of repository protocols
- **Services**: Network and local data services

**Key Principles**:
- DTOs map between API and Domain models
- Repositories implement caching strategy
- Network failures are handled gracefully
- Data is validated before transformation

**Example Repository**:
```swift
final class DefaultPlayerRepository: PlayerRepository {
    private let apiClient: APIClient
    private let coreDataStack: CoreDataStack

    func getPlayer(id: UUID) async throws -> Player {
        // Try cache first
        if let cached = try? fetchPlayerFromCache(id: id) {
            return cached
        }

        // Fetch from API
        let dto: PlayerDTO = try await apiClient.request(endpoint)
        let player = dto.toDomain()

        // Cache result
        try? cachePlayer(player)

        return player
    }
}
```

### 4. Core Layer

**Responsibility**: Infrastructure and utilities

**Components**:
- **APIClient**: HTTP networking
- **WebSocketManager**: Real-time updates
- **CoreDataStack**: Local persistence
- **KeychainManager**: Secure storage
- **DependencyContainer**: Dependency injection

**Key Principles**:
- Framework-specific code isolated here
- Reusable across the app
- No business logic
- Easy to swap implementations

## Data Flow

### Read Flow (Display Data)
```
View → ViewModel → Use Case → Repository → Data Source
                                              ↓
View ← ViewModel ← Use Case ← Repository ← Domain Model
```

### Write Flow (User Action)
```
View (User Action)
  ↓
ViewModel
  ↓
Use Case (Business Logic)
  ↓
Repository (Save)
  ↓
Data Source (API + Cache)
```

### Real-time Update Flow
```
WebSocket → Repository → Use Case → ViewModel → View
```

## Dependency Injection

We use a simple DI container for managing dependencies:

```swift
protocol DependencyContainer {
    var apiClient: APIClient { get }
    var playerRepository: PlayerRepository { get }
    var createCompanyUseCase: CreateCompanyUseCase { get }
}

final class DefaultDependencyContainer: DependencyContainer {
    lazy var apiClient: APIClient = DefaultAPIClient(...)

    lazy var playerRepository: PlayerRepository =
        DefaultPlayerRepository(
            apiClient: apiClient,
            coreDataStack: coreDataStack
        )

    lazy var createCompanyUseCase: CreateCompanyUseCase =
        DefaultCreateCompanyUseCase(
            companyRepository: companyRepository,
            playerRepository: playerRepository
        )
}
```

**Benefits**:
- Easy to test (inject mocks)
- Single source of truth for dependencies
- Lazy initialization
- Protocol-based (easy to swap implementations)

## Navigation Pattern

We use the Coordinator pattern for navigation:

```swift
final class AppCoordinator: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = true

    func start() -> some View {
        if isLoading {
            SplashView()
        } else if isAuthenticated {
            MainTabView()
        } else {
            AuthenticationView()
        }
    }
}
```

**Benefits**:
- Centralized navigation logic
- Views don't know about navigation
- Easy to test navigation flows
- Supports deep linking

## Async/Await & Combine

We use both Swift Concurrency and Combine:

**Swift Concurrency** (async/await):
- Use Cases
- Repository methods
- Network requests
- One-shot operations

**Combine**:
- WebSocket streams
- Real-time updates
- Observable state in ViewModels
- Reactive bindings

```swift
// Swift Concurrency
func loadData() async throws -> Player {
    return try await playerRepository.getCurrentPlayer()
}

// Combine
func subscribeToStockUpdates() -> AnyPublisher<StockUpdate, Never> {
    return webSocketManager.subscribe(to: .stockPriceUpdate)
}
```

## Error Handling

Errors are typed and localized:

```swift
enum CompanyError: LocalizedError {
    case notFound
    case notOwner
    case insufficientLevel

    var errorDescription: String? {
        switch self {
        case .notFound: return "Company not found"
        case .notOwner: return "You don't own this company"
        case .insufficientLevel: return "Company level too low"
        }
    }
}
```

ViewModels catch errors and display to user:

```swift
@MainActor
func loadCompanies() async {
    do {
        companies = try await repository.getCompanies()
    } catch {
        errorMessage = error.localizedDescription
        showError = true
    }
}
```

## Testing Strategy

### Unit Tests
- Domain layer (Entities, Use Cases)
- Repository implementations
- ViewModels

### Integration Tests
- Full data flow (API → Repository → Use Case → ViewModel)
- Authentication flow
- Critical user journeys

### UI Tests
- Main user flows
- Critical screens
- Purchase flows

## Performance Considerations

### Caching Strategy
1. **Memory Cache**: Recently accessed data
2. **Disk Cache**: CoreData for offline access
3. **Cache Invalidation**: TTL-based + manual invalidation

### Pagination
- Load data in batches (20-50 items)
- Infinite scroll for lists
- Prefetch next page

### Background Processing
- Offline revenue calculation in background
- Sync in background when app returns
- Silent push for critical updates

### Memory Management
- Lazy loading of images
- Dispose of unused ViewModels
- Clear caches on memory warning

## Security Architecture

### Authentication
```
User → Login → API → JWT Token → Keychain
                                     ↓
All API requests include token in header
```

### Data Protection
- Sensitive data in Keychain
- HTTPS only
- Certificate pinning
- No sensitive data in logs

### Anti-Cheat
- Server-authoritative for all currency/assets
- Client calculations for UI only
- All transactions validated server-side
- Anomaly detection for suspicious activity

## Scalability

The architecture supports:

1. **Horizontal Features**: Easy to add new features (new Use Case + Repository)
2. **Vertical Features**: Easy to modify existing features (change Use Case logic)
3. **A/B Testing**: Feature flags in Use Cases
4. **Modularization**: Each feature can become a module
5. **Team Scaling**: Teams can work on different layers independently

## Best Practices

1. **Domain First**: Start with Domain models and Use Cases
2. **Protocol-Oriented**: Use protocols for abstractions
3. **Composition Over Inheritance**: Prefer composition
4. **Immutability**: Use `let` over `var` where possible
5. **Value Types**: Prefer structs over classes for models
6. **Error Handling**: Use typed errors, not strings
7. **Documentation**: Document complex business logic
8. **Testing**: Test business logic thoroughly

## Future Improvements

1. **Modularization**: Split into SPM modules
2. **Offline-First**: Better offline support
3. **GraphQL**: Replace REST with GraphQL
4. **SwiftData**: Migrate from CoreData
5. **Observation Framework**: Use new Observation framework (iOS 17+)
