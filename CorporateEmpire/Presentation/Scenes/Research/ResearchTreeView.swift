//
//  ResearchTreeView.swift
//  CorporateEmpire
//
//  Research Tree - Main View (v2.0)
//

import SwiftUI

struct ResearchTreeView: View {
    @StateObject var viewModel: ResearchTreeViewModel
    @State private var selectedBranch: ResearchBranch = .automation
    @State private var selectedNode: ResearchNode?
    @State private var showNodeDetail = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(hex: "#1a1a2e"), Color(hex: "#16213e")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header Stats
                    ResearchStatsHeader(progress: viewModel.progress)
                        .padding()

                    // Branch Selector
                    BranchSelector(
                        selectedBranch: $selectedBranch,
                        branches: ResearchBranch.allCases
                    )
                    .padding(.horizontal)

                    // Tech Tree ScrollView
                    ScrollView([.horizontal, .vertical]) {
                        TechTreeGrid(
                            nodes: viewModel.nodesByBranch[selectedBranch] ?? [],
                            selectedNode: $selectedNode,
                            onNodeTap: { node in
                                selectedNode = node
                                showNodeDetail = true
                            }
                        )
                        .padding()
                    }
                }
            }
            .navigationTitle("Research Lab")
            .sheet(isPresented: $showNodeDetail) {
                if let node = selectedNode {
                    ResearchNodeDetailView(
                        node: node,
                        onResearch: {
                            Task {
                                await viewModel.startResearch(node: node)
                            }
                        }
                    )
                }
            }
            .task {
                await viewModel.loadData()
            }
        }
    }
}

// MARK: - Research Stats Header

struct ResearchStatsHeader: View {
    let progress: ResearchProgress?

    var body: some View {
        HStack(spacing: Spacing.lg) {
            // Available Points
            StatCard(
                title: "Research Points",
                value: "\(progress?.availablePoints ?? 0)",
                icon: "brain.head.profile",
                color: Color(hex: "#2196F3")
            )

            // Completion
            StatCard(
                title: "Unlocked",
                value: "\(Int((progress?.completionPercentage ?? 0) * 100))%",
                icon: "chart.bar.fill",
                color: Color(hex: "#4CAF50")
            )

            // Active Research
            if progress?.currentResearch != nil {
                StatCard(
                    title: "Researching",
                    value: "1",
                    icon: "clock.fill",
                    color: Color(hex: "#FF9800")
                )
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(CornerRadius.md)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(AppFonts.title2)
                .foregroundColor(.white)

            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(Color.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Branch Selector

struct BranchSelector: View {
    @Binding var selectedBranch: ResearchBranch
    let branches: [ResearchBranch]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(branches, id: \.self) { branch in
                    BranchButton(
                        branch: branch,
                        isSelected: branch == selectedBranch
                    ) {
                        withAnimation {
                            selectedBranch = branch
                        }
                    }
                }
            }
        }
    }
}

struct BranchButton: View {
    let branch: ResearchBranch
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Image(systemName: branch.icon)
                    .font(.title3)

                Text(branch.displayName)
                    .font(AppFonts.caption)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                isSelected ?
                    Color(hex: branch.color) :
                    Color.white.opacity(0.1)
            )
            .foregroundColor(.white)
            .cornerRadius(CornerRadius.md)
        }
    }
}

// MARK: - Tech Tree Grid

struct TechTreeGrid: View {
    let nodes: [ResearchNode]
    @Binding var selectedNode: ResearchNode?
    let onNodeTap: (ResearchNode) -> Void

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.fixed(120), spacing: 40), count: 5),
            spacing: 60
        ) {
            ForEach(nodes) { node in
                ResearchNodeCard(node: node)
                    .onTapGesture {
                        onNodeTap(node)
                    }
            }
        }
        .padding()
    }
}

struct ResearchNodeCard: View {
    let node: ResearchNode

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Icon
            ZStack {
                Circle()
                    .fill(nodeColor)
                    .frame(width: 80, height: 80)

                Image(systemName: node.icon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)

                // Progress ring if researching
                if node.isResearching {
                    Circle()
                        .trim(from: 0, to: node.progress)
                        .stroke(Color.green, lineWidth: 4)
                        .frame(width: 88, height: 88)
                        .rotationEffect(.degrees(-90))
                }

                // Checkmark if completed
                if node.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                        .offset(x: 35, y: -35)
                }

                // Lock if locked
                if !node.isCompleted && !node.isResearching && !node.canBeResearched {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            // Name
            Text(node.name)
                .font(AppFonts.caption)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 32)

            // Tier indicator
            Text("Tier \(node.tier)")
                .font(AppFonts.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(width: 100)
    }

    var nodeColor: Color {
        if node.isCompleted {
            return Color.green.opacity(0.8)
        } else if node.isResearching {
            return Color.orange.opacity(0.8)
        } else if node.canBeResearched {
            return Color(hex: node.branch.color).opacity(0.8)
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}

// MARK: - Node Detail View

struct ResearchNodeDetailView: View {
    let node: ResearchNode
    let onResearch: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Header
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color(hex: node.branch.color))
                                .frame(width: 80, height: 80)

                            Image(systemName: node.icon)
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(node.name)
                                .font(AppFonts.title2)

                            Text(node.branch.displayName)
                                .font(AppFonts.caption)
                                .foregroundColor(Color(hex: node.branch.color))

                            Text("Tier \(node.tier)")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }

                        Spacer()
                    }

                    Divider()

                    // Description
                    Text(node.description)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)

                    // Unlocks
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Unlocks")
                            .font(AppFonts.headline)

                        ForEach(node.unlocks.indices, id: \.self) { index in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(node.unlocks[index].displayText)
                                    .font(AppFonts.callout)
                            }
                        }
                    }

                    Divider()

                    // Cost
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Requirements")
                            .font(AppFonts.headline)

                        HStack {
                            Image(systemName: "brain.head.profile")
                            Text("\(node.cost.points) Research Points")
                        }

                        if let cash = node.cost.cash {
                            HStack {
                                Image(systemName: "dollarsign.circle")
                                Text(cash.formatted())
                            }
                        }

                        if let gems = node.cost.gems {
                            HStack {
                                Image(systemName: "diamond.fill")
                                    .foregroundColor(.cyan)
                                Text("\(gems) Gems")
                            }
                        }

                        HStack {
                            Image(systemName: "clock")
                            Text(formatTime(node.cost.timeRequired))
                        }
                    }

                    Spacer()

                    // Research Button
                    if node.canBeResearched {
                        Button(action: {
                            onResearch()
                            dismiss()
                        }) {
                            Text("Start Research")
                                .font(AppFonts.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: node.branch.color))
                                .cornerRadius(CornerRadius.md)
                        }
                    } else if node.isCompleted {
                        Text("✓ Completed")
                            .font(AppFonts.headline)
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(CornerRadius.md)
                    } else if node.isResearching {
                        VStack {
                            Text("Researching...")
                                .font(AppFonts.headline)

                            ProgressView(value: node.progress)
                                .progressViewStyle(LinearProgressViewStyle())
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(CornerRadius.md)
                    }
                }
                .padding()
            }
            .navigationTitle("Research Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds / 3600)
        let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - ViewModel

@MainActor
final class ResearchTreeViewModel: ObservableObject {
    @Published var progress: ResearchProgress?
    @Published var nodesByBranch: [ResearchBranch: [ResearchNode]] = [:]
    @Published var isLoading = false

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func loadData() async {
        isLoading = true

        do {
            let player = try await container.playerRepository.getCurrentPlayer()
            // Would load from repository
            // For now, create sample data
            nodesByBranch = Dictionary(grouping: ResearchTreeFactory.createFullTree(), by: { $0.branch })

            isLoading = false
        } catch {
            isLoading = false
        }
    }

    func startResearch(node: ResearchNode) async {
        // Would call use case
        print("Starting research: \(node.name)")
    }
}
