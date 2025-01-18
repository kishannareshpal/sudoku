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
  @ObservedObject var game: Game

  private let vibrator = UIImpactFeedbackGenerator(style: .rigid)
  
  var isHintable: Bool {
    return !self.game.isGameOver && !self.game.isGamePaused
  }
  
  var body: some View {
    Button(
      action: {
        self.game.solveActivatedNumberCell()
        vibrator.impactOccurred()
      },
      label: {
        HStack {
          Image(systemName: "lightbulb")
            .font(.system(size: 14))
            .foregroundStyle(.white)
          
          Text("Hint")
            .font(.system(size: 12))
            .foregroundStyle(.white)
        }
      }
    )
    .disabled(!isHintable)
    .buttonStyle(GameControlButtonStyle(disabled: !isHintable))
  }
}
