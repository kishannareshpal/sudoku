//
//  GameState.swift
//  sudoku
//
//  Created by Kishan Jadav on 09/02/2025.
//

import SwiftUI

class GameState: ObservableObject {
  var id = UUID()
  
  @Published private(set) var isGameOver: Bool = false
  @Published private(set) var isGamePaused: Bool = false

  @Published private(set) var duration: GameDuration
  
  var isPlaying: Bool {
    !self.isGameOver && !self.isGamePaused
  }
  
  init() {
    self.duration = GameDuration()
  }
  
  func togglePause() {
    self.isGamePaused.toggle()
  }
  
  func endGame() {
    self.isGameOver = true
  }
}
