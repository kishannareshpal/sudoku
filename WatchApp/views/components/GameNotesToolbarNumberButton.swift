//
//  GameNotesToolbarNumberButton.swift
//  sudoku
//
//  Created by Kishan Jadav on 13/01/2025.
//


import SwiftUI
import SpriteKit

struct GameNotesToolbarNumberButton: View {
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
              // self.selectedNumber == number
              self.selected
                ? Color(NumberCellNoteSprite.color(for: number))
                : Color(NumberCellNoteSprite.color(for: number)).opacity(0.3)
            )
          
          Text(number.toString())
            .font(.custom(Theme.Fonts.mono, size: 12))
        }
      }
    )
    .buttonStyle(.plain)
    .foregroundStyle(
      self.selected
        ? Color(NumberCellNoteSprite.color(for: number))
        : .white.opacity(0.3)
    )
  }
}
