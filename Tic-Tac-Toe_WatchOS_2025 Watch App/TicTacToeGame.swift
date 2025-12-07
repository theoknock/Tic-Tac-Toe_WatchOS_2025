//
//  TicTacToeGame.swift
//  Tic-Tac-Toe_WatchOS_2025 Watch App
//
//  Created by Xcode Developer on 12/7/25.
//

import Foundation
import SwiftUI
import Observation

enum Player: String {
    case x = "X"
    case o = "O"

    var color: Color {
        switch self {
        case .x: return .blue
        case .o: return .red
        }
    }

    var next: Player {
        self == .x ? .o : .x
    }
}

struct GameCell: Identifiable {
    let id: Int
    var player: Player?
}

@Observable class TicTacToeGame: NSObject {
    var cells: [GameCell] = []
    var currentPlayer: Player = .x
    var gameOver: Bool = false
    var winner: Player?
    var isDraw: Bool = false

    override init() {
        super.init()
        resetGame()
    }

    func resetGame() {
        cells = (0..<9).map { GameCell(id: $0, player: nil) }
        currentPlayer = .x
        gameOver = false
        winner = nil
        isDraw = false
    }

    func makeMove(at index: Int) {
        guard !gameOver, cells[index].player == nil, currentPlayer == .x else { return }

        cells[index].player = .x

        if checkWin(for: .x) {
            winner = .x
            gameOver = true
        } else if cells.allSatisfy({ $0.player != nil }) {
            isDraw = true
            gameOver = true
        } else {
            currentPlayer = .o
            makeAIMove()
        }
    }

    private func makeAIMove() {
        guard !gameOver else { return }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000)

            guard let move = findBestMove() else { return }

            cells[move].player = .o

            if checkWin(for: .o) {
                winner = .o
                gameOver = true
            } else if cells.allSatisfy({ $0.player != nil }) {
                isDraw = true
                gameOver = true
            } else {
                currentPlayer = .x
            }
        }
    }

    private func findBestMove() -> Int? {
        if let winMove = findWinningMove(for: .o) {
            return winMove
        }

        if let blockMove = findWinningMove(for: .x) {
            return blockMove
        }

        if cells[4].player == nil {
            return 4
        }

        let corners = [0, 2, 6, 8]
        if let corner = corners.shuffled().first(where: { cells[$0].player == nil }) {
            return corner
        }

        return cells.indices.filter { cells[$0].player == nil }.randomElement()
    }

    private func findWinningMove(for player: Player) -> Int? {
        let winPatterns: [[Int]] = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8],
            [0, 3, 6], [1, 4, 7], [2, 5, 8],
            [0, 4, 8], [2, 4, 6]
        ]

        for pattern in winPatterns {
            let playerCells = pattern.filter { cells[$0].player == player }
            let emptyCells = pattern.filter { cells[$0].player == nil }

            if playerCells.count == 2 && emptyCells.count == 1 {
                return emptyCells[0]
            }
        }

        return nil
    }

    private func checkWin(for player: Player) -> Bool {
        let winPatterns: [[Int]] = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
            [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
            [0, 4, 8], [2, 4, 6]              // Diagonals
        ]

        return winPatterns.contains { pattern in
            pattern.allSatisfy { cells[$0].player == player }
        }
    }

    var statusMessage: String {
        if let winner = winner {
            return winner == .x ? "You Win!" : "Watch Wins!"
        } else if isDraw {
            return "Draw!"
        } else {
            return currentPlayer == .x ? "Your Turn" : "Watch's Turn"
        }
    }
}
