//
//  Game.swift
//  sudoku
//
//  Created by Kishan Jadav on 26/08/2024.
//

import Foundation
import SpriteKit

class PreviewGame {
  private(set) var board: Board
  private(set) var graphics: GameGraphics
  private(set) var puzzle: Puzzle

  private(set) var numberCells: Array<NumberCellSprite> = []
  
  init(
    sceneSize: CGSize,
    puzzle: Puzzle
  ) {
    self.puzzle = puzzle
    self.board = Board()
    self.graphics = GameGraphics(sceneSize: sceneSize, puzzle: puzzle)
  }

  func load(on scene: SKScene) {
    // Draw the board
    guard let boardDrawing = self.graphics.createBoard() else { return }
    scene.addChild(boardDrawing)
    
    // Draw the number cells
    self.numberCells = self.graphics.createNumberCells()
    self.numberCells.forEach { numberCell in
      scene.addChild(numberCell)

      // Draw the notes cells
      let numberCellNoteValues = self.puzzle.notes[numberCell.location.row][numberCell.location.col]
      
      numberCell.toggleNotes(
        values: numberCellNoteValues,
        forceVisible: true,
        animate: false
      )
    }
  }
}
