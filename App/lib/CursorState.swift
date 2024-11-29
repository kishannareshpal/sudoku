//
//  CursorState.swift
//  sudoku
//
//  Created by Kishan Jadav on 02/09/2024.
//

struct CursorState {
  var activationMode: CursorActivationMode
  var location: Location
  var crownRotationValue: Double
  var preActivationModeChangeCrownRotationValue: Double = 0.0
}
