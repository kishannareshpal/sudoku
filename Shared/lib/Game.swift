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
    
    // Draw saved / given number cells
    self.numberCells = self.graphics.createNumberCells()
    self.numberCells.forEach { numberCell in
      scene.addChild(numberCell)

      // Draw given / saved notes on each number cell
      let numberCellNoteValues = self.board.puzzle.notes[numberCell.location.row][numberCell.location.col]
      numberCell.toggleNotes(values: numberCellNoteValues, animate: false)
    }
    
    // Draw the cursor
    self.cursorCell = self.graphics.createCursorCell()
    scene.addChild(self.cursorCell)
    
    // Highlight peer cells related to the initial cursor location's number cell
    // - The subsequent highlight events are triggered on cursor movements.
    self.highlightAllPeerCellsRelatedToCursor()
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
    
    activatedNumberCell.toggleNote(value: value)
    self.board.puzzle.toggleNote(value: value, at: activatedNumberCell.location)
    
    // Auto-save
    SaveGameEntityDataService.autoSave(
      puzzle: self.board.puzzle,
      duration: self.durationInSeconds
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
    self.highlightAllPeerCellsRelatedToCursor()
    
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
  
  func solveActivatedNumberCell() -> Void {
    guard let activatedNumberCell = self.activatedNumberCell else { return }
    
    let location = activatedNumberCell.location
    let cellSolutionValue = self.board.puzzle.solution[location.row][location.col]
    
    self.changeActivatedNumberCellValue(with: cellSolutionValue)
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
  
  func clearAllPeerCellsNotes(with value: Int) -> Void {
    let cursorValue = numberCellUnderCursor.value
    let cursorLocation = numberCellUnderCursor.location
    
    self.processEachPeerAndNonPeerNumberCells(for: (cursorValue, cursorLocation)) { peerNumberCell in
      self.board.puzzle
        .toggleNote(
          value: cursorValue,
          at: peerNumberCell.location,
          forceAdd: false
        )

      peerNumberCell.toggleNote(value: cursorValue, forceVisible: false)
    }
    
    // Auto-save
    SaveGameEntityDataService
      .autoSave(
        puzzle: self.board.puzzle,
        duration: self.durationInSeconds,
        score: self.score
      )
  }
  
  /// Highlights all peer cells related to the number cell currently under the cursor.
  ///
  /// This method iterates over all number cells in the Sudoku board. It highlights:
  /// - The cell currently under the cursor.
  /// - All cells with the same value as the cursor cell (if the cursor cell has a non-zero value).
  /// - All cells in the same row, column, or 3x3 block (grid) as the cursor cell.
  /// Any other cells will be unhighlighted.
  ///
  /// - Returns:
  ///   - Void: This function does not return a value.
  private func highlightAllPeerCellsRelatedToCursor() -> Void {
    let cursorValue = numberCellUnderCursor.value
    let cursorLocation = numberCellUnderCursor.location
    
    self.processEachPeerAndNonPeerNumberCells(
      for: (cursorValue, cursorLocation),
      peerFoundCallback: { peerNumberCell in
        peerNumberCell.highlight()
      },
      nonPeerFoundCallback: { nonPeerNumberCell in
        nonPeerNumberCell.unhighlight()
      }
    )
  }
  
  /// Processes each peer and non-peer number cell for a given value and location in the board.
  ///
  /// This method iterates over all the number cells in the `numberCells` collection and applies conditions to identify which cells are peers (based on criteria like row, column, grid, or value) and which are not. For each peer cell, the `peerFoundCallback` is triggered. If a non-peer cell is found, the optional `nonPeerFoundCallback` will be triggered, if provided.
  ///
  /// - Parameters:
  ///   - cell: A tuple containing the value of the current cell and its location.
  ///   - allowSelfAsPeer: A boolean flag to allow the current cell to be considered as a peer (default is `true`).
  ///   - allowRowPeers: A boolean flag to allow peers from the same row (default is `true`).
  ///   - allowColumnPeers: A boolean flag to allow peers from the same column (default is `true`).
  ///   - allowGridPeers: A boolean flag to allow peers from the same grid (default is `true`).
  ///   - allowSameValuePeers: A boolean flag to allow peers that have the same value as the current cell (default is `true`).
  ///   - peerFoundCallback: A closure that gets called for each peer cell  its number cell reference object from the `numberCells` collection.
  ///   - nonPeerFoundCallback: An optional closure that gets called for each non-peer cell with its number cell object reference from the `numberCells` collection.
  ///     - If provided, it will be triggered for each non-peer cell found. If no non-peer cells are found, this callback will not be called.
  private func processEachPeerAndNonPeerNumberCells(
    for cell: (value: Int, location: Location),
    allowSelfAsPeer: Bool = true,
    allowRowPeers: Bool = true,
    allowColumnPeers: Bool = true,
    allowGridPeers: Bool = true,
    allowSameValuePeers: Bool = true,
    peerFoundCallback: (_ peerNumberCell: NumberCellSprite) -> Void,
    nonPeerFoundCallback: ((_ nonPeerNumberCell: NumberCellSprite) -> Void)? = nil
  ) -> Void {
    for numberCell in self.numberCells {
      let isSelf = numberCell.location == cell.location
      if isSelf {
        if allowSelfAsPeer {
          peerFoundCallback(numberCell)
        } else {
          nonPeerFoundCallback?(numberCell)
        }

        continue
      }
      
      // Check row, column, and grid peer conditions
      let sameRow = allowRowPeers && numberCell.location.row == cell.location.row
      if (sameRow) {
        peerFoundCallback(numberCell)
        continue
      }
      
      let sameColumn = allowColumnPeers && numberCell.location.col == cell.location.col
      if (sameColumn) {
        peerFoundCallback(numberCell)
        continue
      }
      
      let sameGrid = allowGridPeers && numberCell.location.grid == cell.location.grid
      if (sameGrid) {
        peerFoundCallback(numberCell)
        continue
      }
      
      // Check same value condition
      let sameValue = allowSameValuePeers && (
        !numberCell.isValueEmpty && (numberCell.value == cell.value)
      )
      if (sameValue) {
        peerFoundCallback(numberCell)
        continue
      }
      
      // Not a peer number cell
      nonPeerFoundCallback?(numberCell)
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

    if !value.isEmpty {
      // Committed a non-empty value to the cell
      // Clear any previous notes from it
      self.clearActivatedNumberCellNotes()
      self.clearAllPeerCellsNotes(with: value)
      
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
