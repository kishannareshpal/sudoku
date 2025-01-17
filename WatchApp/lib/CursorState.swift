//
//  CursorState.swift
//  sudoku
//
//  Created by Kishan Jadav on 02/09/2024.
//

import Combine

class CursorState: ObservableObject {
  @Published var mode: CursorMode = .none
  @Published var crownRotationValue: Double = 0.0
  var previousCrownRotationValue: Double = 0.0
  var preModeChangeCrownRotationValue: Double = 0.0
}
