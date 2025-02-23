//
//  ColorSchemeName.swift
//  sudoku
//
//  Created by Kishan Jadav on 05/02/2025.
//

enum ColorSchemeName: String, CaseIterable, Identifiable {
  var id: String { rawValue }

  case darkYellow = "dark.yellow"
  case darkBlue = "dark.blue"
  case darkGreen = "dark.green"
  case darkGrey = "dark.grey"

  case lightYellow = "light.yellow"
  case lightBlue = "light.blue"
  case lightGreen = "light.green"
  case lightGrey = "light.grey"
}
