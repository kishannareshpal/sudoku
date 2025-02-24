//
//  NewGameButtonContent.swift
//  sudoku
//
//  Created by Kishan Jadav on 12/01/2025.
//

import SwiftUI

struct NewGameButtonContent: View {
  var difficulty: Difficulty
  var loading: Bool = false
  
  var body: some View {
    return (
      HStack(alignment: .center) {
        Text(difficulty.rawValue)
          .fontWeight(.medium)

        Spacer()

        if loading {
          ProgressView()
            .frame(width: 18, height: 18)
            .progressViewStyle(.circular)
            .tint(difficulty.color)

        } else {
          Image(systemName: "plus")
            .foregroundStyle(difficulty.color)
        }
      }
    )
  }
}
