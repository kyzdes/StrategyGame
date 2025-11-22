//
//  SocialView.swift
//  CorporateEmpire
//
//  Social - View
//

import SwiftUI

struct SocialView: View {
    @StateObject var viewModel: SocialViewModel

    var body: some View {
        NavigationView {
            VStack {
                Text("Social View")
                    .font(AppFonts.title)
                Text("Corporation, friends, and leaderboards")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            .navigationTitle("Social")
            .task {
                await viewModel.loadData()
            }
        }
    }
}
