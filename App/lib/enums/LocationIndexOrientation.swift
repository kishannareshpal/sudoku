//
//  LocationIndexOrientation.swift
//  Sudoku WatchKit Extension
//
//  Created by Kishan Jadav on 09/04/2022.
//

public enum LocationIndexOrientation {
  /// Rotating the crownWheel will move the highlight from left to right, top to bottom.
  /// E.g: Starts from the top of the first column (0), moves up to 8, then passes to the top of the second column (9) and so on...
  /// ```
  ///   | 0  | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8  |
  ///   | 9  | . | . | . | . | . | . | . | 17 |
  ///   | 18 | . | . | . | . | . | . | . | 26 |
  ///   | ..
  /// ```
  case leftToRight

  /// Rotating the crownWheel will move the highlighted cell from top to bottom and left to right
  /// E.g: Starts from the top of the first column (0), moves up to 8, then moves to the second column (9) and goes down, and so on...
  /// ```
  ///   | 0 | 9  | 18 | ..
  ///   | 1 | .. | .. |
  ///   | 2 | .. | .. |
  ///   | 3 | .. | .. |
  ///   | 4 | .. | .. |
  ///   | 5 | .. | .. |
  ///   | 6 | .. | .. |
  ///   | 7 | .. | .. |
  ///   | 8 | 17 | 26 |
  /// ```
  case topToBottom
}
