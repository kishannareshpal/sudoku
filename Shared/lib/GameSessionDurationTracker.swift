//
//  GameSessionTracker.swift
//  sudoku
//
//  Created by Kishan Jadav on 02/01/2025.
//

import Foundation

public class GameSessionDurationTracker: ObservableObject {
  /// The time the game session was started.
  var startedAt: Date = Date()
  
  /// Return the calculated elapsed duration in seconds based on the defined start time.
  var elapsedDurationInSeconds: Int64 {
    Int64(Date().timeIntervalSince(self.startedAt))
  }
  
  static func format(_ seconds: Int64) -> String {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let secs = seconds % 60
    
    var components: [String] = []
    if hours > 0 {
      components.append("\(hours)h")
    }
    if minutes > 0 || hours > 0 { // Show minutes if there are hours
      components.append("\(minutes)m")
    }
    components.append("\(secs)s") // Always shows seconds
    
    return components.joined(separator: " ")
  }
}
