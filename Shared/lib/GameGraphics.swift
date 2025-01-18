//
//  GameGraphics.swift
//  sudoku
//
//  Created by Kishan Jadav on 07/01/2023.
//

import SpriteKit

public class GameGraphics {
  var sceneSize: CGSize
  var puzzle: Puzzle!

  var boardSize: CGSize!
  var boardPosition: CGPoint!
  var cellSize: CGSize!
  
  init(sceneSize: CGSize, puzzle: Puzzle) {
    self.sceneSize = sceneSize
    self.puzzle = puzzle

    let boardSize = self.determineBestBoardDimensions()
    self.boardSize = boardSize
    self.cellSize = self.determineCellSize()
  }
  
  func createBoard() -> BoardSprite? {
    // Draw the board sprite
    let boardSprite = BoardSprite(boardSize: self.boardSize, cellSize: self.cellSize)
    guard let boardSprite = boardSprite else {
      return nil
    }
    
    // Position the scene in the middle
    // Note that scene a sprite's anchor point is in the middle
    boardSprite.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
    boardSprite.zPosition = ZIndex.board
    boardSprite.name = "Board"

    return boardSprite
  }

  func createNumberCells() -> [NumberCellSprite] {
    var cells: [NumberCellSprite] = []

    for (rowIndex, rowValues) in self.puzzle.given.enumerated() {
      for (colIndex, givenValue) in rowValues.enumerated() {
        let cellLocation = Location(row: rowIndex, col: colIndex)

        let playerValue = self.puzzle.player[rowIndex][colIndex]
        let usePlayerValue: Bool = givenValue.isEmpty
        
        let cell = self.createNumberCell(
          at: cellLocation,
          isStatic: !usePlayerValue,
          withValue: usePlayerValue ? playerValue : givenValue
        )
        
        if (usePlayerValue && playerValue.isNotEmpty) {
          cell.toggleValidation(
            valid: self.puzzle.validate(value: playerValue, at: cellLocation)
          )
        }

        cells.append(cell)
      }
    }

    return cells
  }
  
  func createCursorCell() -> CursorCellSprite {
    let initialLocation = Location(
      row: 0,
      col: 0,
      orientation: AppConfig.getHighlightOrientation()
    )
    let initialPosition = self.getPositionForCell(of: initialLocation)
    
    let cell = CursorCellSprite(
      size: self.cellSize,
      initialPostion: initialPosition,
      initialLocation: initialLocation
    )
    
    return cell
  }
  
  /// Returns the ``CGPoint`` position where a cell should be drawn for the given ``location`` in the board.
  func getPositionForCell(of location: Location) -> CGPoint {
    let topLeftX = (self.sceneSize.width / 2.0) - (self.cellSize.width * 4)
    let topLeftY = (self.sceneSize.height / 2.0) + (self.cellSize.height * 4)

    let x = topLeftX + (self.cellSize.width * CGFloat(location.col))
    let y = topLeftY - (self.cellSize.width * CGFloat(location.row))

    return CGPoint(x: x, y: y)
  }

  private func createNumberCell(
    at location: Location,
    isStatic: Bool,
    withValue value: Int
  ) -> NumberCellSprite {
    let cellSprite = NumberCellSprite(
      size: self.cellSize,
      location: location,
      value: value,
      isStatic: isStatic
    )

    let cellPosition = self.getPositionForCell(of: location)
    cellSprite.move(to: cellPosition)
    
    return cellSprite
  }
  
  /// Determine the best dimension (width / height) for the square sudoku board relative to the
  /// watch screen, taking into consideration its safe area insets automatically attached to the scene on render.
  private func determineBestBoardDimensions() -> CGSize {
    let sizeThatFits = min(self.sceneSize.width, self.sceneSize.height)
    
    // This allows for the cursor cell to not cut-off its outline at the edges of the canvas
    // by giving a little more room.
    let padding = Theme.Cell.Cursor.outlineWidth / 2.0
    
    let boardSize = CGSize(
      width: sizeThatFits - padding,
      height: sizeThatFits - padding
    )
    
    return boardSize
  }
  
  /// Returns the width for each cell in the board
  /// - SeeAlso: ``getCellHeight()`` to get the cell's Height instead, or ``determineCellSize()`` to get both width and height as `CGSize`
  /// - Returns: width of a board cell.
  private func getCellWidth() -> CGFloat {
    return self.boardSize.width / CGFloat(Board.colsCount)
  }
  
  /// Returns the height for each cell in the board
  /// - SeeAlso: ``getCellWidth()`` to get the cell's Width instead, or ``determineCellSize()`` to get both width and height as `CGSize`
  /// - Returns: height of a board cell.
  private func getCellHeight() -> CGFloat {
    return self.boardSize.height / CGFloat(Board.rowsCount)
  }
  
  /// Returns the determined size for each cell in the board
  /// - SeeAlso: ``getCellWidth()`` to get the cell's Width and ``getCellHeight()`` for it's height, individually.
  /// - Returns: size of a board cell.
  private func determineCellSize() -> CGSize {
    return CGSize(width: self.getCellWidth(), height: self.getCellHeight())
  }
}
