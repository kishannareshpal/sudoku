//
//  CursorState.swift
//  sudoku
//
//  Created by Kishan Jadav on 02/09/2024.
//

import Foundation
import SwiftUI

class CursorState: ObservableObject {
  @Published var mode: CursorMode = AppConfig.prefersStartingInNotesMode() ? .note : .number
  
  func toggleMode() {
    withAnimation(.smooth) {
      self.mode = self.mode == .note ? .number : .note
    }
  }
}
