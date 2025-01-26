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
      HStack {
        Text(difficulty.rawValue)
          .fontWeight(.medium)

        Spacer()

        if loading {
          ProgressView()
        } else {
          Image(systemName: "plus")
            .foregroundStyle(difficulty.color)
        }
        
      }
    )
  }
}
