//
//  GameState.swift
//  sudoku
//
//  Created by Kishan Jadav on 09/02/2025.
//

import Combine

class GameState: ObservableObject {
  @Published private(set) var isGameOver: Bool = false
  @Published private(set) var isGamePaused: Bool = false
  
  private(set) var duration: 
  
  func togglePause() {
    self.isGamePaused.toggle()
  }
  
  func endGame() {
    self.isGameOver = true
  }
}
