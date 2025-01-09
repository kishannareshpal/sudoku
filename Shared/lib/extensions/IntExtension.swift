//
//  IntExtension.swift
//  Sudoku
//
//  Created by Kishan Jadav on 11/08/2024.
//

import CoreGraphics

extension Int {
  /// Converts an integer to a Double type
  func toDouble() -> Double {
    return Double(self)
  }
  
  func toCGFloat() -> CGFloat {
    return CGFloat(self)
  }
  
  func toString() -> String {
    return String(self)
  }
  
  func half() -> Double {
    return self.toDouble().half()
  }
}
