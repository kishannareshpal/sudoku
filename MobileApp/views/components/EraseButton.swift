//
//  EraseButton.swift
//  sudoku
//
//  Created by Kishan Jadav on 26/01/2025.
//

import SwiftUI
import SpriteKit
import UIKit.UIColor
import UIColorHexSwift

struct EraseButton: View {
  var gameScene: MobileGameScene
    
  var body: some View {
    EraseButtonContent(
      gameScene: self.gameScene,
      activeCursorState: self.gameScene.game.activeCursorState,
      gameState: self.gameScene.game.state,
      puzzle: self.gameScene.game.puzzle
    )
  }
}

private struct EraseButtonContent: View {
  private let eraseKeyVibrator = UIImpactFeedbackGenerator(style: .rigid)
  
  var gameScene: MobileGameScene
  @ObservedObject var activeCursorState: ActiveCursorState
  @ObservedObject var gameState: GameState
  
  // This is currently unused, however you should keep this observation,
  // because we need to detect changes to the puzzle values (note / number)
  // to enable / disable this button accordingly.
  @ObservedObject var puzzle: Puzzle

  
  var isActiveNumberCellEraseable: Bool {
    if self.gameState.isGamePaused || self.gameState.isGameOver {
      return false
    }
    
    return self.activeCursorState.numberCell?.isEraseable ?? false
  }
  
  private func onEraseKeyPress() {
    self.eraseKeyVibrator.impactOccurred()
    self.gameScene.clearActivatedNumberCellValueAndNotes()
  }
  
  var body: some View {
    Button(
      action: self.onEraseKeyPress,
      label: {
        Image(systemName: "delete.left.fill")
          .font(.system(size: 16))
          .foregroundStyle(.white)
      }
    )
    .disabled(!self.isActiveNumberCellEraseable)
    .buttonStyle(GameControlButtonStyle(isEnabled: self.isActiveNumberCellEraseable))
    .onAppear(perform: self.eraseKeyVibrator.prepare)
    .apply { view in
      if #available(iOS 17.0, *) {
        view
          .focusable()
          .focusEffectDisabled(!self.isActiveNumberCellEraseable)
      } else {
        view
      }
    }
  }
}

