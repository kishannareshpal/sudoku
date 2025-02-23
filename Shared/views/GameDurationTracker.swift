//
//  GameDurationTracker.swift
//  sudoku
//
//  Created by Kishan Jadav on 13/01/2025.
//

import SwiftUI

struct GameDurationTracker: View {
  var gameState: GameState

  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  var body: some View {
    Color.clear.hidden().onReceive(timer) { _ in
      guard !self.gameState.isGamePaused else { return }
      guard !self.gameState.isGameOver else { return }
      
      self.gameState.duration.increment()
    }
  }
}
