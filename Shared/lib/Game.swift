//
//  Game.swift
//  sudoku
//
//  Created by Kishan Jadav on 26/08/2024.
//

import Foundation
import SpriteKit

class Game: ObservableObject {
  private static let VALID_MOVE_SCORE_ADDITIVE_INCREMENT: Int = 10
  private static let INVALID_MOVE_SCORE_ADDITIVE_INCREMENT: Int = -5
  
  private(set) var difficulty: Difficulty
  private(set) var board: Board
  private(set) var graphics: GameGraphics
  
  private(set) var cursorCell: CursorCellSprite!
  private(set) var numberCells: Array<NumberCellSprite> = []
  @Published private(set) var activatedNumberCell: NumberCellSprite?
  
  @Published private(set) var isGameOver: Bool = false
  @Published private(set) var isGamePaused: Bool = false
  @Published private(set) var durationInSeconds: Int64 = 0
  @Published private(set) var score: Int64 = 0
  
  var cursorLocation: Location {
    get {
      return self.cursorCell.location
    }

    set {
      self.cursorCell.move(
        to: self.graphics.getPositionForCell(of: newValue),
        location: newValue
      )
    }
  }
  
  var isNumberCellActive: Bool {
    return self.activatedNumberCell != nil
  }
  
  var numberCellUnderCursor: NumberCellSprite {
    return self.numberCells.first(
      where: { $0.location == cursorLocation }
    )!
  }
  
  init(
    sceneSize: CGSize,
    difficulty: Difficulty
  ) {
    self.difficulty = difficulty
    let existingGame = SaveGameEntityDataService.findCurrentGame()
    
    self.board = Board(difficulty: self.difficulty, existingGame: existingGame)
    self.graphics = GameGraphics(sceneSize: sceneSize, puzzle: self.board.puzzle)
    
    // New game? Create a new save!
    if existingGame == nil {
      SaveGameEntityDataService.createNewSaveGame(difficulty: difficulty, puzzle: self.board.puzzle)
    }
    
    self.durationInSeconds = existingGame?.durationInSeconds ?? 0
    self.score = existingGame?.score ?? 0
    self.isGameOver = self.checkGameOver()
  }

  func load(on scene: GameScene) {
    // Draw the board
    guard let boardDrawing = self.graphics.createBoard() else { return }
    scene.addChild(boardDrawing)
    
    // Draw the given number cells
    self.numberCells = self.graphics.createNumberCells()
    self.numberCells.forEach { cell in
      scene.addChild(cell)

      // Draw the notes on each number cell
      let cellNoteValues = self.board.puzzle.notes[cell.location.row][cell.location.col]
      cell.toggleNotes(of: cellNoteValues, animate: false)
    }
    
    // Draw the cursor
    self.cursorCell = self.graphics.createCursorCell()
    scene.addChild(self.cursorCell)
    
    // Highlight cells related to the initial cursor location's number cell
    // - The subsequent highlight events are triggered on cursor movements.
    self.highlightNumberCellsRelatedToCursor()
  }
  
  func incrementDuration() -> Void {
    guard !self.isGameOver else {
      return
    }
    
    guard !self.isGamePaused else {
      return
    }
    
    self.durationInSeconds += 1
  }
  
  func saveCurrentGameDuration() -> Void {
    guard !self.isGameOver else {
      return
    }
    
    SaveGameEntityDataService.saveDuration(seconds: self.durationInSeconds)
  }
  
  func toggleActivatedNumberCellNoteValue(with value: Int) -> Void {
    guard !self.isGameOver else {
      return
    }
    
    guard !self.isGamePaused else {
      return
    }
    
    guard let activatedNumberCell = self.activatedNumberCell else { return }
    guard activatedNumberCell.isChangeable && activatedNumberCell.isNotable else {
      return
    }
    
    activatedNumberCell.toggleNote(of: value)
    self.board.puzzle.updateNote(value: value, at: activatedNumberCell.location)
    
    // Auto-save
    SaveGameEntityDataService.autoSave(
      puzzle: self.board.puzzle,
      duration: self.durationInSeconds
    )
  }
  
  func clearActivatedNumberCellNotes() -> Void {
    guard !self.isGameOver else {
      return
    }
    
    guard !self.isGamePaused else {
      return
    }
    
    guard let activatedNumberCell = self.activatedNumberCell else { return }
    guard activatedNumberCell.isChangeable else { return }
    
    self.board.puzzle.clearNotes(at: activatedNumberCell.location)
    activatedNumberCell.clearNotes()
    
    // Auto-save
    SaveGameEntityDataService
      .autoSave(
        puzzle: self.board.puzzle,
        duration: self.durationInSeconds,
        score: self.score
      )
  }
  
  func changeActivatedNumberCellValue(cursorMode: CursorMode, direction: Direction) -> Void {
    guard !self.isGameOver else {
      return
    }
    
    guard !self.isGamePaused else {
      return
    }
    
    guard let activatedNumberCell = self.activatedNumberCell else { return }
    guard activatedNumberCell.isChangeable else { return }

    if (cursorMode == .number) {
      activatedNumberCell.changeDraftNumberValue(direction: direction)
    } else {
      activatedNumberCell.changeDraftNoteValue(direction: direction)
    }
  }
  
  func changeActivatedNumberCellValue(with value: Int) -> Void {
    guard !self.isGameOver else {
      return
    }
    
    guard !self.isGamePaused else {
      return
    }
    
    guard let activatedNumberCell = self.activatedNumberCell else { return }
    guard activatedNumberCell.isChangeable else { return }
    
    activatedNumberCell.changeDraftNumberValue(to: value.toDouble())
    self.commitNumberChanges()
  }
  
  func clearActivatedNumberValue() -> Void {
    guard !self.isGameOver else {
      return
    }
    
    guard !self.isGamePaused else {
      return
    }
    
    self.changeActivatedNumberCellValue(with: 0)
  }
  
  func toggleNumberCellUnderCursor(mode: CursorMode, cancelled: Bool) -> Bool {
    guard !self.isGameOver else {
      return false
    }
    
    guard !self.isGamePaused else {
      return false
    }
    
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
  
  func moveCursor(to location: Location, activateCellImmediately: Bool = false) -> Void {
    self.cursorLocation = location
    self.highlightNumberCellsRelatedToCursor()
    
    if activateCellImmediately && !(self.isGameOver || self.isGamePaused) {
      self.activatedNumberCell = numberCellUnderCursor
    }
    
    print("Activated number cell: ", self.isNumberCellActive)
  }

  func moveCursor(direction: Direction) -> Void {
    switch direction {
    case .forward:
      self.cursorLocation.moveToNextIndex()
    case .backward:
      self.cursorLocation.moveToPreviousIndex()
    }
    
    self.moveCursor(to: self.cursorLocation)
  }
  
  func togglePause() -> Void {
    self.isGamePaused.toggle()
  }
  
  func delete() -> Void {
    SaveGameEntityDataService.delete()
  }
  
  private func highlightNumberCellsRelatedToCursor() -> Void {
    for numberCell in self.numberCells {
      if (numberCell.location == numberCellUnderCursor.location) {
        // The cell where the cursor is located
        numberCell.highlight()
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
  
  private func activateNumberCell(_ numberCell: NumberCellSprite, mode: CursorMode) -> Bool {
    guard !self.isGameOver else {
      return false
    }
    
    guard !self.isGamePaused else {
      return false
    }
    
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
    activatedNumberCell.discardDraftNumberValueChange()
    
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

    // Committing a non-empty value to the cell
    if value != 0 {
      // Clear any previous notes from it
      self.clearActivatedNumberCellNotes()
      
      let scoreToAddForThisMove = Int64(
        (
          validChange
          ? Game.VALID_MOVE_SCORE_ADDITIVE_INCREMENT
          : Game.INVALID_MOVE_SCORE_ADDITIVE_INCREMENT
        ) * self.difficulty.scoreMultiplier
      )
      
      self.score += scoreToAddForThisMove
      self.score = max(self.score, 0)
    }
    
    // Auto-save
    SaveGameEntityDataService.autoSave(
      puzzle: self.board.puzzle,
      duration: self.durationInSeconds,
      score: self.score
    )
    
    // Check whether all cells have been correctly completed
    self.isGameOver = self.checkGameOver()
  }
  
  private func checkGameOver() -> Bool {
    return self.board.puzzle.checkGameOver()
  }
}
