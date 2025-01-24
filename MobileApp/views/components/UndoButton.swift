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
        HStack {
          Image(systemName: "arrow.uturn.backward")
            .font(.system(size: 14))
            .foregroundStyle(.white)
          
          Text("Undo")
            .font(.system(size: 12))
            .foregroundStyle(.white)
        }
      }
    )
    .disabled(!self.game.isMoveUndoable)
    .buttonStyle(GameControlButtonStyle(disabled: !self.game.isMoveUndoable))
    .onAppear(perform: vibrator.prepare)
  }
}
