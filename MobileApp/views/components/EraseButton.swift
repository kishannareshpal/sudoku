//
//  DeleteButton.swift
//  sudoku
//
//  Created by Kishan Jadav on 26/01/2025.
//

import SwiftUI
import SpriteKit
import UIKit.UIColor
import UIColorHexSwift

struct DeleteButton: View {
  var gameScene: MobileGameScene
  @ObservedObject var game: Game
  @ObservedObject var puzzle: Puzzle

  private var eraseKeyVibrator = UIImpactFeedbackGenerator(style: .rigid)
  
  init(
    gameScene: MobileGameScene,
    game: Game,
    puzzle: Puzzle
  ) {
    self.gameScene = gameScene
    self.game = game
    self.puzzle = puzzle
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
        HStack {
          Image(systemName: "arrow.uturn.forward")
            .font(.system(size: 14))
            .foregroundStyle(.white)
          
          //          Text("Redo")
          //            .font(.system(size: 12))
          //            .foregroundStyle(.white)
        }
      }
    )
    .disabled(!self.isActiveNumberCellEraseable)
    .buttonStyle(GameControlButtonStyle(disabled: !self.isActiveNumberCellEraseable))
    .onAppear(perform: eraseKeyVibrator.prepare)
  }
}

