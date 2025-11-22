//
//  DashboardView.swift
//  CorporateEmpire
//
//  Dashboard - Main View
//

import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel: DashboardViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Net Worth Card
                    NetWorthCard(
                        netWorth: viewModel.netWorth,
                        change24h: viewModel.change24h
                    )

                    // Quick Actions
                    QuickActionsRow(onCollectIncome: viewModel.collectIncome)

                    // Companies Section
                    if !viewModel.companies.isEmpty {
                        CompaniesSection(companies: viewModel.companies)
                    }

                    // Portfolio Summary
                    if let portfolio = viewModel.portfolio {
                        PortfolioSummaryCard(portfolio: portfolio)
                    }

                    // Placeholder for other sections
                    DailyQuestsPlaceholder()
                    NewsEventsPlaceholder()
                }
                .padding(Spacing.md)
            }
            .navigationTitle("Dashboard")
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadData()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }
}

// MARK: - Net Worth Card

struct NetWorthCard: View {
    let netWorth: Decimal
    let change24h: Double

    var body: some View {
        VStack(spacing: Spacing.sm) {
            Text("Net Worth")
                .font(AppFonts.subheadline)
                .foregroundColor(AppColors.textSecondary)

            Text(netWorth.formatted())
                .font(AppFonts.moneyLarge)
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: Spacing.xs) {
                Image(systemName: change24h >= 0 ? "arrow.up.right" : "arrow.down.right")
                Text(String(format: "%.2f%%", abs(change24h)))
                Text("(24h)")
                    .foregroundColor(AppColors.textSecondary)
            }
            .font(AppFonts.caption)
            .foregroundColor(change24h >= 0 ? AppColors.positive : AppColors.negative)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.lg)
        .cardStyle(shadow: .medium)
    }
}

// MARK: - Quick Actions Row

struct QuickActionsRow: View {
    let onCollectIncome: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            QuickActionButton(
                icon: "dollarsign.circle.fill",
                title: "Collect",
                color: AppColors.positive
            ) {
                onCollectIncome()
            }

            QuickActionButton(
                icon: "chart.line.uptrend.xyaxis",
                title: "Market",
                color: AppColors.primary
            ) {
                // Navigate to market
            }

            QuickActionButton(
                icon: "building.2.fill",
                title: "Corporation",
                color: AppColors.secondary
            ) {
                // Navigate to corporation
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Text(title)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.md)
            .cardStyle()
        }
    }
}

// MARK: - Companies Section

struct CompaniesSection: View {
    let companies: [Company]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Your Companies")
                .font(AppFonts.headline)
                .padding(.horizontal, Spacing.sm)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(companies) { company in
                        CompanyCard(company: company)
                    }
                }
                .padding(.horizontal, Spacing.sm)
            }
        }
    }
}

struct CompanyCard: View {
    let company: Company

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Circle()
                    .fill(AppColors.industryColor(company.industry))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: company.logo.iconName)
                            .foregroundColor(.white)
                    }

                Spacer()

                Text("Lv.\(company.level)")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            Text(company.name)
                .font(AppFonts.headline)
                .lineLimit(1)

            Text(company.industry.displayName)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)

            Divider()

            HStack {
                Text("Revenue")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)

                Spacer()

                Text(company.revenue.formatted())
                    .font(AppFonts.moneySmall)
            }
        }
        .padding(Spacing.md)
        .frame(width: 200)
        .cardStyle()
    }
}

// MARK: - Portfolio Summary

struct PortfolioSummaryCard: View {
    let portfolio: Portfolio

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Portfolio")
                .font(AppFonts.headline)

            HStack {
                VStack(alignment: .leading) {
                    Text("Total Value")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)

                    Text(portfolio.totalValue.formatted())
                        .font(AppFonts.moneyMedium)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("P/L")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)

                    Text(portfolio.totalPL.formatted())
                        .font(AppFonts.moneyMedium)
                        .foregroundColor(portfolio.totalPL >= 0 ? AppColors.positive : AppColors.negative)
                }
            }
        }
        .padding(Spacing.md)
        .cardStyle()
    }
}

// MARK: - Placeholders

struct DailyQuestsPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Daily Quests")
                .font(AppFonts.headline)

            Text("Complete quests to earn rewards")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .cardStyle()
    }
}

struct NewsEventsPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("News & Events")
                .font(AppFonts.headline)

            Text("Stay updated with market events")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .cardStyle()
    }
}

// MARK: - Decimal Extension

extension Decimal {
    func formatted() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: self as NSDecimalNumber) ?? "$0"
    }
}
