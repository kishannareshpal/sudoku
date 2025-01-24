//
//  PauseGameButton.swift
//  sudoku
//
//  Created by Kishan Jadav on 12/01/2025.
//

import SwiftUI

struct PauseGameButton: View {
  @ObservedObject var game: Game

  private let vibrator = UIImpactFeedbackGenerator(style: .medium)
  
  var body: some View {
    Button {
      self.game.togglePause()
      self.vibrator.impactOccurred()
    } label: {
      Image(
        systemName: self.game.isGamePaused ? "play.fill" : "pause.fill"
      )
      .font(.system(size: 24))
      .foregroundStyle(.white)
      .apply { view in
        if #available(iOS 17.0, *) {
          view.symbolEffect(.bounce.wholeSymbol, value: self.game.isGamePaused)
        }
      }
    }
    .onAppear() {
      vibrator.prepare()
    }
  }
}
