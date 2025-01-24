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
  @ObservedObject var game: Game

  private let vibrator = UIImpactFeedbackGenerator(style: .rigid)
  
  var body: some View {
    Button(
      action: {
        self.game.redoMove()
        self.vibrator.impactOccurred()
      },
      label: {
        HStack {
          Image(systemName: "arrow.uturn.forward")
            .font(.system(size: 14))
            .foregroundStyle(.white)
          
          Text("Redo")
            .font(.system(size: 12))
            .foregroundStyle(.white)
        }
      }
    )
    .disabled(!self.game.isMoveRedoable)
    .buttonStyle(GameControlButtonStyle(disabled: !self.game.isMoveRedoable))
    .onAppear(perform: vibrator.prepare)
  }
}
