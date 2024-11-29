//
//  NewGameCard.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

import SwiftUI

struct NewGameCard: View {
  let difficulty: Difficulty
  
  var body: some View {
    HStack(alignment: .center) {
      Text(difficulty.rawValue).fontWeight(.medium)

      Spacer()

      Image(systemName: "plus")
        .foregroundStyle(difficulty.color)
    }
    .padding()
  }
}

#Preview {
  NavigationView {
    List {
      ForEach(Difficulty.allCases) { difficulty in
        NewGameCard(difficulty: difficulty)
      }
    }
  }
}
