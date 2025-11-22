//
//  ProfileView.swift
//  CorporateEmpire
//
//  Profile - View
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel

    var body: some View {
        NavigationView {
            VStack {
                if let player = viewModel.player {
                    Text(player.username)
                        .font(AppFonts.title)
                    Text("Level \(player.level)")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .navigationTitle("Profile")
            .task {
                await viewModel.loadProfile()
            }
        }
    }
}
