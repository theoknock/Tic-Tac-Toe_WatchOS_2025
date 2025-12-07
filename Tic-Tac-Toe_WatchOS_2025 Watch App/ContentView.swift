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

    var body: some View {
        NavigationStack {
            VStack(spacing: 6) {
            ScoreView(playerWins: game.playerWins, watchWins: game.watchWins, draws: game.draws)

            Text(game.statusMessage)
                .font(.headline)
                .foregroundColor(game.winner?.color ?? .white)
                .padding(.bottom, 2)
                .scaleEffect(celebrationScale)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: celebrationScale)
                .onChange(of: game.gameOver) { _, isOver in
                    if isOver {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            celebrationScale = 1.2
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                celebrationScale = 1.0
                            }
                        }
                    }
                }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                ForEach(game.cells) { cell in
                    CellView(player: cell.player, isWinningCell: game.isWinningCell(cell.id))
                        .onTapGesture {
                            game.makeMove(at: cell.id)
                        }
                }
            }
            .padding(.horizontal, 8)
            .id(game.gameID)

            if game.gameOver {
                Button("New Game") {
                    celebrationScale = 1.0
                    game.resetGame()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
                .transition(.scale.combined(with: .opacity))
            }

            if game.totalGames > 0 {
                NavigationLink(destination: StatisticsView(game: game)) {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .font(.caption)
                .padding(.top, 2)
            }

            if game.playerWins + game.watchWins + game.draws > 0 {
                Button("Reset Scores") {
                    game.resetScores()
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .transition(.opacity)
            }
            }
            .padding(.vertical, 4)
            .animation(.easeInOut(duration: 0.3), value: game.gameOver)
        }
    }
}

struct ScoreView: View {
    let playerWins: Int
    let watchWins: Int
    let draws: Int

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 2) {
                Text("You")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("\(playerWins)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }

            VStack(spacing: 2) {
                Text("Draws")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("\(draws)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            }

            VStack(spacing: 2) {
                Text("Watch")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("\(watchWins)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

struct CellView: View {
    let player: Player?
    let isWinningCell: Bool
    @State private var appeared = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isWinningCell ? Color.yellow : Color.clear, lineWidth: 3)
                        .opacity(isWinningCell ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isWinningCell)
                )

            if let player = player {
                Text(player.rawValue)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(player.color)
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

struct StatisticsView: View {
    let game: TicTacToeGame

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Statistics")
                    .font(.title3)
                    .fontWeight(.bold)

                VStack(spacing: 8) {
                    StatRow(label: "Total Games", value: "\(game.totalGames)")
                    StatRow(label: "Win Rate", value: String(format: "%.1f%%", game.winPercentage))
                    StatRow(label: "Current Streak", value: "\(game.currentStreak)")
                    StatRow(label: "Longest Streak", value: "\(game.longestStreak)")
                    StatRow(label: "Avg Moves", value: String(format: "%.1f", game.averageMovesPerGame))
                }

                if !game.gameHistory.isEmpty {
                    Divider()
                        .padding(.vertical, 4)

                    Text("Recent Games")
                        .font(.headline)
                        .padding(.bottom, 4)

                    ForEach(game.gameHistory.prefix(10)) { history in
                        GameHistoryRow(history: history)
                    }
                }
            }
            .padding()
        }
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

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(history.resultText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(history.result == .playerWin ? .blue : (history.result == .watchWin ? .red : .gray))
                Text("\(history.moveCount) moves")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(formatDate(history.date))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
}
