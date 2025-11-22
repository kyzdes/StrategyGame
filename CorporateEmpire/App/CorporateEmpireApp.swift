//
//  CorporateEmpireApp.swift
//  CorporateEmpire
//
//  Main App Entry Point
//

import SwiftUI

@main
struct CorporateEmpireApp: App {
    @StateObject private var appCoordinator: AppCoordinator

    init() {
        // Initialize dependency container
        let container = DefaultDependencyContainer.shared

        // Initialize app coordinator
        _appCoordinator = StateObject(wrappedValue: AppCoordinator(container: container))

        // Configure appearance
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            appCoordinator.start()
                .onAppear {
                    appCoordinator.handleAppLaunch()
                }
        }
    }

    private func configureAppearance() {
        // Configure navigation bar appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance

        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}
