//
//  ActivatedCursorState.swift
//  sudoku
//
//  Created by Kishan Jadav on 09/02/2025.
//

import SwiftUI

class ActiveCursorState: ObservableObject {
  var id = UUID()
  
  /// The activated cursor number cell sprite
  @Published var numberCell: NumberCellSprite?
  
  var isActive: Bool {
    self.numberCell != nil
  }
}
