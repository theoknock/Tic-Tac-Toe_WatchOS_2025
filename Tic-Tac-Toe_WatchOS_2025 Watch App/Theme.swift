//
//  Theme.swift
//  Tic-Tac-Toe_WatchOS_2025 Watch App
//
//  Created by Xcode Developer on 12/7/25.
//

import SwiftUI

struct GameTheme: Identifiable, Equatable {
    let id: String
    let name: String
    let playerXColor: Color
    let playerOColor: Color
    let boardBackground: Color
    let cellBackground: Color
    let winningLineColor: Color

    static let classic = GameTheme(
        id: "classic",
        name: "Classic",
        playerXColor: .blue,
        playerOColor: .red,
        boardBackground: Color(white: 0.15),
        cellBackground: Color.gray.opacity(0.3),
        winningLineColor: .yellow
    )

    static let ocean = GameTheme(
        id: "ocean",
        name: "Ocean",
        playerXColor: Color(red: 0.2, green: 0.6, blue: 0.9),
        playerOColor: Color(red: 0.0, green: 0.8, blue: 0.8),
        boardBackground: Color(red: 0.1, green: 0.2, blue: 0.3),
        cellBackground: Color(red: 0.2, green: 0.3, blue: 0.4).opacity(0.5),
        winningLineColor: Color(red: 0.5, green: 0.9, blue: 1.0)
    )

    static let sunset = GameTheme(
        id: "sunset",
        name: "Sunset",
        playerXColor: Color(red: 1.0, green: 0.5, blue: 0.3),
        playerOColor: Color(red: 0.9, green: 0.3, blue: 0.5),
        boardBackground: Color(red: 0.2, green: 0.1, blue: 0.2),
        cellBackground: Color(red: 0.3, green: 0.2, blue: 0.3).opacity(0.5),
        winningLineColor: Color(red: 1.0, green: 0.8, blue: 0.3)
    )

    static let neon = GameTheme(
        id: "neon",
        name: "Neon",
        playerXColor: Color(red: 0.0, green: 1.0, blue: 0.5),
        playerOColor: Color(red: 1.0, green: 0.0, blue: 0.8),
        boardBackground: Color.black,
        cellBackground: Color(white: 0.1).opacity(0.5),
        winningLineColor: Color(red: 0.5, green: 1.0, blue: 1.0)
    )

    static let forest = GameTheme(
        id: "forest",
        name: "Forest",
        playerXColor: Color(red: 0.3, green: 0.7, blue: 0.3),
        playerOColor: Color(red: 0.6, green: 0.4, blue: 0.2),
        boardBackground: Color(red: 0.1, green: 0.2, blue: 0.1),
        cellBackground: Color(red: 0.2, green: 0.3, blue: 0.2).opacity(0.5),
        winningLineColor: Color(red: 0.8, green: 0.9, blue: 0.3)
    )

    static let midnight = GameTheme(
        id: "midnight",
        name: "Midnight",
        playerXColor: Color(red: 0.5, green: 0.5, blue: 1.0),
        playerOColor: Color(red: 0.8, green: 0.4, blue: 1.0),
        boardBackground: Color(red: 0.05, green: 0.05, blue: 0.15),
        cellBackground: Color(red: 0.1, green: 0.1, blue: 0.2).opacity(0.5),
        winningLineColor: Color(red: 1.0, green: 0.8, blue: 1.0)
    )

    static let allThemes: [GameTheme] = [
        .classic, .ocean, .sunset, .neon, .forest, .midnight
    ]
}
