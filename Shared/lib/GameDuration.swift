//
//  GameDuration.swift
//  sudoku
//
//  Created by Kishan Jadav on 09/02/2025.
//

import SwiftUI

class GameDuration: ObservableObject {
  @Published private(set) var seconds: Int = 0
  
  init() { }
  
  func startFrom(_ seconds: Int) {
    self.seconds = seconds
  }
  
  func increment() {
    self.seconds += 1
  }
}
