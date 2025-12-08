# Tic-Tac-Toe for Apple Watch

A feature-rich Tic-Tac-Toe game built natively for watchOS, featuring seven different algorithms, customizable themes, and comprehensive statistics tracking.

## Features

### 🎮 Gameplay
- **Immersive board view** with smooth animations
- **Long-press gesture** to pause mid-game
- **Resume game** functionality
- **Haptic feedback** for moves and game events
- **Winning cell highlighting** with pulsing animation that displays for 3 seconds
- **Automatic menu navigation** after game completion for streamlined experience

### 🤖 Game Theory Algorithms (7 Strategies)

Choose from seven different computer opponents, each with unique playing styles:

1. **Rule-Based** - Classic heuristic approach with win/block/fork logic
2. **Minimax** - Exhaustive game tree search for perfect play
3. **Alpha-Beta Pruning** - Optimized Minimax with branch elimination
4. **Monte Carlo Tree Search (MCTS)** - Simulation-based decision making
5. **MCTS + Opponent Modeling** - Adaptive algorithm that learns your playing style
6. **Q-Learning** - Reinforcement learning with experience replay
7. **Lookup Table** - Pre-computed optimal moves for instant response

### 🎨 Themes (6 Color Schemes)

- **Classic** - Traditional blue and red
- **Ocean** - Cool aquatic tones
- **Sunset** - Warm oranges and pinks
- **Neon** - Vibrant cyberpunk colors
- **Forest** - Natural greens and browns
- **Midnight** - Deep purples and blues

### 📊 Statistics & Analytics

- **Overall statistics**: Total games, win rate, current/longest streak
- **Per-algorithm performance**: Win/loss/draw breakdown for each game theory algorithm
- **Game history**: Recent games with move counts and timestamps
- **Average moves per game** tracking
- **Persistent score tracking** with reset option

### ✨ Additional Features

- **About screen** with developer attribution and version info
- **App icon** with custom tic-tac-toe grid design
- **Pause menu** accessible via long-press during gameplay
- **Theme picker** with live preview
- **Game Theory Algorithm picker** with detailed strategy descriptions
- **Opponent belief visualization** (for MCTS + Model game theory algorithm)

## Requirements

- Apple Watch Series 4 or later
- watchOS 10.0 or later
- Xcode 15.0 or later (for development)

## Installation

### From Source

1. Clone the repository:
   ```bash
   git clone https://github.com/theoknock/Tic-Tac-Toe_WatchOS_2025.git
   ```

2. Open the project in Xcode:
   ```bash
   cd Tic-Tac-Toe_WatchOS_2025
   open Tic-Tac-Toe_WatchOS_2025.xcodeproj
   ```

3. Select your Apple Watch as the destination

4. Build and run (⌘R)

### App Store

*Coming soon - pending App Store submission*

## Technologies Used

- **SwiftUI** - Modern declarative UI framework
- **Observation Framework** - Reactive state management
- **WatchKit** - watchOS-specific APIs and haptics
- **Combine** - Asynchronous event handling
- **Swift** - 100% Swift codebase

## Architecture

The app follows a clean MVVM-like architecture:

- **`TicTacToeGame`** - Observable game state and logic
- **`TicTacToeGameTheoryStrategy`** - Protocol for game theory algorithm implementations
- **`GameTheme`** - Theme configuration and color schemes
- **SwiftUI Views** - Declarative UI components
- **Design Tokens** - Consistent spacing and sizing via CGFloat extensions

## Implementation Highlights

### Opponent Modeling (MCTS + Model)
The most advanced game theory algorithm uses Bayesian inference to build a probabilistic model of the player's strategy:
- Tracks move patterns to classify playing style
- Updates beliefs based on observed moves
- Adapts strategy in real-time
- Visualizes confidence distribution across four opponent archetypes

### Q-Learning with Experience Replay
Implements reinforcement learning with:
- State-action value estimation
- Experience replay buffer
- Epsilon-greedy exploration
- Temporal difference learning

## Development

### Project Structure
```
Tic-Tac-Toe_WatchOS_2025/
├── Tic-Tac-Toe_WatchOS_2025 Watch App/
│   ├── ContentView.swift          # Main UI views
│   ├── TicTacToeGame.swift        # Game logic and state
│   ├── GameTheoryAlgorithms.swift # Protocol and algorithm implementations
│   ├── Theme.swift                # Theme definitions
│   ├── DesignTokens.swift         # Design system
│   └── Assets.xcassets/           # App icon and colors
└── README.md
```

### Building
```bash
xcodebuild -scheme "Tic-Tac-Toe_WatchOS_2025 Watch App" \
  -destination 'platform=watchOS,name=Your Apple Watch' \
  clean build
```

## Screenshots

*Screenshots to be added*

## Version History

### Version 1.0 (Current)
- Initial release
- Seven game theory algorithms with unique playing styles
- Six visual themes with live preview
- Comprehensive statistics and game history
- Game pause/resume functionality
- Opponent modeling visualization with belief distribution
- Clean game-end experience with cell highlighting
- Automatic navigation flow for intuitive gameplay

## Developer

**James Alan Bush**

## License

© 2025 James Alan Bush. All rights reserved.

## Acknowledgments

Built with [Claude Code](https://claude.com/claude-code)

---

*Made with ❤️ for Apple Watch*
