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

struct NotesModeToggleButton: View {
  @ObservedObject var game: Game
  @ObservedObject var cursorState: CursorState

  private let vibrator = UIImpactFeedbackGenerator(style: .rigid)
  
  var iconSystemName: String {
    return "circle.grid.3x3"
  }
  
  var isNotesModeToggled: Bool {
    return self.cursorState.mode == .note
  }
  
  var isNotesModeToggleable: Bool {
    return !self.game.isGameOver && !self.game.isGamePaused
  }
  
  var body: some View {
    Button(
      action: {
        withAnimation(.snappy(duration: 0.3)) {
          self.cursorState.mode = (self.cursorState.mode == .note) ? .number : .note
        }

        vibrator.impactOccurred()
      },
      label: {
        HStack(spacing: 8) {
          Image(systemName: iconSystemName)
            .font(.system(size: 14))
            .foregroundStyle(
              self.isNotesModeToggled ? .black : .white
            )
          
          Text("Note")
            .font(.system(size: 12))
            .foregroundStyle(
              self.isNotesModeToggled ? .black : .white
            )
        }
      }
    )
    .disabled(!isNotesModeToggleable)
    .buttonStyle(
      GameControlButtonStyle(
        disabled: !isNotesModeToggleable,
        toggled: self.isNotesModeToggled
      )
    )
  }
}
