//
//  CompaniesView.swift
//  CorporateEmpire
//
//  Companies - View
//

import SwiftUI

struct CompaniesView: View {
    @StateObject var viewModel: CompaniesViewModel

    var body: some View {
        NavigationView {
            List(viewModel.companies) { company in
                CompanyRow(company: company)
            }
            .navigationTitle("Companies")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: createCompany) {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await viewModel.loadCompanies()
            }
        }
    }

    private func createCompany() {
        // Show create company sheet
    }
}

struct CompanyRow: View {
    let company: Company

    var body: some View {
        HStack {
            Circle()
                .fill(AppColors.industryColor(company.industry))
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: company.logo.iconName)
                        .foregroundColor(.white)
                }

            VStack(alignment: .leading) {
                Text(company.name)
                    .font(AppFonts.headline)

                Text("\(company.industry.displayName) • Lv.\(company.level)")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(company.valuation.formatted())
                    .font(AppFonts.moneySmall)

                Text("\(company.revenue.formatted())/s")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
}
