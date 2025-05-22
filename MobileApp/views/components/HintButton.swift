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

struct HintButton: View {
  var gameScene: GameScene
  
  var body: some View {
    HintButtonContent(
      game: self.gameScene.game,
      gameState: self.gameScene.game.state
    )
  }
}

private struct HintButtonContent: View {
  private let vibrator = UIImpactFeedbackGenerator(style: .rigid)
  
  var game: Game
  @ObservedObject var gameState: GameState
  
  var isHintable: Bool {
    return !self.gameState.isGameOver && !self.gameState.isGamePaused
  }
  
  var body: some View {
    Button(
      action: {
        self.game.solveActivatedNumberCell()
        self.vibrator.impactOccurred()
      },
      label: {
        Image(systemName: "lightbulb")
          .font(.system(size: 16))
          .foregroundStyle(.white)
      }
    )
    .disabled(!isHintable)
    .buttonStyle(GameControlButtonStyle(isEnabled: self.isHintable))
    .onAppear(perform: self.vibrator.prepare)
    .apply { view in
      if #available(iOS 17.0, *) {
        view
          .focusable()
          .focusEffectDisabled(!self.isHintable)
      } else {
        view
      }
    }
  }
}

