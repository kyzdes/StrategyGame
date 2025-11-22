//
//  MainTabView.swift
//  CorporateEmpire
//
//  Main Tab Bar View
//

import SwiftUI

struct MainTabView: View {
    let container: DependencyContainer
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard
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

            // Trading
            TradingView(viewModel: TradingViewModel(container: container))
                .tabItem {
                    Label("Trading", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)

            // Social
            SocialView(viewModel: SocialViewModel(container: container))
                .tabItem {
                    Label("Social", systemImage: "person.2.fill")
                }
                .tag(3)

            // Profile
            ProfileView(viewModel: ProfileViewModel(container: container))
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
        .accentColor(AppColors.primary)
    }
}
