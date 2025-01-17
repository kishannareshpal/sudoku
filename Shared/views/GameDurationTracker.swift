//
//  GameDurationInvisibleTracker.swift
//  sudoku
//
//  Created by Kishan Jadav on 13/01/2025.
//

import SwiftUI

struct GameDurationTracker: View {
  @ObservedObject var game: Game

  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  var body: some View {
    Color.clear
      .hidden()
      .onReceive(timer) { _ in
        guard !self.game.isGamePaused else { return }
        guard !self.game.isGameOver else { return }
        
        self.game.incrementDuration()
      }
  }
}
