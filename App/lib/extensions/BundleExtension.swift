//
//  BundleExtension.swift
//  sudoku
//
//  Created by Kishan Jadav on 04/01/2025.
//

import Foundation

extension Bundle {
  var appVersionNumber: String {
    return (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
  }
  
  var appBuildNumber: String? {
    return infoDictionary?["CFBundleVersion"] as? String
  }
}
