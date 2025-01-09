//
//  AppConfig.swift
//  sudoku
//
//  Created by Kishan Jadav on 04/01/2025.
//

import Foundation

public class AppConfig {
  public struct Keys {
    static let highlightOrientation: String = "highlightOrientation"
  }
  
  static func getHighlightOrientation() -> LocationIndexOrientation {
    return LocationIndexOrientation(
      rawValue: UserDefaults.standard.string(
        forKey: AppConfig.Keys.highlightOrientation
      ) ?? LocationIndexOrientation.topToBottom.rawValue
    ) ?? .topToBottom
  }
}
