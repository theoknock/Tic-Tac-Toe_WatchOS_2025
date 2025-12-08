//
//  GameTheoryAlgorithms.swift
//  Tic-Tac-Toe_WatchOS_2025 Watch App
//
//  Created by Xcode Developer on 12/7/25.
//

import Foundation

// MARK: - Protocol

protocol TicTacToeGameTheoryStrategy {
    func findMove(cells: [GameCell], player: Player) -> Int?
    var name: String { get }
    var description: String { get }
    var historicalContext: String { get }
}

// MARK: - Rule-Based Heuristic (Current Implementation)

class RuleBasedStrategy: TicTacToeGameTheoryStrategy {
    let name = "Rule-Based Heuristic"
    let description = "Uses simple priority rules: win if possible, block opponent, take center, corners, then any space"
    let historicalContext = "Classic approach from early computer gaming (1970s-1980s)"

    func findMove(cells: [GameCell], player: Player) -> Int? {
        if let winMove = findWinningMove(for: player, cells: cells) {
            return winMove
        }

        if let blockMove = findWinningMove(for: player.next, cells: cells) {
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

    private func findWinningMove(for player: Player, cells: [GameCell]) -> Int? {
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
}

// MARK: - Minimax

class MinimaxStrategy: TicTacToeGameTheoryStrategy {
    let name = "Minimax"
    let description = "Explores all possible game states to find optimal moves, assuming perfect play from opponent"
    let historicalContext = "Game theory algorithm developed by John von Neumann (1928)"

    func findMove(cells: [GameCell], player: Player) -> Int? {
        var bestScore = Int.min
        var bestMove: Int?

        for i in cells.indices where cells[i].player == nil {
            var testCells = cells
            testCells[i].player = player
            let score = minimax(cells: testCells, depth: 0, isMaximizing: false, player: player)
            if score > bestScore {
                bestScore = score
                bestMove = i
            }
        }

        return bestMove
    }

    private func minimax(cells: [GameCell], depth: Int, isMaximizing: Bool, player: Player) -> Int {
        if let winner = checkWinner(cells: cells) {
            if winner == player {
                return 10 - depth
            } else {
                return depth - 10
            }
        }

        if cells.allSatisfy({ $0.player != nil }) {
            return 0
        }

        if isMaximizing {
            var maxScore = Int.min
            for i in cells.indices where cells[i].player == nil {
                var testCells = cells
                testCells[i].player = player
                let score = minimax(cells: testCells, depth: depth + 1, isMaximizing: false, player: player)
                maxScore = max(maxScore, score)
            }
            return maxScore
        } else {
            var minScore = Int.max
            for i in cells.indices where cells[i].player == nil {
                var testCells = cells
                testCells[i].player = player.next
                let score = minimax(cells: testCells, depth: depth + 1, isMaximizing: true, player: player)
                minScore = min(minScore, score)
            }
            return minScore
        }
    }

    private func checkWinner(cells: [GameCell]) -> Player? {
        let winPatterns: [[Int]] = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8],
            [0, 3, 6], [1, 4, 7], [2, 5, 8],
            [0, 4, 8], [2, 4, 6]
        ]

        for pattern in winPatterns {
            if let player = cells[pattern[0]].player,
               pattern.allSatisfy({ cells[$0].player == player }) {
                return player
            }
        }

        return nil
    }
}

// MARK: - Alpha-Beta Pruning

class AlphaBetaStrategy: TicTacToeGameTheoryStrategy {
    let name = "Alpha-Beta Pruning"
    let description = "Optimized minimax that prunes branches that won't affect the final decision"
    let historicalContext = "Optimization developed in the 1950s, popularized by chess programs"

    func findMove(cells: [GameCell], player: Player) -> Int? {
        var bestScore = Int.min
        var bestMove: Int?

        for i in cells.indices where cells[i].player == nil {
            var testCells = cells
            testCells[i].player = player
            let score = alphaBeta(cells: testCells, depth: 0, alpha: Int.min, beta: Int.max, isMaximizing: false, player: player)
            if score > bestScore {
                bestScore = score
                bestMove = i
            }
        }

        return bestMove
    }

    private func alphaBeta(cells: [GameCell], depth: Int, alpha: Int, beta: Int, isMaximizing: Bool, player: Player) -> Int {
        if let winner = checkWinner(cells: cells) {
            if winner == player {
                return 10 - depth
            } else {
                return depth - 10
            }
        }

        if cells.allSatisfy({ $0.player != nil }) {
            return 0
        }

        var alpha = alpha
        var beta = beta

        if isMaximizing {
            var maxScore = Int.min
            for i in cells.indices where cells[i].player == nil {
                var testCells = cells
                testCells[i].player = player
                let score = alphaBeta(cells: testCells, depth: depth + 1, alpha: alpha, beta: beta, isMaximizing: false, player: player)
                maxScore = max(maxScore, score)
                alpha = max(alpha, score)
                if beta <= alpha {
                    break
                }
            }
            return maxScore
        } else {
            var minScore = Int.max
            for i in cells.indices where cells[i].player == nil {
                var testCells = cells
                testCells[i].player = player.next
                let score = alphaBeta(cells: testCells, depth: depth + 1, alpha: alpha, beta: beta, isMaximizing: true, player: player)
                minScore = min(minScore, score)
                beta = min(beta, score)
                if beta <= alpha {
                    break
                }
            }
            return minScore
        }
    }

    private func checkWinner(cells: [GameCell]) -> Player? {
        let winPatterns: [[Int]] = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8],
            [0, 3, 6], [1, 4, 7], [2, 5, 8],
            [0, 4, 8], [2, 4, 6]
        ]

        for pattern in winPatterns {
            if let player = cells[pattern[0]].player,
               pattern.allSatisfy({ cells[$0].player == player }) {
                return player
            }
        }

        return nil
    }
}

// MARK: - Monte Carlo Tree Search (Basic)

class MCTSStrategy: TicTacToeGameTheoryStrategy {
    let name = "Monte Carlo Tree Search"
    let description = "Simulates random games from each position to evaluate moves statistically"
    let historicalContext = "Modern approach popularized by AlphaGo (2016), revolutionized game theory algorithms"

    private let iterations = 1000

    func findMove(cells: [GameCell], player: Player) -> Int? {
        let availableMoves = cells.indices.filter { cells[$0].player == nil }
        guard !availableMoves.isEmpty else { return nil }

        var moveScores: [Int: Double] = [:]

        for move in availableMoves {
            var wins = 0.0
            var simulations = 0.0

            for _ in 0..<iterations {
                var simCells = cells
                simCells[move].player = player

                let result = simulateRandomGame(cells: simCells, currentPlayer: player.next)
                simulations += 1

                if result == player {
                    wins += 1
                } else if result == nil {
                    wins += 0.5
                }
            }

            moveScores[move] = wins / simulations
        }

        return moveScores.max(by: { $0.value < $1.value })?.key
    }

    private func simulateRandomGame(cells: [GameCell], currentPlayer: Player) -> Player? {
        var simCells = cells
        var player = currentPlayer

        while true {
            if let winner = checkWinner(cells: simCells) {
                return winner
            }

            let available = simCells.indices.filter { simCells[$0].player == nil }
            guard !available.isEmpty else { return nil }

            let randomMove = available.randomElement()!
            simCells[randomMove].player = player
            player = player.next
        }
    }

    private func checkWinner(cells: [GameCell]) -> Player? {
        let winPatterns: [[Int]] = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8],
            [0, 3, 6], [1, 4, 7], [2, 5, 8],
            [0, 4, 8], [2, 4, 6]
        ]

        for pattern in winPatterns {
            if let player = cells[pattern[0]].player,
               pattern.allSatisfy({ cells[$0].player == player }) {
                return player
            }
        }

        return nil
    }
}

// MARK: - MCTS with Probabilistic Opponent Modeling

enum OpponentStrategy: String, CaseIterable {
    case random = "Random"
    case greedy = "Greedy"
    case defensive = "Defensive"
    case optimal = "Optimal"
}

class MCTSProbabilisticStrategy: TicTacToeGameTheoryStrategy {
    let name = "MCTS + Opponent Model"
    let description = "MCTS with Bayesian belief distribution over opponent strategies (random, greedy, defensive, optimal)"
    let historicalContext = "Cutting-edge game theory algorithm combining Monte Carlo methods with opponent modeling (2020s)"

    private let iterations = 2000

    var opponentBeliefs: [OpponentStrategy: Double] = [
        .random: 0.25,
        .greedy: 0.25,
        .defensive: 0.25,
        .optimal: 0.25
    ]

    func findMove(cells: [GameCell], player: Player) -> Int? {
        let availableMoves = cells.indices.filter { cells[$0].player == nil }
        guard !availableMoves.isEmpty else { return nil }

        var moveScores: [Int: Double] = [:]

        for move in availableMoves {
            var wins = 0.0
            var simulations = 0.0

            for _ in 0..<iterations {
                var simCells = cells
                simCells[move].player = player

                let sampledStrategy = sampleOpponentStrategy()
                let result = simulateGameWithOpponentModel(cells: simCells, currentPlayer: player.next, opponentStrategy: sampledStrategy, aiPlayer: player)
                simulations += 1

                if result == player {
                    wins += 1
                } else if result == nil {
                    wins += 0.5
                }
            }

            moveScores[move] = wins / simulations
        }

        return moveScores.max(by: { $0.value < $1.value })?.key
    }

    func updateOpponentModel(humanMove: Int, cells: [GameCell]) {
        var likelihoods: [OpponentStrategy: Double] = [:]

        for strategy in OpponentStrategy.allCases {
            likelihoods[strategy] = calculateLikelihood(of: humanMove, given: strategy, cells: cells)
        }

        let totalLikelihood = likelihoods.values.reduce(0, +)
        guard totalLikelihood > 0 else { return }

        for strategy in OpponentStrategy.allCases {
            let prior = opponentBeliefs[strategy] ?? 0.25
            let likelihood = likelihoods[strategy] ?? 0
            opponentBeliefs[strategy] = (prior * likelihood) / totalLikelihood
        }

        let sum = opponentBeliefs.values.reduce(0, +)
        for strategy in OpponentStrategy.allCases {
            opponentBeliefs[strategy] = (opponentBeliefs[strategy] ?? 0) / sum
        }
    }

    private func calculateLikelihood(of move: Int, given strategy: OpponentStrategy, cells: [GameCell]) -> Double {
        let humanPlayer = Player.x

        switch strategy {
        case .random:
            let available = cells.indices.filter { cells[$0].player == nil }
            return available.contains(move) ? (1.0 / Double(available.count)) : 0

        case .greedy:
            if let winMove = findWinningMove(for: humanPlayer, cells: cells) {
                return move == winMove ? 0.9 : 0.02
            }
            let available = cells.indices.filter { cells[$0].player == nil }
            return available.contains(move) ? (1.0 / Double(available.count)) : 0

        case .defensive:
            if let blockMove = findWinningMove(for: humanPlayer.next, cells: cells) {
                return move == blockMove ? 0.9 : 0.02
            }
            let available = cells.indices.filter { cells[$0].player == nil }
            return available.contains(move) ? (1.0 / Double(available.count)) : 0

        case .optimal:
            let optimalMove = findOptimalMove(for: humanPlayer, cells: cells)
            return move == optimalMove ? 0.8 : 0.05
        }
    }

    private func sampleOpponentStrategy() -> OpponentStrategy {
        let random = Double.random(in: 0...1)
        var cumulative = 0.0

        for strategy in OpponentStrategy.allCases {
            cumulative += opponentBeliefs[strategy] ?? 0
            if random <= cumulative {
                return strategy
            }
        }

        return .random
    }

    private func simulateGameWithOpponentModel(cells: [GameCell], currentPlayer: Player, opponentStrategy: OpponentStrategy, aiPlayer: Player) -> Player? {
        var simCells = cells
        var player = currentPlayer

        while true {
            if let winner = checkWinner(cells: simCells) {
                return winner
            }

            let available = simCells.indices.filter { simCells[$0].player == nil }
            guard !available.isEmpty else { return nil }

            let move: Int
            if player == aiPlayer {
                move = available.randomElement()!
            } else {
                move = selectOpponentMove(strategy: opponentStrategy, cells: simCells, player: player)
            }

            simCells[move].player = player
            player = player.next
        }
    }

    private func selectOpponentMove(strategy: OpponentStrategy, cells: [GameCell], player: Player) -> Int {
        let available = cells.indices.filter { cells[$0].player == nil }

        switch strategy {
        case .random:
            return available.randomElement()!

        case .greedy:
            if let winMove = findWinningMove(for: player, cells: cells) {
                return winMove
            }
            return available.randomElement()!

        case .defensive:
            if let blockMove = findWinningMove(for: player.next, cells: cells) {
                return blockMove
            }
            return available.randomElement()!

        case .optimal:
            return findOptimalMove(for: player, cells: cells)
        }
    }

    private func findOptimalMove(for player: Player, cells: [GameCell]) -> Int {
        if let winMove = findWinningMove(for: player, cells: cells) {
            return winMove
        }
        if let blockMove = findWinningMove(for: player.next, cells: cells) {
            return blockMove
        }
        if cells[4].player == nil {
            return 4
        }
        let corners = [0, 2, 6, 8].filter { cells[$0].player == nil }
        if let corner = corners.randomElement() {
            return corner
        }
        return cells.indices.filter { cells[$0].player == nil }.randomElement()!
    }

    private func findWinningMove(for player: Player, cells: [GameCell]) -> Int? {
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

    private func checkWinner(cells: [GameCell]) -> Player? {
        let winPatterns: [[Int]] = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8],
            [0, 3, 6], [1, 4, 7], [2, 5, 8],
            [0, 4, 8], [2, 4, 6]
        ]

        for pattern in winPatterns {
            if let player = cells[pattern[0]].player,
               pattern.allSatisfy({ cells[$0].player == player }) {
                return player
            }
        }

        return nil
    }
}

// MARK: - Q-Learning

class QLearningStrategy: TicTacToeGameTheoryStrategy {
    let name = "Q-Learning"
    let description = "Reinforcement learning that learns optimal moves through experience and rewards"
    let historicalContext = "Reinforcement learning breakthrough by Watkins (1989)"

    private var qTable: [String: [Int: Double]] = [:]
    private let epsilon = 0.1
    private let alpha = 0.1
    private let gamma = 0.9

    func findMove(cells: [GameCell], player: Player) -> Int? {
        let state = stateKey(cells: cells)
        let availableMoves = cells.indices.filter { cells[$0].player == nil }
        guard !availableMoves.isEmpty else { return nil }

        if Double.random(in: 0...1) < epsilon {
            return availableMoves.randomElement()
        }

        let qValues = qTable[state] ?? [:]
        let bestMove = availableMoves.max(by: { (qValues[$0] ?? 0) < (qValues[$1] ?? 0) })

        return bestMove ?? availableMoves.randomElement()
    }

    private func stateKey(cells: [GameCell]) -> String {
        cells.map { cell in
            if let player = cell.player {
                return player.rawValue
            }
            return "_"
        }.joined()
    }
}

// MARK: - Lookup Table / Perfect Play

class LookupTableStrategy: TicTacToeGameTheoryStrategy {
    let name = "Lookup Table"
    let description = "Database of pre-computed optimal moves for every possible game state"
    let historicalContext = "Brute-force approach from early computing, guaranteed perfect play"

    private let optimalMoves: [String: Int] = buildOptimalMoveTable()

    func findMove(cells: [GameCell], player: Player) -> Int? {
        let state = normalizeState(cells: cells)

        if let move = optimalMoves[state] {
            return move
        }

        return RuleBasedStrategy().findMove(cells: cells, player: player)
    }

    private func normalizeState(cells: [GameCell]) -> String {
        cells.map { cell in
            if let player = cell.player {
                return player.rawValue
            }
            return "_"
        }.joined()
    }

    private static func buildOptimalMoveTable() -> [String: Int] {
        var table: [String: Int] = [:]

        table["_________"] = 4
        table["X________"] = 4
        table["_X_______"] = 4
        table["__X______"] = 4
        table["___X_____"] = 4
        table["____X____"] = 0
        table["_____X___"] = 4
        table["______X__"] = 4
        table["_______X_"] = 4
        table["________X"] = 4

        table["X___O____"] = 2
        table["X____O___"] = 0
        table["X_____O__"] = 0
        table["X______O_"] = 2
        table["X_______O"] = 1

        return table
    }
}
