//
//  KeyboardArrowDirection.swift
//  sudoku
//
//  Created by Kishan Jadav on 22/05/2025.
//

import SwiftUI

public enum KeyboardArrowDirection {
  case up
  case down
  case left
  case right
  
  @available(iOS 17.0, *)
  static func from(key: KeyEquivalent) -> KeyboardArrowDirection {
    switch key {
      case .upArrow:
        return .up
      case .downArrow:
        return .down
      case .leftArrow:
        return .left
      case .rightArrow:
        return .right
      default:
        fatalError("There is no keyboard arrow direction for key equivalent of: \(key)")
    }
  }
}
