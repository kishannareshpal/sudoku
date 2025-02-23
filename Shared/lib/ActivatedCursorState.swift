//
//  GameState.swift
//  sudoku
//
//  Created by Kishan Jadav on 09/02/2025.
//

import SwiftUI

class ActivatedCursorState: ObservableObject {
  var id = UUID()
  
  @Published private(set) var isGameOver: Bool = false
  @Published private(set) var isGamePaused: Bool = false

  @Published private(set) var duration: GameDuration
  
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
