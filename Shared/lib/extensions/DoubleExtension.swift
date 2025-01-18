//
//  DoubleExtensions.swift
//  Sudoku
//
//  Created by Kishan Jadav on 11/08/2024.
//

extension Double {
  var isNotEmpty: Bool {
    return self != 0
  }
  
  var isEmpty: Bool {
    return self == 0
  }
  
  /// Converts a double to an Int type
  func toInt() -> Int {
    return Int(self)
  }
  
  func half() -> Double {
    return self / 2.0
  }
}
