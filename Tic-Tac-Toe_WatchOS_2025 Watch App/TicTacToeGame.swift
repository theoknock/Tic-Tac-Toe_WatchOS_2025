//
//  TicTacToeGame.swift
//  Tic-Tac-Toe_WatchOS_2025 Watch App
//
//  Created by Xcode Developer on 12/7/25.
//

import Foundation
import SwiftUI
import Observation
import WatchKit

enum Player: String {
    case x = "X"
    case o = "O"

    func color(for theme: GameTheme) -> Color {
        switch self {
        case .x: return theme.playerXColor
        case .o: return theme.playerOColor
        }
    }

    var next: Player {
        self == .x ? .o : .x
    }
}

enum AIAlgorithm: String, CaseIterable, Identifiable {
    case ruleBased = "Rule-Based"
    case minimax = "Minimax"
    case alphaBeta = "Alpha-Beta"
    case mcts = "MCTS"
    case mctsProbabilistic = "MCTS + Model"
    case qLearning = "Q-Learning"
    case lookupTable = "Lookup Table"

    var id: String { rawValue }

    var strategy: TicTacToeAIStrategy {
        switch self {
        case .ruleBased:
            return RuleBasedStrategy()
        case .minimax:
            return MinimaxStrategy()
        case .alphaBeta:
            return AlphaBetaStrategy()
        case .mcts:
            return MCTSStrategy()
        case .mctsProbabilistic:
            return MCTSProbabilisticStrategy()
        case .qLearning:
            return QLearningStrategy()
        case .lookupTable:
            return LookupTableStrategy()
        }
    }
}

struct GameCell: Identifiable {
    let id: Int
    var player: Player?
}

enum GameResult {
    case playerWin
    case watchWin
    case draw
}

struct GameHistory: Identifiable {
    let id = UUID()
    let date: Date
    let result: GameResult
    let moveCount: Int
    let algorithm: AIAlgorithm

    var resultText: String {
        switch result {
        case .playerWin: return "You Won"
        case .watchWin: return "Watch Won"
        case .draw: return "Draw"
        }
    }
}

@Observable class TicTacToeGame: NSObject {
    var cells: [GameCell] = []
    var currentPlayer: Player = .x
    var gameOver: Bool = false
    var winner: Player?
    var isDraw: Bool = false
    var winningPattern: [Int] = []
    var gameID: UUID = UUID()
    var moveCount: Int = 0

    var playerWins: Int = 0
    var watchWins: Int = 0
    var draws: Int = 0

    var gameHistory: [GameHistory] = []

    var currentTheme: GameTheme = .classic
    var selectedAlgorithm: AIAlgorithm = .ruleBased

    private var mctsProbabilisticStrategy: MCTSProbabilisticStrategy?

    var opponentBeliefs: [OpponentStrategy: Double] {
        mctsProbabilisticStrategy?.opponentBeliefs ?? [
            .random: 0.25,
            .greedy: 0.25,
            .defensive: 0.25,
            .optimal: 0.25
        ]
    }

    override init() {
        super.init()
        resetGame()
    }

    func resetGame() {
        if gameOver {
            updateScores()
        }

        cells = (0..<9).map { GameCell(id: $0, player: nil) }
        currentPlayer = .x
        gameOver = false
        winner = nil
        isDraw = false
        winningPattern = []
        gameID = UUID()
        moveCount = 0
    }

    func resetScores() {
        playerWins = 0
        watchWins = 0
        draws = 0
        gameHistory = []
    }

    private func updateScores() {
        let result: GameResult
        if let winner = winner {
            if winner == .x {
                playerWins += 1
                result = .playerWin
            } else {
                watchWins += 1
                result = .watchWin
            }
        } else if isDraw {
            draws += 1
            result = .draw
        } else {
            return
        }

        let history = GameHistory(date: Date(), result: result, moveCount: moveCount, algorithm: selectedAlgorithm)
        gameHistory.insert(history, at: 0)
    }

    func makeMove(at index: Int) {
        guard !gameOver, cells[index].player == nil, currentPlayer == .x else { return }

        cells[index].player = .x
        moveCount += 1
        playHaptic(.click)

        if selectedAlgorithm == .mctsProbabilistic {
            if mctsProbabilisticStrategy == nil {
                mctsProbabilisticStrategy = MCTSProbabilisticStrategy()
            }
            mctsProbabilisticStrategy?.updateOpponentModel(humanMove: index, cells: cells)
        }

        if checkWin(for: .x) {
            winner = .x
            gameOver = true
            playHaptic(.success)
        } else if cells.allSatisfy({ $0.player != nil }) {
            isDraw = true
            gameOver = true
            playHaptic(.notification)
        } else {
            currentPlayer = .o
            makeAIMove()
        }
    }

    private func makeAIMove() {
        guard !gameOver else { return }

        Task { @MainActor in
            let delay: UInt64 = selectedAlgorithm == .mctsProbabilistic ? 300_000_000 : 500_000_000
            try? await Task.sleep(nanoseconds: delay)

            let strategy: TicTacToeAIStrategy
            if selectedAlgorithm == .mctsProbabilistic {
                if mctsProbabilisticStrategy == nil {
                    mctsProbabilisticStrategy = MCTSProbabilisticStrategy()
                }
                strategy = mctsProbabilisticStrategy!
            } else {
                strategy = selectedAlgorithm.strategy
            }

            guard let move = strategy.findMove(cells: cells, player: .o) else { return }

            cells[move].player = .o
            moveCount += 1
            playHaptic(.click)

            if checkWin(for: .o) {
                winner = .o
                gameOver = true
                playHaptic(.failure)
            } else if cells.allSatisfy({ $0.player != nil }) {
                isDraw = true
                gameOver = true
                playHaptic(.notification)
            } else {
                currentPlayer = .x
            }
        }
    }

    private func checkWin(for player: Player) -> Bool {
        let winPatterns: [[Int]] = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
            [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
            [0, 4, 8], [2, 4, 6]              // Diagonals
        ]

        for pattern in winPatterns {
            if pattern.allSatisfy({ cells[$0].player == player }) {
                winningPattern = pattern
                return true
            }
        }
        return false
    }

    func isWinningCell(_ index: Int) -> Bool {
        return winningPattern.contains(index)
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

    private func playHaptic(_ type: WKHapticType) {
        WKInterfaceDevice.current().play(type)
    }

    // Statistics computed properties
    var totalGames: Int {
        playerWins + watchWins + draws
    }

    var winPercentage: Double {
        guard totalGames > 0 else { return 0 }
        return Double(playerWins) / Double(totalGames) * 100
    }

    var currentStreak: Int {
        var streak = 0
        for game in gameHistory {
            if game.result == .playerWin {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }

    var longestStreak: Int {
        var longest = 0
        var current = 0
        for game in gameHistory.reversed() {
            if game.result == .playerWin {
                current += 1
                longest = max(longest, current)
            } else {
                current = 0
            }
        }
        return longest
    }

    var averageMovesPerGame: Double {
        guard !gameHistory.isEmpty else { return 0 }
        let totalMoves = gameHistory.reduce(0) { $0 + $1.moveCount }
        return Double(totalMoves) / Double(gameHistory.count)
    }

    func algorithmStats(for algorithm: AIAlgorithm) -> (wins: Int, losses: Int, draws: Int, winRate: Double) {
        let games = gameHistory.filter { $0.algorithm == algorithm }
        let wins = games.filter { $0.result == .playerWin }.count
        let losses = games.filter { $0.result == .watchWin }.count
        let draws = games.filter { $0.result == .draw }.count
        let total = games.count
        let winRate = total > 0 ? Double(wins) / Double(total) * 100 : 0
        return (wins, losses, draws, winRate)
    }
}
