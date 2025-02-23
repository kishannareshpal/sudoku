//
//  ControlButton.swift
//  sudoku
//
//  Created by Kishan Jadav on 08/01/2025.
//

import SwiftUI
import SpriteKit
import UIKit.UIColor
import UIColorHexSwift

struct UndoButton: View {
  private let vibrator = UIImpactFeedbackGenerator(style: .rigid)

  var gameScene: MobileGameScene
  
  var body: some View {
    UndoButtonContent(
      puzzle: self.gameScene.game.puzzle,
      gameState: self.gameScene.game.state
    ) {
      self.gameScene.game.undoLastMove()
      self.vibrator.impactOccurred()
    }
  }
}

private struct UndoButtonContent: View {
  @ObservedObject var puzzle: Puzzle
  @ObservedObject var gameState: GameState
  var onPress: () -> Void
  
  var canUndo: Bool {
    self.gameState.isPlaying && self.puzzle.isMoveUndoable
  }
  
  var body: some View {
    Button(
      action: self.onPress,
      label: {
        Image(systemName: "arrow.uturn.backward")
          .font(.system(size: 16))
          .foregroundStyle(.white)
      }
    )
    .disabled(!self.canUndo)
    .buttonStyle(GameControlButtonStyle(isEnabled: self.canUndo))
  }
}
