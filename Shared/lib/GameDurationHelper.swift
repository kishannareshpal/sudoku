//
//  GameSessionTracker.swift
//  sudoku
//
//  Created by Kishan Jadav on 02/01/2025.
//

import Foundation
import SwiftDate

public class GameDurationHelper {
  static func format(_ seconds: Int, pretty: Bool = false) -> String {
    if pretty {
      // Formats as: "1h 12m 12s"
      // - Only shows h / m / s if they are applicable.

      return seconds.seconds.timeInterval.toString {
        $0.unitsStyle = .abbreviated
      }
    } else {
      // Formats as: "hh:mm:ss"
      
      let hours = seconds / 3600
      let minutes = (seconds % 3600) / 60
      let secs = seconds % 60
      return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
  }
}
