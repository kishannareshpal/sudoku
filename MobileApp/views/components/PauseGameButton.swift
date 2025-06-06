//
//  PauseGameButton.swift
//  sudoku
//
//  Created by Kishan Jadav on 12/01/2025.
//

import SwiftUI

struct PauseGameButton: View {
  @ObservedObject var gameScene: GameScene
  
  var body: some View {    
    PauseGameButtonContent(gameState: self.gameScene.game.state)
  }
}

private struct PauseGameButtonContent: View {
  private let currentColorScheme = StyleManager.current.colorScheme

  @ObservedObject var gameState: GameState
  
  private let vibrator = UIImpactFeedbackGenerator(style: .medium)
  
  var body: some View {
    Button {
      self.gameState.togglePause()
      self.vibrator.impactOccurred()
    } label: {
      Image(
        systemName: self.gameState.isGamePaused ? "play.fill" : "pause.fill"
      )
      .font(.system(size: 24))
      .foregroundStyle(
        Color(
          self.gameState.isGamePaused
          ? currentColorScheme.board.cell.text.player.valid
          : currentColorScheme.ui.game.nav.text
        )
      )
    }
    .onAppear() {
      vibrator.prepare()
    }
    .apply { view in
      if #available(iOS 17.0, *) {
        view.focusable()
      } else {
        view
      }
    }
  }
}
