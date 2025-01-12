//
//  NewGameButtonContent.swift
//  sudoku
//
//  Created by Kishan Jadav on 12/01/2025.
//

import SwiftUI

struct NewGameButtonContent: View {
  var difficulty: Difficulty
  
  var body: some View {
    return (
      HStack {
        Text(difficulty.rawValue)
          .fontWeight(.medium)

        Spacer()

        Image(systemName: "plus")
          .foregroundStyle(difficulty.color)
      }
    )
  }
}
