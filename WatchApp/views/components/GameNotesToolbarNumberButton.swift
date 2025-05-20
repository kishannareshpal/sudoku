//
//  GameNotesToolbarNumberButton.swift
//  sudoku
//
//  Created by Kishan Jadav on 13/01/2025.
//


import SwiftUI
import SpriteKit

struct GameNotesToolbarNumberButton: View {
  private let currentColorScheme = StyleManager.current.colorScheme
  
  var number: Int
  var selected: Bool
  var onPress: () -> Void
  
  var body: some View {
    Button(
      action: self.onPress,
      label: {
        VStack {
          Circle()
            .frame(width: 8, height: 8)
            .foregroundStyle(
              self.selected
                ? Color(NumberCellNoteSprite.color(for: number, with: currentColorScheme))
                : Color(NumberCellNoteSprite.color(for: number, with: currentColorScheme))
                  .opacity(0.3)
            )
          
          Text(number.toString())
            .foregroundStyle(Color(self.currentColorScheme.board.cell.text.given))
            .font(.custom(TheTheme.Fonts.mono, size: 12))
        }
      }
    )
    .buttonStyle(.plain)
    .foregroundStyle(
      self.selected
        ? Color(NumberCellNoteSprite.color(for: number, with: currentColorScheme))
        : .white.opacity(0.3)
    )
  }
}
