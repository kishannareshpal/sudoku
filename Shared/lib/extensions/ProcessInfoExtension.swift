//
//  ProcessInfoExtension.swift
//  sudoku
//
//  Created by Kishan Jadav on 02/02/2025.
//

import Foundation

public extension ProcessInfo {
  var isXcodePreview: Bool {
    environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
  }
}
