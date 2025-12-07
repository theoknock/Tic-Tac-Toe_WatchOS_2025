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

    var body: some View {
        VStack(spacing: 6) {
            ScoreView(playerWins: game.playerWins, watchWins: game.watchWins, draws: game.draws)

            Text(game.statusMessage)
                .font(.headline)
                .foregroundColor(game.winner?.color ?? .white)
                .padding(.bottom, 2)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                ForEach(game.cells) { cell in
                    CellView(player: cell.player)
                        .onTapGesture {
                            game.makeMove(at: cell.id)
                        }
                }
            }
            .padding(.horizontal, 8)

            if game.gameOver {
                Button("New Game") {
                    game.resetGame()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
            }

            if game.playerWins + game.watchWins + game.draws > 0 {
                Button("Reset Scores") {
                    game.resetScores()
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
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

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(1, contentMode: .fit)

            if let player = player {
                Text(player.rawValue)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(player.color)
            }
        }
    }
}

#Preview {
    ContentView()
}
