//
//  Difficulty.swift
//  sudoku
//
//  Created by Kishan Jadav on 18/04/2022.
//

import SwiftUICore

/// Difficulty of a playing game
public enum Difficulty: String, CaseIterable, Identifiable, Codable {
  public var id: RawValue { rawValue }
  
  case easy = "Easy"
  case medium = "Medium"
  case hard = "Hard"
  case veryHard = "Very Hard"
  case extreme = "Extreme"
}

extension Difficulty {
  var color: Color {
    switch self {
    case .easy:
      return Color(TheTheme.Difficulty.easy)
    case .medium:
      return Color(TheTheme.Difficulty.medium)
    case .hard:
      return Color(TheTheme.Difficulty.hard)
    case .veryHard:
      return Color(TheTheme.Difficulty.veryHard)
    case .extreme:
      return Color(TheTheme.Difficulty.extreme)
    }
  }
  
  var scoreMultiplier: Int {
    switch self {
    case .easy:
      return 1
    case .medium:
      return 2
    case .hard:
      return 3
    case .veryHard:
      return 4
    case .extreme:
      return 5
    }
  }
}
