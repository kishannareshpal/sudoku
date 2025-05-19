//
//  Game.swift
//  sudoku
//
//  Created by Kishan Jadav on 26/08/2024.
//

import Foundation
import SpriteKit

class Game: ObservableObject {
  var id: UUID = UUID()
  
  private static let VALID_MOVE_SCORE_ADDITIVE_INCREMENT: Int = 10
  private static let INVALID_MOVE_SCORE_ADDITIVE_INCREMENT: Int = -20
  
  private(set) var saveGameId: EntityID

  private(set) var difficulty: Difficulty
  private(set) var board: Board

  private(set) var graphics: GameGraphics
  private(set) var puzzle: Puzzle
  
  private(set) var cursorCell: CursorCellSprite!
  private(set) var numberCells: Array<NumberCellSprite> = []

  private(set) var activeCursorState: ActiveCursorState = ActiveCursorState()

  private(set) var state: GameState

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
  
  var numberCellUnderCursor: NumberCellSprite {
    return self.numberCells.first(
      where: { $0.location == self.cursorLocation }
    )!
  }
  
  init(sceneSize: CGSize) throws {
    guard let saveGame = DataManager.default.saveGamesService.findActiveLocalSaveGame() else {
      fatalError("Attempted to load a game with no active save game")
    }
    
    self.saveGameId = saveGame.objectID
    self.score = saveGame.score
    self.difficulty = Difficulty(rawValue: saveGame.difficulty!)!

    self.board = Board()

    let puzzle = Puzzle(saveGame: saveGame)
    self.puzzle = puzzle

    self.graphics = GameGraphics(sceneSize: sceneSize, puzzle: puzzle)
    self.state = GameState()
    
    if self.checkGameOver() {
      self.state.endGame()
    }
    
    // Pre-set the time already spent in the game on game start
    self.state.duration.startFrom(Int(saveGame.durationInSeconds))
  }
  
  func resizeGraphics(to sceneSize: CGSize) {
    self.graphics.resize(to: sceneSize)
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
      let numberCellNoteValues = self.puzzle.notes[numberCell.location.row][numberCell.location.col]

      numberCell.toggleNotes(
        values: numberCellNoteValues,
        forceVisible: true,
        animate: false
      )
    }
    
    // Draw the cursor
    self.cursorCell = self.graphics.createCursorCell()
    scene.addChild(self.cursorCell)
    
    // Highlight peer cells related to the initial cursor location's number cell
    // - The subsequent highlight events are triggered on cursor movements.
    self.highlightAllPeerCellsRelatedToCursor()
  }
  
  func incrementGameDuration() -> Void {
    guard !self.state.isGameOver else {
      return
    }
    
    guard !self.state.isGamePaused else {
      return
    }
    
    self.state.duration.increment()
  }
  
  func saveCurrentGameDuration() -> Void {
    guard !self.state.isGameOver else {
      return
    }

    try? DataManager.default.saveGamesService.autoSave(
      self.saveGameId,
      duration: Int64(self.state.duration.seconds)
    )
  }
  
  func toggleActivatedNumberCellNoteValues(with values: [Int], forceVisible: Bool? = nil, recordMove: Bool = false) -> Void {
    guard !self.state.isGameOver else { return }
    guard !self.state.isGamePaused else { return }
    guard let activatedNumberCell = self.activeCursorState.numberCell else {
      return
    }
    
    guard activatedNumberCell.isChangeable && activatedNumberCell.isNotable else {
      return
    }
    
    activatedNumberCell.toggleNotes(values: values, forceVisible: forceVisible)
    self.puzzle
      .toggleNotes(
        values: values,
        at: activatedNumberCell.location,
        forceAdd: forceVisible
      )
    
    try! DataManager.default.saveGamesService
      .autoSave(
        self.saveGameId,
        puzzle: self.puzzle,
        duration: Int64(self.state.duration.seconds)
      )
  }
  
  func toggleActivatedNumberCellNoteValue(with value: Int, recordMove: Bool = false) -> Void {
    guard !self.state.isGameOver else { return }
    guard !self.state.isGamePaused else { return }
    
    guard let activatedNumberCell = self.activeCursorState.numberCell else {
      return
    }

    guard activatedNumberCell.isChangeable && activatedNumberCell.isNotable else {
      return
    }

    activatedNumberCell.changeDraftNoteValue(to: value.toDouble())
    self.commitNoteChange(recordMove: recordMove)
  }
  
  func changeActivatedNumberCellDraftValue(
    cursorMode: CursorMode,
    direction: Direction
  ) -> Void {
    guard !self.state.isGameOver else {
      return
    }
    
    guard !self.state.isGamePaused else {
      return
    }
    
    guard let activatedNumberCell = self.activeCursorState.numberCell else {
      return
    }

    guard activatedNumberCell.isChangeable else { return }

    if (cursorMode == .number) {
      activatedNumberCell.changeDraftNumberValue(direction: direction)
    } else {
      activatedNumberCell.changeDraftNoteValue(direction: direction)
    }
  }
  
  func changeActivatedNumberCellValue(to value: Int, recordMove: Bool = false, automatedMove: Bool = false) -> Void {
    guard !self.state.isGameOver else {
      return
    }
    
    guard !self.state.isGamePaused else {
      return
    }
    
    guard let activatedNumberCell = self.activeCursorState.numberCell else {
      return
    }

    guard activatedNumberCell.isChangeable else { return }
    
    activatedNumberCell.changeDraftNumberValue(to: value.toDouble())
    self.commitNumberChange(recordMove: recordMove, automatedMove: automatedMove)
  }
  
  func clearActivatedNumberCellValueAndNotes(recordMove: Bool = false) -> Void {
    guard !self.state.isGameOver else {
      return
    }
    
    guard !self.state.isGamePaused else {
      return
    }
    
    guard let activatedNumberCell = self.activeCursorState.numberCell else {
      return
    }

    guard activatedNumberCell.isChangeable else { return }
    
    let encodedClearedNumber: String = CellValueNotationHelper.encodeNumber(activatedNumberCell.value)
    let encodedClearedNotes: String = CellValueNotationHelper.encodeNotes(activatedNumberCell.notes.map(\.value))
    
    let hasClearedNumber = self.clearActivatedNumberCellValue(recordMove: false)
    let hasClearedNotes = self.clearActivatedNumberCellNotes(recordMove: false)
    
    guard hasClearedNumber || hasClearedNotes else { return }
    
    // Record a move at the end, as one
    if recordMove {
      let location = activatedNumberCell.location

      self.puzzle.recordMove(
        locationNotation: location.notation,
        type: hasClearedNumber ? .removeNumber : .removeNotes,
        value: hasClearedNumber ? encodedClearedNumber : encodedClearedNotes
      )
    }
  }
  
  @discardableResult
  func clearActivatedNumberCellValue(recordMove: Bool = false) -> Bool {
    guard !self.state.isGameOver else { return false }
    guard !self.state.isGamePaused else { return false }
    
    guard let activatedNumberCell = self.activeCursorState.numberCell else {
      return false
    }

    guard activatedNumberCell.isChangeable else { return false }
    guard activatedNumberCell.value.isNotEmpty else { return false }
    
    self.changeActivatedNumberCellValue(to: 0, recordMove: recordMove, automatedMove: true)
    return true
  }
  
  @discardableResult
  func toggleNumberCellUnderCursor(mode: CursorMode, cancelled: Bool) -> Bool {
    guard !self.state.isGameOver else {
      return false
    }
    
    guard !self.state.isGamePaused else {
      return false
    }
    
    let willActivate = !self.activeCursorState.isActive
    
    let activated: Bool
    if willActivate {
      activated = self.activateNumberCell(numberCellUnderCursor, mode: mode)
    } else {
      self.deactivateNumberCell(
        cancelled: cancelled,
        recordMoveIfNotCancelled: true
      )
      activated = false
    }
    
    return activated
  }
  
  func moveCursor(to location: Location, activateCellImmediately: Bool = false) -> Void {
    self.cursorLocation = location
    self.highlightAllPeerCellsRelatedToCursor()
    
    if activateCellImmediately && !(
      self.state.isGameOver || self.state.isGamePaused
    ) {
      self.activeCursorState.numberCell = numberCellUnderCursor
    }
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
  
  func solveActivatedNumberCell() -> Void {
    guard let activatedNumberCell = self.activeCursorState.numberCell else {
      return
    }
    
    let location = activatedNumberCell.location
    let cellSolutionValue = self.puzzle.solution[location.row][location.col]
    
    self.changeActivatedNumberCellValue(to: cellSolutionValue, recordMove: true, automatedMove: true)
  }
  
  @discardableResult
  func clearActivatedNumberCellNotes(recordMove: Bool = false) -> Bool {
    guard !self.state.isGameOver else { return false }
    guard !self.state.isGamePaused else { return false }

    guard let activatedNumberCell = self.activeCursorState.numberCell else {
      return false
    }

    guard activatedNumberCell.isChangeable else { return false }
    guard !activatedNumberCell.isNotesEmpty else { return false }
    
    self.puzzle.clearNotes(at: activatedNumberCell.location)
    activatedNumberCell.clearNotes()

    // Auto-save
    try! DataManager.default.saveGamesService
      .autoSave(
        self.saveGameId,
        puzzle: self.puzzle,
        duration: Int64(self.state.duration.seconds),
        score: self.score
      )
    
    return true
  }
  
  func clearAllPeerCellsNotes(with value: Int) -> Void {
    let cursorValue = numberCellUnderCursor.value
    let cursorLocation = numberCellUnderCursor.location
    
    self.processEachPeerAndNonPeerNumberCells(
      for: (cursorValue, cursorLocation),
      allowSameValueAnywherePeers: false,
      peerFoundCallback: { (peerNumberCell, _) in
        self.puzzle
          .toggleNote(
            value: cursorValue,
            at: peerNumberCell.location,
            forceAdd: false
          )

        peerNumberCell.toggleNote(value: cursorValue, forceVisible: false)
      }
    );
  }
  
  func undoLastMove() -> Void {
    guard self.state.isPlaying else { return }
    guard self.puzzle.isMoveUndoable else { return }
    
    // Undo this move
    let currentMoveEntry = self.puzzle.currentMoveEntry
    if let currentMoveEntry {
      self.moveCursor(
        to: Location(notation: currentMoveEntry.locationNotation),
        activateCellImmediately: true
      )
      
      if currentMoveEntry.type == MoveType.setNumber {
        // Unset number
        // Lookup the history for the last move made on this location, if any
        let lastMoveOnThisCell = self.puzzle.findLastMoveMade(
          at: currentMoveEntry.locationNotation,
          before: currentMoveEntry.index
        )
        
        if let lastMoveOnThisCell {
          self.changeActivatedNumberCellValue(
            to: Int(lastMoveOnThisCell.value)!
          )

        } else {
          // No other moves made on this cell, so it must be 0 / empty
          self.changeActivatedNumberCellValue(to:  0)
        }

      } else if currentMoveEntry.type == MoveType.removeNumber {
        // Set number
        self.changeActivatedNumberCellValue(to: Int(currentMoveEntry.value)!, automatedMove: true)
        
      } else if currentMoveEntry.type == MoveType.setNote {
        // Set a note
        let noteValues = CellValueNotationHelper.decodeNotes(currentMoveEntry.value)
        self.toggleActivatedNumberCellNoteValues(
          with: noteValues
        )

      } else if currentMoveEntry.type == MoveType.removeNotes {
        // Remove notes
        let noteValues = CellValueNotationHelper.decodeNotes(currentMoveEntry.value)
        self.toggleActivatedNumberCellNoteValues(
          with: noteValues
        )
      }
    }

    self.puzzle.moveIndex -= 1
    try! DataManager.default.saveGamesService.autoSave(
      self.saveGameId,
      puzzle: self.puzzle
    )
  }
  
  func redoLastMove() -> Void {
    guard self.state.isPlaying else { return }
    guard self.puzzle.isMoveRedoable else { return }
    
    self.puzzle.moveIndex += 1
    let currentMoveEntry = self.puzzle.currentMoveEntry
    
    if let currentMoveEntry {
      self.moveCursor(
        to: Location(notation: currentMoveEntry.locationNotation),
        activateCellImmediately: true
      )
      
      if currentMoveEntry.type == MoveType.setNumber {
        // Set number
        self.changeActivatedNumberCellValue(to: Int(currentMoveEntry.value)!, automatedMove: true)
        
      } else if currentMoveEntry.type == MoveType.removeNumber {
        // Unset number
        self.changeActivatedNumberCellValue(to: 0)
        
      } else if currentMoveEntry.type == MoveType.setNote {
        // Set note
        let noteValues = CellValueNotationHelper.decodeNotes(currentMoveEntry.value)
        self.toggleActivatedNumberCellNoteValues(
          with: noteValues
        )

      } else if currentMoveEntry.type == MoveType.removeNotes {
        // Unset note
        let noteValues = CellValueNotationHelper.decodeNotes(currentMoveEntry.value)
        self.toggleActivatedNumberCellNoteValues(
          with: noteValues
        )
      }
    }
    
    try! DataManager.default.saveGamesService.autoSave(
      saveGameId,
      puzzle: self.puzzle
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
      peerFoundCallback: { (peerNumberCell, peerType) in
        if (peerType == .number ) || (peerType == .both) {
          peerNumberCell.highlight()
        } else if peerType == .note {
          // Don't highlight the entire cell, because only the note on this cell is the peer
          peerNumberCell.unhighlight()
        }

        peerNumberCell.toggleHighlighForNotes(with: cursorValue)
      },
      nonPeerFoundCallback: { nonPeerNumberCell in
        nonPeerNumberCell.unhighlight()
        nonPeerNumberCell.toggleHighlighForNotes(with: cursorValue)
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
  ///   - allowSameValueAnywherePeers: A boolean flag to allow peers that have the same value as the current cell - ignoring row or column sameness (default is `true`).
  ///   - allowNotePeers: A boolean flag to allow peers that have a note with the same value as the current cell (default is `true`)
  ///   - peerFoundCallback: A closure that gets called for each peer cell  its number cell reference object from the `numberCells` collection.
  ///   - nonPeerFoundCallback: An optional closure that gets called for each non-peer cell with its number cell object reference from the `numberCells` collection.
  ///     - If provided, it will be triggered for each non-peer cell found. If no non-peer cells are found, this callback will not be called.
  private func processEachPeerAndNonPeerNumberCells(
    for cell: (value: Int, location: Location),
    allowSelfAsPeer: Bool = true,
    allowRowPeers: Bool = true,
    allowColumnPeers: Bool = true,
    allowGridPeers: Bool = true,
    allowSameValueAnywherePeers: Bool = true,
    allowNotePeers: Bool = true,
    peerFoundCallback: (_ peerNumberCell: NumberCellSprite, _ peerType: PeerType) -> Void,
    nonPeerFoundCallback: ((_ nonPeerNumberCell: NumberCellSprite) -> Void)? = nil
  ) -> Void {
    for numberCell in self.numberCells {
      // Check note peer condition
      let hasNotePeer: Bool = if allowNotePeers && numberCell.isValueEmpty && !numberCell.isNotesEmpty {
        numberCell.notes.contains(where: { $0.value == cell.value })
      } else {
        false
      }

      let isSelf = numberCell.location == cell.location
      if isSelf {
        if allowSelfAsPeer {
          peerFoundCallback(numberCell, hasNotePeer ? .both : .number)
        } else {
          nonPeerFoundCallback?(numberCell)
        }
        continue
      }
      
      // Check row, column, and grid peer conditions
      let sameRow = allowRowPeers && numberCell.location.row == cell.location.row
      if (sameRow) {
        peerFoundCallback(numberCell, hasNotePeer ? .both : .number)
        continue
      }
      
      let sameColumn = allowColumnPeers && numberCell.location.col == cell.location.col
      if (sameColumn) {
        peerFoundCallback(numberCell, hasNotePeer ? .both : .number)
        continue
      }
      
      let sameGrid = allowGridPeers && numberCell.location.grid == cell.location.grid
      if (sameGrid) {
        peerFoundCallback(numberCell, hasNotePeer ? .both : .number)
        continue
      }
      
      // Check same value condition
      let sameValue = allowSameValueAnywherePeers && (
        !numberCell.isValueEmpty && (numberCell.value == cell.value)
      )
      if (sameValue) {
        peerFoundCallback(numberCell, hasNotePeer ? .both : .number)
        continue
      }
      
      // Only has a peer note
      if hasNotePeer && allowSameValueAnywherePeers {
        peerFoundCallback(numberCell, .note)
        continue
      }
      
      // Not a peer number cell
      nonPeerFoundCallback?(numberCell)
    }
  }
  
  private func activateNumberCell(_ numberCell: NumberCellSprite, mode: CursorMode) -> Bool {
    guard !self.state.isGameOver else {
      return false
    }
    
    guard !self.state.isGamePaused else {
      return false
    }
    
    guard !self.activeCursorState.isActive else {
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
    
    self.activeCursorState.numberCell = numberCell
    numberCell.resetValidation()
    self.cursorCell.activate(mode: mode)
    
    return true
  }
  
  private func deactivateNumberCell(
    cancelled: Bool = false,
    recordMoveIfNotCancelled: Bool = false
  ) -> Void {
    guard self.activeCursorState.isActive else {
      return
    }
    
    if (cancelled) {
      self.discardNumberChange()
    } else {
      self.commitNumberChange(recordMove: recordMoveIfNotCancelled)
    }
    
    self.activeCursorState.numberCell = nil
    self.cursorCell.deactivate()
  }
  
  private func discardNumberChange() -> Void {
    guard let activatedNumberCell = self.activeCursorState.numberCell else {
      return
    }

    // Cancel changes
    activatedNumberCell.discardDraftNumberValueChange()
    
    // Re-validate cell as it was reset during cell activation
    activatedNumberCell.toggleValidation(
      valid: activatedNumberCell.isValueEmpty || self.puzzle.validate(
        value: activatedNumberCell.value,
        at: activatedNumberCell.location
      )
    )
  }
  
  private func commitNumberChange(recordMove: Bool = false, automatedMove: Bool = false) -> Void {
    guard let activatedNumberCell = self.activeCursorState.numberCell else {
      return
    }
    
    let value = activatedNumberCell.numberValueToBeCommitted
    let location = activatedNumberCell.location
    
    // Validate comitting changes
    let validChange = self.puzzle.validate(value: value, at: location)
    let enteredSameValue = self.puzzle.isSame(value: value, at: location)
    
    activatedNumberCell.toggleValidation(valid: validChange, valueCleared: value.isEmpty)
    
    // Commit changes
    self.puzzle.updatePlayer(value: value, at: location)
    activatedNumberCell.commitValueChange()

    if value.isNotEmpty {
      // Committed a non-empty value to the cell
      // Clear any previous notes from it
      self.clearActivatedNumberCellNotes(recordMove: false)
      
      if AppConfig.shouldAutoRemoveNotes() {
        self.clearAllPeerCellsNotes(with: value)
      }
      
      if !enteredSameValue && !automatedMove {
        // Update the score if the number has been CHANGED to another valid / invalid number
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
    }

    // Record the move, if allowed
    if recordMove {
      self.puzzle.recordMove(
        locationNotation: location.notation,
        type: value.isEmpty ? .removeNumber : .setNumber,
        value: CellValueNotationHelper.encodeNumber(value)
      )
    }
    
    // Auto-save
    try! DataManager.default.saveGamesService.autoSave(
      self.saveGameId,
      puzzle: self.puzzle,
      duration: Int64(self.state.duration.seconds),
      score: self.score
    )
    
    self.highlightAllPeerCellsRelatedToCursor()

    // Check if game over now
    if self.checkGameOver() {
      self.state.endGame()
    }
  }
  
  private func commitNoteChange(recordMove: Bool = false) -> Void {
    guard let activatedNumberCell = self.activeCursorState.numberCell else {
      return
    }
    
    let value = activatedNumberCell.noteValueToBeCommitted
    let location = activatedNumberCell.location
    
    activatedNumberCell.toggleNote(value: value)
    self.puzzle.toggleNote(value: value, at: location)
    
    // Record the move, if allowed
    if recordMove {
      self.puzzle.recordMove(
        locationNotation: location.notation,
        type: value.isEmpty ? .removeNotes : .setNote,
        value: CellValueNotationHelper.encodeNumber(value)
      )
    }
    
    // Auto-save
    try! DataManager.default.saveGamesService.autoSave(
      self.saveGameId,
      puzzle: self.puzzle,
      duration: Int64(self.state.duration.seconds),
      score: self.score
    )
  }
  
  private func checkGameOver() -> Bool {
    return self.puzzle.checkGameOver()
  }
}
