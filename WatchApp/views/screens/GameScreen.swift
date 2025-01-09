//
//  GameScreen.swift
//  sudoku
//
//  Created by Kishan Jadav on 17/08/2024.
//

import SwiftUI
import SpriteKit

struct GameScreen: View {
  @State private var cursorState: CursorState = .init(
    mode: .none,
    crownRotationValue: 0.0
  )

  @StateObject private var sessionTracker = GameSessionDurationTracker()
  @State private var gameOver: Bool = false
  @State private var exitedGame: Bool = false

  var difficulty: Difficulty
  var existingGame: SaveGameEntity?
  
  init(difficulty: Difficulty, existingGame: SaveGameEntity? = nil) {
    self.difficulty = difficulty
    self.existingGame = existingGame
  }
  
  var body: some View {
    if exitedGame == false {
      GeometryReader { geometry in
        let gameScene = WatchGameScene(size: geometry.size,
                                       gameOver: $gameOver,
                                       difficulty: difficulty,
                                       existingGame: existingGame,
                                       cursorState: $cursorState)

        SpriteView(
          scene: gameScene,
          preferredFramesPerSecond: 60
        ).focusable()
          .digitalCrownRotation($cursorState.crownRotationValue,
                                from: 0.0,
                                through: 80.0,
                                by: 1.0,
                                sensitivity: .medium,
                                isContinuous: true,
                                isHapticFeedbackEnabled: true)
          .onTapGesture {
            //let newCursorState =
            gameScene.toggleCellUnderCursor(mode: .number)
          }
          .onLongPressGesture {
            // Toggle notes mode ON:
            // - See GameNotesToolbar.swift where the logic for untoggling this lives.
            gameScene.toggleCellUnderCursor(mode: .note)
          }
        
        GameNotesToolbar(gameScene: gameScene, cursorState: $cursorState)
        
        GameMenuToolbar(
          gameScene: gameScene,
          cursorState: $cursorState,
          exitedGame: $exitedGame
        )
        .frame(
          width: geometry.size.width,
          height: geometry.safeAreaInsets.top,
          alignment: .leading
        )
        .ignoresSafeArea(
          edges: [.top]
        )

      }
      .overlay {
        if gameOver {
          GameOverOverlay()
        }
      }
      .onAppear() {
        self.sessionTracker.startedAt = Date()
      }
      .onDisappear() {
        SaveGameEntityDataService
          .incrementSessionDuration(
            durationInSeconds: self.sessionTracker.elapsedDurationInSeconds
          )
      }
    }
  }
}
