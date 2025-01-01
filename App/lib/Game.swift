//
//  Game.swift
//  sudoku
//
//  Created by Kishan Jadav on 26/08/2024.
//

import Foundation
import SpriteKit

class Game {
  var difficulty: Difficulty!

  var gameScene: GameScene!

  var board: Board
  var graphics: GameGraphics
  
  var cursorCell: CursorCellSprite!
  var numberCells: Array<NumberCellSprite> = []
  var activatedNumberCell: NumberCellSprite?
  
  var cursorLocation: Location = Location(
    index: 0,
    orientation: .topToBottom
  )
  
  var isNumberCellActive: Bool {
    return self.activatedNumberCell != nil
  }
  
  var numberCellUnderCursor: NumberCellSprite {
    return self.numberCells.first(
      where: { $0.location == cursorLocation }
    )!
  }
  
  var isGameOver: Bool {
    return self.numberCells.allSatisfy { cell in
      return cell.value == self.board.puzzle.solution[cell.location.row][cell.location.col]
    }
  }
  
  init(
    sceneSize: CGSize,
    difficulty: Difficulty
  ) {
    self.difficulty = difficulty
    let existingGame = SaveGameEntityDataService.findLastGame()
    
    self.board = Board(difficulty: self.difficulty, existingGame: existingGame)
    self.graphics = GameGraphics(sceneSize: sceneSize, puzzle: self.board.puzzle)
    
    // New game? Create a new save!
    if existingGame == nil {
      SaveGameEntityDataService.createNewSaveGame(difficulty: difficulty, puzzle: self.board.puzzle)
    }
  }
  
  func load(on scene: GameScene) {
    self.gameScene = scene
    
    // Draw the board
    guard let boardDrawing = self.graphics.createBoard() else { return }
    self.gameScene.addChild(boardDrawing)
    
    // Draw the given number cells
    self.numberCells = self.graphics.createNumberCells()
    self.numberCells.forEach { cell in
      self.gameScene.addChild(cell)

      // Draw the notes on each number cell
      let cellNoteValues = self.board.puzzle.notes[cell.location.row][cell.location.col]
      Task {
        await cell.toggleNotes(of: cellNoteValues, animate: false)
      }
    }
    
    // Draw the cursor
    self.cursorCell = self.graphics.createCursorCell()
    self.gameScene.addChild(self.cursorCell)
    
    // Highlight cells related to the initial cursor location's number cell
    // - The subsequent highlight events are triggered on cursor movements.
    self.highlightNumberCellsRelatedToCursor()
  }
  
  func applyActivatedNumberCellNoteValue(to value: Int) async -> Void {
    guard let activatedNumberCell = self.activatedNumberCell else { return }
    
    await activatedNumberCell.toggleNote(of: value)
    self.board.puzzle.updateNote(value: value, at: activatedNumberCell.location)
    
    // Auto-save
    SaveGameEntityDataService.autoSave(puzzle: self.board.puzzle)
  }
  
  func changeActivatedNumberCellValue(direction: Direction) -> Void {
    guard let activatedNumberCell = self.activatedNumberCell else { return }

    if (cursorCell.activeMode == .number) {
      activatedNumberCell.changeNumberValue(direction: direction)
    } else {
      Task {
        await activatedNumberCell.changeDraftNoteValue(direction: direction)
      }
    }
  }
  
  func toggleNumberCellUnderCursor(mode: CursorActivationMode, cancelled: Bool) -> Bool {
    let willActivate = !self.isNumberCellActive
    
    let activated: Bool
    if willActivate {
      activated = self.activateNumberCell(numberCellUnderCursor, mode: mode)
    } else {
      self.deactivateNumberCell(cancelled: cancelled)
      activated = false
    }
    
    return activated
  }
  
  func moveCursor(direction: Direction) -> Void {
    switch direction {
    case .forward:
      self.cursorLocation.moveToNextIndex()
    case .backward:
      self.cursorLocation.moveToPreviousIndex()
    }
    
    self.cursorCell.move(
      to: self.graphics.getPositionForCell(of: cursorLocation),
      location: cursorLocation
    )
    
    self.highlightNumberCellsRelatedToCursor()
  }
  
  private func highlightNumberCellsRelatedToCursor() -> Void {
    for numberCell in self.numberCells {
      if (numberCell.location == numberCellUnderCursor.location) {
        // Skip the cursor cell itself
        continue
      }
      
      // Should highlight cells with equal value
      let isIteratingCellEmpty = numberCell.value == 0;
      let isEqual = !isIteratingCellEmpty && (
        numberCell.value == numberCellUnderCursor.value
      )
      
      // Is the iterating cell on the same row as the cursor cell?
      let isInRow = numberCell.location.row == numberCellUnderCursor.location.row
      // Is the iterating cell on the same column as the cursor cell?
      let isInColumn = numberCell.location.col == numberCellUnderCursor.location.col
      // Is the iterating cell on the same 3x3 block as the cursor cell?
      let isInBlock = numberCell.location.grid == numberCellUnderCursor.location.grid
      
      let sameLineOrGrid = (isInRow || isInColumn || isInBlock)
      if (isEqual || sameLineOrGrid) {
        numberCell.highlight()
      } else {
        numberCell.unhighlight()
      }
    }
  }
  
  private func activateNumberCell(_ numberCell: NumberCellSprite, mode: CursorActivationMode) -> Bool {
    guard !self.isNumberCellActive else {
      return false
    }
    
    if mode == .note {
      guard numberCell.isNotable else {
        return false
      }
    }
    
    guard numberCell.isChangeable else {
      return false
    }
    
    self.activatedNumberCell = numberCell
    numberCell.resetValidation()
    self.cursorCell.activate(mode: mode)
    
    return true
  }
  
  private func deactivateNumberCell(cancelled: Bool = false) -> Void {
    guard self.isNumberCellActive else {
      return
    }
    
    if (cancelled) {
      self.discardChanges()
    } else {
      self.commitNumberChanges()
    }
    
    self.activatedNumberCell = nil
    self.cursorCell.deactivate()
  }
  
  private func discardChanges() -> Void {
    guard let activatedNumberCell = self.activatedNumberCell else {
      return
    }

    // Cancel changes
    activatedNumberCell.discardValueChange()
    
    // Re-validate cell as it was reset during cell activation
    activatedNumberCell.toggleValidation(
      valid: self.board.puzzle.validate(
        value: activatedNumberCell.value,
        at: activatedNumberCell.location
      )
    )
  }
  
  private func commitNumberChanges() -> Void {
    guard let activatedNumberCell = self.activatedNumberCell else {
      return
    }
    
    let value = activatedNumberCell.numberValueToBeCommitted
    let location = activatedNumberCell.location
    
    // Validate comitting changes
    let validChange = self.board.puzzle.validate(value: value, at: location)
    activatedNumberCell.toggleValidation(valid: validChange)
    
    // Commit changes
    self.board.puzzle.updatePlayer(value: value, at: location)
    activatedNumberCell.commitValueChange()
    
    // Clear all the notes from this cell if committing a non-zero value to the cell
    if value != 0 {
      self.board.puzzle.clearNotes(at: location)
      activatedNumberCell.clearNotes()
    }
    
    // Auto-save
    SaveGameEntityDataService.autoSave(puzzle: self.board.puzzle)
    
    // Check whether all cells have been correctly completed
    if self.isGameOver {
      self.gameOver()
    }
  }
  
  private func gameOver() {
    SaveGameEntityDataService.clear()    
    self.gameScene.didGameOver()
  }
}
