//
//  Difficulty.swift
//  Sudoku WatchKit Extension
//
//  Created by Kishan Jadav on 18/04/2022.
//

import SwiftUICore

/// Difficulty of a playing game
public enum Difficulty: String, CaseIterable, Identifiable {
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
      return Color(Theme.Difficulty.easy)
    case .medium:
      return Color(Theme.Difficulty.medium)
    case .hard:
      return Color(Theme.Difficulty.hard)
    case .veryHard:
      return Color(Theme.Difficulty.veryHard)
    case .extreme:
      return Color(Theme.Difficulty.extreme)
    }
  }
}