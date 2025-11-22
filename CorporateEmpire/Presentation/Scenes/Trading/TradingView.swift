//
//  TradingView.swift
//  CorporateEmpire
//
//  Trading - View
//

import SwiftUI

struct TradingView: View {
    @StateObject var viewModel: TradingViewModel

    var body: some View {
        NavigationView {
            VStack {
                Text("Trading View")
                    .font(AppFonts.title)
                Text("Stock market and trading functionality")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            .navigationTitle("Trading")
            .task {
                await viewModel.loadStocks()
            }
        }
    }
}
