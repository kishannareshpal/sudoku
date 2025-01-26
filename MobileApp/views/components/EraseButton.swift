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
  @ObservedObject var game: Game

  private var eraseKeyVibrator = UIImpactFeedbackGenerator(style: .rigid)
  
  init(
    gameScene: MobileGameScene,
    game: Game
  ) {
    self.gameScene = gameScene
    self.game = game
  }

  var isActiveNumberCellEraseable: Bool {
    if self.game.isGamePaused || self.game.isGameOver {
      return false
    }
    
    return self.game.activatedNumberCell?.isEraseable ?? false
  }
  
  private func onEraseKeyPress() {
    eraseKeyVibrator.impactOccurred()
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
    .buttonStyle(GameControlButtonStyle(disabled: !self.isActiveNumberCellEraseable))
    .onAppear(perform: eraseKeyVibrator.prepare)
  }
}

