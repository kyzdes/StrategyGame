//
//  AppCoordinator.swift
//  CorporateEmpire
//
//  App Coordinator - Main navigation coordinator
//

import SwiftUI
import Combine

final class AppCoordinator: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = true

    private let container: DependencyContainer
    private var cancellables = Set<AnyCancellable>()

    init(container: DependencyContainer) {
        self.container = container
    }

    @ViewBuilder
    func start() -> some View {
        if isLoading {
            SplashView()
        } else if isAuthenticated {
            MainTabView(container: container)
        } else {
            AuthenticationView(coordinator: self, container: container)
        }
    }

    func handleAppLaunch() {
        Task {
            // Simulate checking authentication state
            await checkAuthentication()

            // Calculate offline revenue
            if isAuthenticated {
                await calculateOfflineRevenue()
            }

            await MainActor.run {
                isLoading = false
            }
        }
    }

    func signIn() {
        isAuthenticated = true
    }

    func signOut() {
        isAuthenticated = false

        // Clear keychain
        try? container.keychainManager.deleteAll()
    }

    private func checkAuthentication() async {
        // Check if user has valid auth token
        if let token = try? container.keychainManager.get(key: KeychainKey.authToken),
           !token.isEmpty {
            isAuthenticated = true
        } else {
            isAuthenticated = false
        }

        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }

    private func calculateOfflineRevenue() async {
        guard let playerIdString = try? container.keychainManager.get(key: KeychainKey.userId),
              let playerId = UUID(uuidString: playerIdString) else {
            return
        }

        do {
            let result = try await container.calculateOfflineRevenueUseCase.execute(playerId: playerId)
            print("Offline revenue calculated: \(result.totalRevenue)")
            // Show offline revenue popup to user
        } catch {
            print("Failed to calculate offline revenue: \(error)")
        }
    }
}

// MARK: - Splash View

struct SplashView: View {
    var body: some View {
        ZStack {
            AppColors.primaryGradient
                .ignoresSafeArea()

            VStack(spacing: Spacing.lg) {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)

                Text("Corporate Empire")
                    .font(AppFonts.largeTitle)
                    .foregroundColor(.white)

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
    }
}

// MARK: - Authentication View

struct AuthenticationView: View {
    @ObservedObject var coordinator: AppCoordinator
    let container: DependencyContainer

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack(spacing: Spacing.lg) {
                Spacer()

                // Logo
                Image(systemName: "building.2.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppColors.primary)

                Text("Corporate Empire")
                    .font(AppFonts.title)

                Spacer()

                // Login Form
                VStack(spacing: Spacing.md) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)

                    Button(action: signIn) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Sign In")
                        }
                    }
                    .primaryButton()
                    .disabled(isLoading)

                    Button(action: signUp) {
                        Text("Create Account")
                    }
                    .secondaryButton()
                    .disabled(isLoading)
                }

                Spacer()
            }
            .padding(Spacing.lg)
            .navigationTitle("Welcome")
        }
    }

    private func signIn() {
        isLoading = true

        // Simulate authentication
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Save mock token
            try? container.keychainManager.save(
                key: KeychainKey.authToken,
                value: "mock_token_\(UUID().uuidString)"
            )

            coordinator.signIn()
            isLoading = false
        }
    }

    private func signUp() {
        // Navigate to sign up flow
        print("Sign up tapped")
    }
}
