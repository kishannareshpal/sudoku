//
//  DurationView.swift
//  sudoku
//
//  Created by Kishan Jadav on 09/02/2025.
//

import SwiftUI

struct DurationText: View {
  private let currentColorScheme: ColorScheme = StyleManager.current.colorScheme
  @ObservedObject var gameDuration: GameDuration
  
  var body: some View {
    Text(GameDurationHelper.format(self.gameDuration.seconds))
      .font(.system(size: 24, weight: .bold).monospaced())
      .foregroundStyle(Color(self.currentColorScheme.ui.game.nav.text))
  }
}
