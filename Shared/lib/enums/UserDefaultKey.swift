//
//  UserDefaultKey.swift
//  sudoku
//
//  Created by Kishan Jadav on 25/01/2025.
//

enum UserDefaultKey: String {
  public var id: RawValue { rawValue }
  
  case highlightOrientation

  /// Stores the current ColorSchemeName
  case offline
  
  /// Stores the current ColorSchemeName
  case colorSchemeName
  
  /// Stores the encoded ShapeStyle
  case shapeStyle
  
  case hapticFeedbackEnabled
  
  case startGameInNotesMode
  
  case autoRemoveNotes
  
  case showTimer
  
  case useGridNumberPadStyle
}
