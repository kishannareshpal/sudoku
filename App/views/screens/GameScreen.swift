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
    activationMode: .none,
    location: .zero,
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
        let gameScene = GameScene(size: geometry.size,
                                  crownRotationValue: $cursorState.crownRotationValue,
                                  gameOver: $gameOver,
                                  difficulty: difficulty,
                                  existingGame: existingGame)

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
            let newCursorState = gameScene.toggleCellUnderCursor(mode: .number)

            withAnimation(.smooth) {
              self.cursorState = newCursorState
            }
          }
          .onLongPressGesture {
            // Toggle notes mode ON:
            // - See GameNotesToolbar.swift where the logic for untoggling this lives.
            let newCursorState = gameScene.toggleCellUnderCursor(mode: .note)

            withAnimation(.smooth) {
              self.cursorState = newCursorState
            }
          }
        
        GameNotesToolbar(
          gameScene: gameScene,
          cursorState: $cursorState
        )
        
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
