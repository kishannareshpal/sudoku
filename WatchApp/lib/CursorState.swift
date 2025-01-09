//
//  CursorState.swift
//  sudoku
//
//  Created by Kishan Jadav on 02/09/2024.
//

struct CursorState {
  var mode: CursorMode
  var crownRotationValue: Double = 0.0
  var previousCrownRotationValue: Double = 0.0
  var preModeChangeCrownRotationValue: Double = 0.0
}
