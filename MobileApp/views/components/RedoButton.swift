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

struct RedoButton: View {
  private let vibrator = UIImpactFeedbackGenerator(style: .rigid)
  
  var gameScene: MobileGameScene
  
  var body: some View {
    RedoButtonContent(
      puzzle: self.gameScene.game.puzzle,
      gameState: self.gameScene.game.state
    ) {
      self.gameScene.game.redoLastMove()
      self.vibrator.impactOccurred()
    }
  }
}

private struct RedoButtonContent: View {
  @ObservedObject var puzzle: Puzzle
  @ObservedObject var gameState: GameState
  var onPress: () -> Void
  
  var canRedo: Bool {
    self.gameState.isPlaying && self.puzzle.isMoveRedoable
  }
  
  var body: some View {
    Button(
      action: self.onPress,
      label: {
        Image(systemName: "arrow.uturn.forward")
          .font(.system(size: 16))
          .foregroundStyle(.white)
      }
    )
    .disabled(!self.canRedo)
    .buttonStyle(GameControlButtonStyle(isEnabled: self.canRedo))
    .apply { view in
      if #available(iOS 17.0, *) {
        view
          .focusable()
          .focusEffectDisabled(!self.canRedo)
      } else {
        view
      }
    }
  }
}
