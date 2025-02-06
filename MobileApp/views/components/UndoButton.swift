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
  @ObservedObject var game: Game

  private let vibrator = UIImpactFeedbackGenerator(style: .rigid)
  
  var body: some View {
    Button(
      action: {
        self.game.undoMove()
        self.vibrator.impactOccurred()
      },
      label: {
        Image(systemName: "arrow.uturn.backward")
          .font(.system(size: 16))
          .foregroundStyle(.white)
      }
    )
    .disabled(!self.game.isMoveUndoable)
    .buttonStyle(GameControlButtonStyle(isEnabled: self.game.isMoveUndoable))
    .onAppear(perform: vibrator.prepare)
  }
}
