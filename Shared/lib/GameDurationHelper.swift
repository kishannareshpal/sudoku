//
//  GameSessionTracker.swift
//  sudoku
//
//  Created by Kishan Jadav on 02/01/2025.
//

import Foundation

public class GameDurationHelper {
  static func format(_ seconds: Int64, pretty: Bool = false) -> String {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let secs = seconds % 60
    
    if pretty {
      // Formats as: "1h 12m 12s"
      // - Only shows h / m / s if they are applicable.

      var components: [String] = []
      if hours > 0 {
        components.append("\(hours)h")
      }
      if minutes > 0 || hours > 0 { // Show minutes if there are hours
        components.append("\(minutes)m")
      }
      components.append("\(secs)s") // Always shows seconds
      
      return components.joined(separator: " ")
    } else {
      // Formats as: "00:00:00"
      return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
    
  }
}
