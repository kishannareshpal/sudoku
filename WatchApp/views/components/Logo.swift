//
//  NewGameCard.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

import SwiftUI

struct Logo: View {
  private let currentColorScheme = StyleManager.current.colorScheme

  var body: some View {
    VStack(alignment: .leading, spacing: -8) {
      Text("Mini").font(.system(size: 18, weight: .bold).italic())
      Text("SUDOKU")
    }
    .font(.system(size: 24, weight: .black).italic())
    .foregroundStyle(Color(self.currentColorScheme.board.cell.text.player.valid))
  }
}
