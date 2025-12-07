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
        VStack(spacing: 8) {
            Text(game.statusMessage)
                .font(.headline)
                .foregroundColor(game.winner?.color ?? .white)
                .padding(.bottom, 4)

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
                .padding(.top, 8)
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
