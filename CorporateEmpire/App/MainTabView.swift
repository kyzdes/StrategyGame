//
//  MainTabView.swift
//  CorporateEmpire
//
//  Main Tab Bar View - v2.0 Enhanced with 7 tabs
//

import SwiftUI

struct MainTabView: View {
    let container: DependencyContainer
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard - Enhanced with v2.0 features
            DashboardView(viewModel: DashboardViewModel(container: container))
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(0)

            // Companies
            CompaniesView(viewModel: CompaniesViewModel(container: container))
                .tabItem {
                    Label("Companies", systemImage: "building.2.fill")
                }
                .tag(1)

            // Market Wars - NEW v2.0: PvP Trading
            TradingArenaView(viewModel: TradingArenaViewModel(container: container))
                .tabItem {
                    Label("Wars", systemImage: "bolt.shield.fill")
                }
                .tag(2)
                .badge(Text("NEW"))

            // Trading - Enhanced with predictions
            TradingView(viewModel: TradingViewModel(container: container))
                .tabItem {
                    Label("Trading", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(3)

            // Research - NEW v2.0: Tech Tree
            ResearchTreeView(viewModel: ResearchTreeViewModel(container: container))
                .tabItem {
                    Label("Research", systemImage: "brain.head.profile")
                }
                .tag(4)
                .badge(Text("NEW"))

            // Social - Enhanced with Corporation Wars
            SocialView(viewModel: SocialViewModel(container: container))
                .tabItem {
                    Label("Social", systemImage: "person.2.fill")
                }
                .tag(5)

            // Profile - Enhanced with Battle Pass
            ProfileView(viewModel: ProfileViewModel(container: container))
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(6)
        }
        .accentColor(AppColors.primary)
        .onAppear {
            // Configure tab bar appearance for v2.0
            configureTabBarAppearance()
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        // Vibrant blur effect
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
