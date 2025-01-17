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
    if self.cursorState.mode == .note {
      return "pencil.circle.fill"
    } else {
      return "pencil.circle"
    }
  }
  
  var isNotesModeToggleable: Bool {
    return !self.game.isGameOver && !self.game.isGamePaused
  }
  
  var body: some View {
    Button(
      action: {
        self.cursorState.mode = self.cursorState.mode == .note
          ? .number
          : .note

        vibrator.impactOccurred()
      },
      label: {
        HStack(spacing: 8) {
          Image(systemName: iconSystemName)
            .font(.system(size: 24))
            .foregroundStyle(
              self.cursorState.mode == .note ? .accent : Color.white
            )
          
          VStack(alignment: .leading) {
            Text("Notes mode")
              .fontWeight(.bold)
              .foregroundStyle(.white)
            
            Text(self.cursorState.mode == .note ? "On" : "Off")
              .foregroundStyle(
                self.cursorState.mode == .note ? .accent : Color(UIColor("#5A5A5A"))
              )
              .font(.system(size: 14, weight: .bold))
          }
        }
      }
    )
    .disabled(!isNotesModeToggleable)
    .buttonStyle(NotesModeToggleButtonStyle(disabled: !isNotesModeToggleable))
  }
}

struct NotesModeToggleButtonStyle: ButtonStyle {
  var disabled: Bool = false
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(.vertical, 14)
      .padding(.horizontal, 12)
      .background(Color(UIColor("#141414")))
      .opacity(self.disabled ? 0.3 : 1)
      .clipShape(RoundedRectangle(cornerSize: .init(width: 8, height: 8)))
      .scaleEffect(configuration.isPressed ? 0.9 : 1)
      .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
  }
}

#Preview {
    ContentView()
}
