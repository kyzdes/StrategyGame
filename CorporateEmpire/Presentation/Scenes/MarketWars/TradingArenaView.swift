//
//  TradingArenaView.swift
//  CorporateEmpire
//
//  Stock Market Wars - Trading Arena View (v2.0)
//

import SwiftUI

struct TradingArenaView: View {
    @StateObject var viewModel: TradingArenaViewModel
    @State private var selectedArenaType: ArenaType = .quickBattle
    @State private var showArenaLobby = false

    var body: some View {
        NavigationView {
            ZStack {
                // Animated background
                AnimatedTradingBackground()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Competitive Rank Card
                        if let profile = viewModel.competitiveProfile {
                            CompetitiveRankCard(profile: profile)
                                .padding(.horizontal)
                        }

                        // Arena Types
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Select Battle Type")
                                .font(AppFonts.title3)
                                .foregroundColor(.white)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: Spacing.md) {
                                    ForEach(ArenaType.allCases, id: \.self) { type in
                                        ArenaTypeCard(
                                            type: type,
                                            isSelected: type == selectedArenaType
                                        ) {
                                            selectedArenaType = type
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Active Arenas
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Live Arenas")
                                .font(AppFonts.title3)
                                .foregroundColor(.white)
                                .padding(.horizontal)

                            ForEach(viewModel.activeArenas) { arena in
                                ArenaCard(arena: arena) {
                                    viewModel.selectedArena = arena
                                    showArenaLobby = true
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Leaderboards
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Top Traders Today")
                                .font(AppFonts.title3)
                                .foregroundColor(.white)
                                .padding(.horizontal)

                            LeaderboardPreview(entries: viewModel.topTraders)
                                .padding(.horizontal)
                        }

                        // Quick Stats
                        PersonalStatsCard(profile: viewModel.competitiveProfile)
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Market Wars")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.findMatch(type: selectedArenaType)
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Quick Match")
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(CornerRadius.md)
                    }
                }
            }
            .sheet(isPresented: $showArenaLobby) {
                if let arena = viewModel.selectedArena {
                    ArenaLobbyView(arena: arena, viewModel: viewModel)
                }
            }
            .task {
                await viewModel.loadData()
            }
        }
    }
}

// MARK: - Animated Background

struct AnimatedTradingBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "#0f2027"),
                    Color(hex: "#203a43"),
                    Color(hex: "#2c5364")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Animated particles
            ForEach(0..<20) { i in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: CGFloat.random(in: 2...8))
                    .position(
                        x: animate ? CGFloat.random(in: 0...400) : CGFloat.random(in: 0...400),
                        y: animate ? CGFloat.random(in: 0...800) : CGFloat.random(in: 0...800)
                    )
                    .animation(
                        Animation.linear(duration: Double.random(in: 10...20))
                            .repeatForever(autoreverses: false),
                        value: animate
                    )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Competitive Rank Card

struct CompetitiveRankCard: View {
    let profile: CompetitiveProfile

    var body: some View {
        HStack(spacing: Spacing.lg) {
            // Rank Icon
            ZStack {
                Circle()
                    .fill(Color(hex: profile.rank.color).opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: profile.rank.icon)
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: profile.rank.color))
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(profile.rank.displayName)
                    .font(AppFonts.title2)
                    .foregroundColor(.white)

                Text("\(profile.rankPoints) RP")
                    .font(AppFonts.headline)
                    .foregroundColor(Color(hex: profile.rank.color))

                // Progress to next rank
                if let nextRank = nextRank(current: profile.rank) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Next: \(nextRank.displayName)")
                            .font(AppFonts.caption)
                            .foregroundColor(.white.opacity(0.7))

                        ProgressView(value: rankProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: nextRank.color)))
                    }
                }
            }

            Spacer()

            // Win Rate
            VStack {
                Text("\(Int(profile.winRate))%")
                    .font(AppFonts.title2)
                    .foregroundColor(.green)

                Text("Win Rate")
                    .font(AppFonts.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color(hex: profile.rank.color).opacity(0.3), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(CornerRadius.lg)
    }

    private var rankProgress: Double {
        guard let next = nextRank(current: profile.rank) else { return 1.0 }
        let current = profile.rank.minPoints
        let target = next.minPoints
        let points = profile.rankPoints

        return Double(points - current) / Double(target - current)
    }

    private func nextRank(current: CompetitiveRank) -> CompetitiveRank? {
        let ranks = CompetitiveRank.allCases
        guard let index = ranks.firstIndex(of: current),
              index < ranks.count - 1 else {
            return nil
        }
        return ranks[index + 1]
    }
}

// MARK: - Arena Type Card

struct ArenaTypeCard: View {
    let type: ArenaType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)

                    Spacer()

                    Text("\(Int(type.duration / 60))min")
                        .font(AppFonts.caption)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(4)
                }

                Text(type.displayName)
                    .font(AppFonts.headline)

                Text("\(type.maxParticipants) players")
                    .font(AppFonts.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .foregroundColor(.white)
            .padding()
            .frame(width: 180, height: 140)
            .background(
                isSelected ?
                    LinearGradient(
                        colors: [Color.green.opacity(0.8), Color.green.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(
                        colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
            )
            .cornerRadius(CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
    }

    private var icon: String {
        switch type {
        case .quickBattle: return "bolt.fill"
        case .speedTrading: return "hare.fill"
        case .marathon: return "figure.run"
        case .ranked: return "star.fill"
        case .tournament: return "trophy.fill"
        }
    }
}

// MARK: - Arena Card

struct ArenaCard: View {
    let arena: TradingArena
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(arena.type.displayName)
                            .font(AppFonts.headline)

                        Text("\(arena.participants.count)/\(arena.maxParticipants) Players")
                            .font(AppFonts.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    if arena.isActive {
                        LiveIndicator()
                    }

                    Image(systemName: "chevron.right")
                }

                // Prize Pool
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.yellow)
                    Text("Prize: \(arena.prizePool.totalCash.formatted())")
                        .font(AppFonts.callout)
                }

                // Time Remaining
                if arena.isActive {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.orange)
                        Text("Ends in \(formatTime(arena.remainingTime))")
                            .font(AppFonts.callout)
                    }
                }
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(CornerRadius.md)
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        let secs = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, secs)
    }
}

struct LiveIndicator: View {
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
                .scaleEffect(pulse ? 1.2 : 1.0)
                .opacity(pulse ? 0.5 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                    value: pulse
                )

            Text("LIVE")
                .font(AppFonts.caption)
                .fontWeight(.bold)
                .foregroundColor(.red)
        }
        .onAppear {
            pulse = true
        }
    }
}

// MARK: - Leaderboard Preview

struct LeaderboardPreview: View {
    let entries: [ArenaLeaderboard.LeaderboardEntry]

    var body: some View {
        VStack(spacing: Spacing.xs) {
            ForEach(entries.prefix(5)) { entry in
                HStack {
                    // Position
                    Text("#\(entry.position)")
                        .font(AppFonts.headline)
                        .foregroundColor(positionColor(entry.position))
                        .frame(width: 40)

                    // Rank Icon
                    Image(systemName: entry.rank.icon)
                        .foregroundColor(Color(hex: entry.rank.color))

                    // Name
                    Text(entry.playerName)
                        .font(AppFonts.callout)

                    Spacer()

                    // Value
                    Text(entry.value.formatted())
                        .font(AppFonts.moneySmall)
                        .foregroundColor(.green)
                }
                .foregroundColor(.white)
                .padding(.vertical, Spacing.xs)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(CornerRadius.md)
    }

    private func positionColor(_ position: Int) -> Color {
        switch position {
        case 1: return .yellow
        case 2: return Color(hex: "#C0C0C0")
        case 3: return Color(hex: "#CD7F32")
        default: return .white
        }
    }
}

// MARK: - Personal Stats Card

struct PersonalStatsCard: View {
    let profile: CompetitiveProfile?

    var body: some View {
        if let profile = profile {
            VStack(spacing: Spacing.md) {
                Text("Your Statistics")
                    .font(AppFonts.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: Spacing.lg) {
                    StatItem(
                        title: "Matches",
                        value: "\(profile.matchesPlayed)",
                        icon: "gamecontroller.fill"
                    )

                    StatItem(
                        title: "Wins",
                        value: "\(profile.matchesWon)",
                        icon: "trophy.fill",
                        color: .yellow
                    )

                    StatItem(
                        title: "Best Profit",
                        value: profile.bestProfit.formatted(),
                        icon: "chart.line.uptrend.xyaxis",
                        color: .green
                    )
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(CornerRadius.md)
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    var color: Color = .white

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(AppFonts.headline)
                .foregroundColor(.white)

            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Arena Lobby View

struct ArenaLobbyView: View {
    let arena: TradingArena
    @ObservedObject var viewModel: TradingArenaViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                Text("Arena Lobby - Coming Soon!")
                    .font(AppFonts.title)

                Text("Join the battle and trade your way to victory!")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
            }
            .navigationTitle("Battle Lobby")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - ViewModel

@MainActor
final class TradingArenaViewModel: ObservableObject {
    @Published var competitiveProfile: CompetitiveProfile?
    @Published var activeArenas: [TradingArena] = []
    @Published var topTraders: [ArenaLeaderboard.LeaderboardEntry] = []
    @Published var selectedArena: TradingArena?
    @Published var isLoading = false

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func loadData() async {
        isLoading = true

        do {
            let player = try await container.playerRepository.getCurrentPlayer()
            // Would load real data from repositories
            // For now, create sample data
            competitiveProfile = CompetitiveProfile(playerId: player.id)
            isLoading = false
        } catch {
            isLoading = false
        }
    }

    func findMatch(type: ArenaType) {
        print("Finding match for \(type.displayName)")
        // Would call matchmaking service
    }
}

// MARK: - ArenaType Extension

extension ArenaType: CaseIterable {
    static var allCases: [ArenaType] {
        [.quickBattle, .speedTrading, .marathon, .ranked, .tournament]
    }
}
