//
//  EraseButton.swift
//  sudoku
//
//  Created by Kishan Jadav on 26/01/2025.
//

import SwiftUI
import SpriteKit
import UIKit.UIColor
import UIColorHexSwift

struct PuzzleDebug: View {
  @ObservedObject var puzzle: Puzzle
    
  var body: some View {
    Section(
      header: Text("MOVEMENT HISTORY TRACKER")
    ) {
      VStack(alignment: .leading) {
        Text("Summary:")
        Text(
          "• Current move index: \(self.puzzle.moveIndex)"
        )
        Text("• Number of moves in total: \(puzzle.moves.count)").padding(.bottom)
      }
      
      ScrollView {
        VStack(alignment: .leading, spacing: 6) {
          Text(
            "\(puzzle.moveIndex == -1 ? " ❯ " : "   ") Initial position – No moves."
          )

          ForEach(puzzle.moves, id: \.index) { move in
            Text(
              "\(puzzle.moveIndex == move.index ? " ❯ " : "   ") Index: \(move.index.toString()) – Type: \(move.type) – Value: \(move.value) – Location: \(move.locationNotation)"
            )
          }
          
        }
        .font(.subheadline.monospaced())
        .frame(maxWidth: .infinity)
      }
    }.padding(.top)
  }
}
