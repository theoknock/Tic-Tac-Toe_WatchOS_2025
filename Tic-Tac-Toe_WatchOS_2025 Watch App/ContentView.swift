//
//  ContentView.swift
//  Tic-Tac-Toe_WatchOS_2025 Watch App
//
//  Created by Xcode Developer on 12/7/25.
//

import SwiftUI
import Observation
import Combine

struct ContentView: View {
    @State private var game = TicTacToeGame()
    @State private var celebrationScale: CGFloat = 1.0
    @State private var showingStats = false
    @State private var showingAbout = true

    var body: some View {
        NavigationStack {
            if showingAbout {
                AboutView()
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showingAbout = false
                            }
                        }
                    }
            } else if game.shouldShowStatistics {
                StatisticsView(game: game, celebrationScale: $celebrationScale)
                    .transition(.opacity)
            } else if game.gameOver || game.isPaused {
                ButtonMenuView(game: game, celebrationScale: $celebrationScale)
                    .transition(.opacity)
            } else {
                BoardView(game: game, celebrationScale: $celebrationScale)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingAbout)
        .animation(.easeInOut(duration: 0.3), value: game.shouldShowStatistics)
        .animation(.easeInOut(duration: 0.3), value: game.gameOver)
        .animation(.easeInOut(duration: 0.3), value: game.isPaused)
    }
}

struct BoardView: View {
    let game: TicTacToeGame
    @Binding var celebrationScale: CGFloat

    var body: some View {
        VStack(spacing: .small) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: .small) {
                ForEach(game.cells) { cell in
                    CellView(player: cell.player, isWinningCell: game.isWinningCell(cell.id), theme: game.currentTheme)
                        .onTapGesture {
                            game.makeMove(at: cell.id)
                        }
                }
            }
            .padding(.horizontal, .medium)
            .id(game.gameID)
            .background(game.currentTheme.boardBackground)
        }
        .padding(.vertical, .small)
        .onLongPressGesture(minimumDuration: 0.5) {
            game.isPaused = true
        }
    }
}

struct ButtonMenuView: View {
    let game: TicTacToeGame
    @Binding var celebrationScale: CGFloat

    var body: some View {
        VStack(spacing: .large) {
            Spacer()

            Button("New Game") {
                celebrationScale = 1.0
                game.isPaused = false
                game.resetGame()
            }
            .buttonStyle(.borderedProminent)

            if !game.gameOver && game.isPaused {
                Button("Resume Game") {
                    game.isPaused = false
                }
                .buttonStyle(.bordered)
            }

            Divider()
                .padding(.vertical, .small)

            HStack(spacing: .medium) {
                NavigationLink(destination: StatisticsView(game: game, celebrationScale: $celebrationScale)) {
                    Image(systemName: "chart.bar.fill")
                        .font(.title3)
                }

                NavigationLink(destination: AlgorithmPickerView(game: game)) {
                    Image(systemName: "cpu")
                        .font(.title3)
                }

                NavigationLink(destination: ThemePickerView(game: game)) {
                    Image(systemName: "paintpalette.fill")
                        .font(.title3)
                }
            }

            Spacer()
        }
        .padding()
    }
}

struct ScoreView: View {
    let playerWins: Int
    let watchWins: Int
    let draws: Int
    let theme: GameTheme

    var body: some View {
        HStack(spacing: .large) {
            VStack(spacing: .xxSmall) {
                Text("You")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("\(playerWins)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(theme.playerXColor)
            }

            VStack(spacing: .xxSmall) {
                Text("Draws")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("\(draws)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            }

            VStack(spacing: .xxSmall) {
                Text("Watch")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("\(watchWins)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(theme.playerOColor)
            }
        }
        .padding(.vertical, .small)
    }
}

struct CellView: View {
    let player: Player?
    let isWinningCell: Bool
    let theme: GameTheme
    @State private var appeared = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: .cornerRadiusMedium)
                .fill(theme.cellBackground)
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    RoundedRectangle(cornerRadius: .cornerRadiusMedium)
                        .stroke(isWinningCell ? theme.winningLineColor : Color.clear, lineWidth: .borderWidthMedium)
                        .opacity(isWinningCell ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isWinningCell)
                )

            if let player = player {
                Text(player.rawValue)
                    .font(.system(size: .fontSizeLarge, weight: .bold))
                    .foregroundColor(player.color(for: theme))
                    .scaleEffect(appeared ? 1.0 : 0.1)
                    .opacity(appeared ? 1.0 : 0.0)
                    .rotationEffect(.degrees(appeared ? 0 : 180))
                    .onAppear {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            appeared = true
                        }
                    }
                    .onChange(of: player) { _, _ in
                        appeared = false
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            appeared = true
                        }
                    }
            }
        }
    }
}

struct ThemePickerView: View {
    let game: TicTacToeGame

    var body: some View {
        ScrollView {
            VStack(spacing: .large) {
                Text("Choose Theme")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.bottom, .small)

                ForEach(GameTheme.allThemes) { theme in
                    ThemePreviewButton(theme: theme, isSelected: game.currentTheme.id == theme.id) {
                        withAnimation {
                            game.currentTheme = theme
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct ThemePreviewButton: View {
    let theme: GameTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: .medium) {
                HStack(spacing: .small) {
                    Text("X")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(theme.playerXColor)
                        .frame(width: .previewCellSize, height: .previewCellSize)
                        .background(theme.cellBackground)
                        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusSmall))

                    Text("O")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(theme.playerOColor)
                        .frame(width: .previewCellSize, height: .previewCellSize)
                        .background(theme.cellBackground)
                        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusSmall))
                }
                .padding(.medium)
                .background(theme.boardBackground)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusMedium))

                Text(theme.name)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .regular)
            }
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadiusLarge)
                    .stroke(isSelected ? Color.white : Color.clear, lineWidth: .borderWidthThin)
            )
        }
        .buttonStyle(.plain)
    }
}

struct StatisticsView: View {
    let game: TicTacToeGame
    @Binding var celebrationScale: CGFloat

    var body: some View {
        ScrollView {
            VStack(spacing: .large) {
                if game.gameOver {
                    Text(game.statusMessage)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(game.winner?.color(for: game.currentTheme) ?? .white)
                        .scaleEffect(celebrationScale)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: celebrationScale)
                        .onAppear {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                celebrationScale = 1.2
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                    celebrationScale = 1.0
                                }
                            }
                        }

                    Button("New Game") {
                        celebrationScale = 1.0
                        game.resetGame()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom, .small)
                }

                Text("Statistics")
                    .font(.title3)
                    .fontWeight(.bold)

                ScoreView(playerWins: game.playerWins, watchWins: game.watchWins, draws: game.draws, theme: game.currentTheme)
                    .padding(.bottom, .small)

                VStack(spacing: .medium) {
                    StatRow(label: "Total Games", value: "\(game.totalGames)")
                    StatRow(label: "Win Rate", value: String(format: "%.1f%%", game.winPercentage))
                    StatRow(label: "Current Streak", value: "\(game.currentStreak)")
                    StatRow(label: "Longest Streak", value: "\(game.longestStreak)")
                    StatRow(label: "Avg Moves", value: String(format: "%.1f", game.averageMovesPerGame))
                }

                if !game.gameHistory.isEmpty {
                    Divider()
                        .padding(.vertical, .small)

                    Text("By Algorithm")
                        .font(.headline)
                        .padding(.bottom, .small)

                    ForEach(AIAlgorithm.allCases) { algorithm in
                        let stats = game.algorithmStats(for: algorithm)
                        if stats.wins + stats.losses + stats.draws > 0 {
                            AlgorithmStatRow(algorithm: algorithm, stats: stats)
                        }
                    }

                    Divider()
                        .padding(.vertical, .small)

                    Text("Recent Games")
                        .font(.headline)
                        .padding(.bottom, .small)

                    ForEach(game.gameHistory.prefix(10)) { history in
                        GameHistoryRow(history: history, theme: game.currentTheme)
                    }
                }

                if game.playerWins + game.watchWins + game.draws > 0 {
                    Divider()
                        .padding(.vertical, .small)

                    Button("Reset Scores") {
                        game.resetScores()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
            .padding()
        }
    }
}

struct AlgorithmStatRow: View {
    let algorithm: AIAlgorithm
    let stats: (wins: Int, losses: Int, draws: Int, winRate: Double)

    var body: some View {
        VStack(alignment: .leading, spacing: .small) {
            HStack {
                Text(algorithm.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
                Text(String(format: "%.0f%%", stats.winRate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: .small) {
                Text("W:\(stats.wins)")
                    .font(.caption2)
                    .foregroundColor(.green)
                Text("L:\(stats.losses)")
                    .font(.caption2)
                    .foregroundColor(.red)
                Text("D:\(stats.draws)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, .xxSmall)
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
        }
    }
}

struct GameHistoryRow: View {
    let history: GameHistory
    let theme: GameTheme

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: .xxSmall) {
                Text(history.resultText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(history.result == .playerWin ? theme.playerXColor : (history.result == .watchWin ? theme.playerOColor : .gray))
                Text("\(history.moveCount) moves • \(history.algorithm.rawValue)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(formatDate(history.date))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, .small)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AlgorithmPickerView: View {
    let game: TicTacToeGame

    var body: some View {
        ScrollView {
            VStack(spacing: .large) {
                Text("AI Algorithm")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.bottom, .small)

                ForEach(AIAlgorithm.allCases) { algorithm in
                    AlgorithmButton(
                        algorithm: algorithm,
                        isSelected: game.selectedAlgorithm == algorithm
                    ) {
                        withAnimation {
                            game.selectedAlgorithm = algorithm
                        }
                    }
                }

                if game.selectedAlgorithm == .mctsProbabilistic {
                    Divider()
                        .padding(.vertical, .small)

                    OpponentModelView(beliefs: game.opponentBeliefs)
                }
            }
            .padding()
        }
    }
}

struct AlgorithmButton: View {
    let algorithm: AIAlgorithm
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: .small) {
                Text(algorithm.strategy.name)
                    .font(.headline)
                    .fontWeight(isSelected ? .bold : .semibold)
                    .foregroundColor(isSelected ? .white : .primary)

                Text(algorithm.strategy.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)

                Text(algorithm.strategy.historicalContext)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .italic()
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.medium)
            .background(isSelected ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusMedium))
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadiusMedium)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: .borderWidthThin)
            )
        }
        .buttonStyle(.plain)
    }
}

struct OpponentModelView: View {
    let beliefs: [OpponentStrategy: Double]

    var body: some View {
        VStack(alignment: .leading, spacing: .medium) {
            Text("Opponent Model")
                .font(.headline)
                .fontWeight(.bold)

            Text("AI's belief distribution about your playing style")
                .font(.caption2)
                .foregroundColor(.secondary)

            ForEach(OpponentStrategy.allCases, id: \.self) { strategy in
                VStack(alignment: .leading, spacing: .xxSmall) {
                    HStack {
                        Text(strategy.rawValue)
                            .font(.caption)
                            .foregroundColor(.primary)
                        Spacer()
                        Text(String(format: "%.0f%%", (beliefs[strategy] ?? 0) * 100))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: .xxxSmall)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: .small)

                            RoundedRectangle(cornerRadius: .xxxSmall)
                                .fill(strategyColor(strategy))
                                .frame(width: geometry.size.width * CGFloat(beliefs[strategy] ?? 0), height: .small)
                        }
                    }
                    .frame(height: .small)
                }
            }
        }
        .padding(.medium)
        .background(Color.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusMedium))
    }

    private func strategyColor(_ strategy: OpponentStrategy) -> Color {
        switch strategy {
        case .random:
            return .orange
        case .greedy:
            return .green
        case .defensive:
            return .blue
        case .optimal:
            return .purple
        }
    }
}

struct AboutView: View {
    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    var body: some View {
        VStack(spacing: .large) {
            Spacer()

            VStack(spacing: .medium) {
                Text("Tic-Tac-Toe")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Developed by")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("James Alan Bush")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            Spacer()

            VStack(spacing: .xxSmall) {
                Text("Version \(appVersion)")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Text("Build \(buildNumber)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
