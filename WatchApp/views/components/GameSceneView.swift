//
//  GameSceneView.swift
//  sudoku
//
//  Created by Kishan Jadav on 13/01/2025.
//

import SwiftUI
import SpriteKit

struct GameSceneView: View {
  var gameScene: WatchGameScene
  @ObservedObject var game: Game
  @ObservedObject var cursorState: CursorState

  var body: some View {
    // I've tried using the alignment properties of
    // either VStack or HStack but that didn't work for aligning the SpriteView
    // to the middle of the watch screen.
    // - For that reason, I'm using these Spacer() to manually align instead.
    VStack {
      Spacer(minLength: 0)
      HStack {
        Spacer(minLength: 0)
        
        SpriteView(scene: self.gameScene, preferredFramesPerSecond: 60)
          .scaledToFit()
          .frame(alignment: .center)
          .focusable()
          .digitalCrownRotation(
            self.$cursorState.crownRotationValue,
            from: 0.0,
            through: 80.0,
            by: 1.0,
            sensitivity: .medium,
            isContinuous: true,
            isHapticFeedbackEnabled: true
          )
          .onTapGesture {
            self.gameScene.toggleCellUnderCursor(mode: .number)
          }
          .onLongPressGesture {
            // Toggle notes mode ON:
            // - See GameNotesToolbar.swift where the logic for untoggling is defined.
            self.gameScene.toggleCellUnderCursor(mode: .note)
          }
          .onDisappear() {
            self.gameScene.game.saveCurrentGameDuration()
          }
        
//        SolveButton(gameScene: self.gameScene)
        
        Spacer(minLength: 0)
      }
      Spacer(minLength: 0)
    }
    .overlay {
      GameDurationTracker(
        gameState: self.gameScene.game.state
      )
    }
  }
}
