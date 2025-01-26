//
//  SolveButton.swift
//  sudoku
//
//  Created by Kishan Jadav on 13/01/2025.
//


import SwiftUI

struct SolveButton: View {
  var gameScene: GameScene
  
  var body: some View {
    Button("Solve") {
      self.gameScene.game.puzzle.solution.enumerated().forEach { (rowIndex, row) in
        row.enumerated().forEach { (colIndex, value) in
          
          let isGivenCell = self.gameScene.game.puzzle.given[rowIndex][colIndex].isNotEmpty
          if isGivenCell {
            // Skip given cells
            return
          }
          
          let delayInSeconds: Double = 0.1
          let location = Location(row: rowIndex, col: colIndex)
          
          DispatchQueue.main.asyncAfter(
            deadline: .now() + delayInSeconds * Double(location.index)
          ) {
            self.gameScene.game.moveCursor(
              to: location, activateCellImmediately: true
            )
            
            self.gameScene.changeActivatedNumberCellValue(to: value)
          }
        }
      }
    }
  }
}
