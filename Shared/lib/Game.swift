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
  
  private(set) var saveGameId: EntityID
  private(set) var difficulty: Difficulty
  private(set) var board: Board
  private(set) var graphics: GameGraphics
  @Published private(set) var puzzle: Puzzle
  
  private(set) var cursorCell: CursorCellSprite!
  private(set) var numberCells: Array<NumberCellSprite> = []
  
  @Published private(set) var activatedNumberCell: NumberCellSprite?
  
  @Published private(set) var isGameOver: Bool = false
  @Published private(set) var isGamePaused: Bool = false
  @Published private(set) var durationInSeconds: Int64 = 0
  @Published private(set) var score: Int64 = 0

  @Published private(set) var moveIndex: Int32 = -1
  @Published private(set) var moves: [MoveEntryEntity] = []
  
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
  
  var isMoveUndoable: Bool {
    return !self.isGameOver && !self.isGamePaused && (self.moveIndex >= 0)
  }
  
  var isMoveRedoable: Bool {
    let movesCount = self.moves.count
    
    return (!self.isGameOver && !self.isGamePaused) && (self.moveIndex < movesCount - 1)
  }
  
  init(sceneSize: CGSize) throws {
    guard let saveGame = DataManager.default.saveGamesService.findActiveLocalSaveGame() else {
      fatalError("Attempted to load a game with no active save game")
    }
    
    let puzzle = Puzzle(saveGame: saveGame)
    self.puzzle = puzzle
    self.board = Board()
    self.graphics = GameGraphics(sceneSize: sceneSize, puzzle: puzzle)

    self.saveGameId = saveGame.objectID
    self.difficulty = Difficulty(rawValue: saveGame.difficulty!)!
    self.durationInSeconds = saveGame.durationInSeconds
    self.score = saveGame.score
    self.moveIndex = saveGame.moveIndex
    self.moves = (saveGame.moves?.allObjects as? [MoveEntryEntity])?.sorted {
      $0.position > $1.position
    } ?? []
    
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
      let numberCellNoteValues = self.puzzle.notes[numberCell.location.row][numberCell.location.col]
      numberCell
        .toggleNotes(
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

    try? DataManager.default.saveGamesService.repository
      .updateDuration(for: self.saveGameId, seconds: self.durationInSeconds)
  }
  
  func toggleActivatedNumberCellNoteValues(with values: [Int], forceVisible: Bool? = nil, recordMove: Bool = false) -> Void {
    guard !self.isGameOver else { return }
    guard !self.isGamePaused else { return }
    
    guard let activatedNumberCell = self.activatedNumberCell else { return }
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
        duration: self.durationInSeconds
      )
  }
  
  func toggleActivatedNumberCellNoteValue(with value: Int, recordMove: Bool = false) -> Void {
    guard !self.isGameOver else { return }
    guard !self.isGamePaused else { return }
    
    guard let activatedNumberCell = self.activatedNumberCell else { return }
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
  
  func changeActivatedNumberCellValue(to value: Int, recordMove: Bool = false) -> Void {
    guard !self.isGameOver else {
      return
    }
    
    guard !self.isGamePaused else {
      return
    }
    
    guard let activatedNumberCell = self.activatedNumberCell else { return }
    guard activatedNumberCell.isChangeable else { return }
    
    activatedNumberCell.changeDraftNumberValue(to: value.toDouble())
    self.commitNumberChange(recordMove: recordMove)
  }
  
  func clearActivatedNumberCellValueAndNotes(recordMove: Bool = false) -> Void {
    guard !self.isGameOver else {
      return
    }
    
    guard !self.isGamePaused else {
      return
    }
    
    guard let activatedNumberCell = self.activatedNumberCell else { return }
    guard activatedNumberCell.isChangeable else { return }
    
    let encodedClearedNumber: String = CellValueNotationHelper.encodeNumber(activatedNumberCell.value)
    let encodedClearedNotes: String = CellValueNotationHelper.encodeNotes(activatedNumberCell.notes.map(\.value))
    
    let hasClearedNumber = self.clearActivatedNumberCellValue(recordMove: false)
    let hasClearedNotes = self.clearActivatedNumberCellNotes(recordMove: false)
    
    guard hasClearedNumber || hasClearedNotes else { return }
    
    // Record a move at the end, as one
    if recordMove {
      let location = activatedNumberCell.location

      self.recordMoveToHistory(
        locationNotation: location.notation,
        type: hasClearedNumber ? .clearNumber : .clearNote,
        value: hasClearedNumber ? encodedClearedNumber : encodedClearedNotes
      )
    }
  }
  
  @discardableResult
  func clearActivatedNumberCellValue(recordMove: Bool = false) -> Bool {
    guard !self.isGameOver else { return false }
    guard !self.isGamePaused else { return false }
    
    guard let activatedNumberCell = self.activatedNumberCell else { return false }
    guard activatedNumberCell.isChangeable else { return false }
    guard activatedNumberCell.value.isNotEmpty else { return false }
    
    self.changeActivatedNumberCellValue(to: 0, recordMove: recordMove)
    return true
  }
  
  @discardableResult
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
  
  func solveActivatedNumberCell() -> Void {
    guard let activatedNumberCell = self.activatedNumberCell else { return }
    
    let location = activatedNumberCell.location
    let cellSolutionValue = self.puzzle.solution[location.row][location.col]
    
    self.changeActivatedNumberCellValue(to: cellSolutionValue, recordMove: true)
  }
  
  @discardableResult
  func clearActivatedNumberCellNotes(recordMove: Bool = false) -> Bool {
    guard !self.isGameOver else { return false }
    guard !self.isGamePaused else { return false }

    guard let activatedNumberCell = self.activatedNumberCell else { return false }
    guard activatedNumberCell.isChangeable else { return false }
    guard !activatedNumberCell.isNotesEmpty else { return false }
    
    self.puzzle.clearNotes(at: activatedNumberCell.location)
    activatedNumberCell.clearNotes()

    // Auto-save
    try! DataManager.default.saveGamesService
      .autoSave(
        self.saveGameId,
        puzzle: self.puzzle,
        duration: self.durationInSeconds,
        score: self.score
      )
    
    return true
  }
  
  func clearAllPeerCellsNotes(with value: Int) -> Void {
    let cursorValue = numberCellUnderCursor.value
    let cursorLocation = numberCellUnderCursor.location
    
    self.processEachPeerAndNonPeerNumberCells(for: (cursorValue, cursorLocation)) { (peerNumberCell, _) in
      self.puzzle
        .toggleNote(
          value: cursorValue,
          at: peerNumberCell.location,
          forceAdd: false
        )

      peerNumberCell.toggleNote(value: cursorValue, forceVisible: false)
    }
  }
  
  func recordMoveToHistory(
    locationNotation: String,
    type: MoveType,
    value: String
  ) {
    // TODO: - Fix given cloud syncing changes
//    self.moveIndex += 1
//    let moveEntry = try! DataManager.default.saveGamesService.addMove(
//      self.saveGameId,
//      position: self.moveIndex,
//      locationNotation: locationNotation,
//      type: type,
//      value: value
//    )
//    
//    if let moveEntry {
//      self.moves.removeAll { entry in entry.position >= self.moveIndex }
//      self.moves.insert(moveEntry, at: 0)
//    }
  }
  
  func undoMove() -> Void {
    guard self.isMoveUndoable else { return }
    
    // Undo this move
    let move = self.moves.first(where: { $0.position == self.moveIndex })
    if let move {
      self.moveCursor(
        to: Location(notation: move.locationNotation!),
        activateCellImmediately: true
      )
      
      if move.type == MoveType.setNumber.rawValue {
        // Unset number
        // Lookup the history for the last move made on this location, if any
        let lastMoveOnThisCell = self.moves.first {
          ($0.position < move.position) && ($0.locationNotation == move.locationNotation)
        }
        
        if let lastMoveOnThisCell {
          self.changeActivatedNumberCellValue(
            to: Int(lastMoveOnThisCell.value!)!
          )
          
        } else {
          // No other moves made to this cell, so it must be 0
          self.changeActivatedNumberCellValue(to:  0)
        }
        
      } else if move.type == MoveType.removeNumber.rawValue || move.type == MoveType.clearNumber.rawValue {
        // Set number
        self.changeActivatedNumberCellValue(to: Int(move.value!)!)
        
      } else if move.type == MoveType.setNote.rawValue {
        // Unset note
        let noteValues: [Int] = move.value?.split(separator: ",").map({ Int($0)! }) ?? []
        self.toggleActivatedNumberCellNoteValues(
          with: noteValues
        )

      } else if move.type == MoveType.removeNote.rawValue || move.type == MoveType.clearNote.rawValue {
        // Set note
        let noteValues: [Int] = move.value?.split(separator: ",").map({ Int($0)! }) ?? []
        self.toggleActivatedNumberCellNoteValues(
          with: noteValues
        )
      }
    }
    
    self.moveIndex -= 1
    try! DataManager.default.saveGamesService.repository
      .update(self.saveGameId, moveIndex: self.moveIndex)
  }
  
  func redoMove() -> Void {
    guard self.isMoveRedoable else { return }
    
    self.moveIndex += 1

    let move = self.moves.first(where: { $0.position == self.moveIndex })
    if let move = move {
      self.moveCursor(
        to: Location(notation: move.locationNotation!),
        activateCellImmediately: true
      )
      
      if move.type == MoveType.setNumber.rawValue {
        // Set number
        self.changeActivatedNumberCellValue(to: Int(move.value!)!)
        
      } else if move.type == MoveType.removeNumber.rawValue || move.type == MoveType.clearNumber.rawValue {
        // Unset number
        self.changeActivatedNumberCellValue(to: 0)
        
      } else if move.type == MoveType.setNote.rawValue {
        // Set note
        let noteValues: [Int] = move.value?.split(separator: ",").map({ Int($0)! }) ?? []
        self.toggleActivatedNumberCellNoteValues(
          with: noteValues
        )

      } else if move.type == MoveType.removeNote.rawValue || move.type == MoveType.clearNote.rawValue {
        // Unset note
        let noteValues: [Int] = move.value?.split(separator: ",").map({ Int($0)! }) ?? []
        self.toggleActivatedNumberCellNoteValues(
          with: noteValues
        )
      }
    }
    
    try! DataManager.default.saveGamesService.repository
      .update(self.saveGameId, moveIndex: self.moveIndex)
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
  ///   - allowSameValuePeers: A boolean flag to allow peers that have the same value as the current cell (default is `true`).
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
    allowSameValuePeers: Bool = true,
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
      let sameValue = allowSameValuePeers && (
        !numberCell.isValueEmpty && (numberCell.value == cell.value)
      )
      if (sameValue) {
        peerFoundCallback(numberCell, hasNotePeer ? .both : .number)
        continue
      }
      
      // Only has a peer note
      if hasNotePeer {
        peerFoundCallback(numberCell, .note)
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
  
  private func deactivateNumberCell(cancelled: Bool = false, recordMoveIfNotCancelled: Bool = false) -> Void {
    guard self.isNumberCellActive else {
      return
    }
    
    if (cancelled) {
      self.discardNumberChange()
    } else {
      self.commitNumberChange(recordMove: recordMoveIfNotCancelled)
    }
    
    self.activatedNumberCell = nil
    self.cursorCell.deactivate()
  }
  
  private func discardNumberChange() -> Void {
    guard let activatedNumberCell = self.activatedNumberCell else {
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
  
  private func commitNumberChange(recordMove: Bool = false) -> Void {
    guard let activatedNumberCell = self.activatedNumberCell else {
      return
    }
    
    let value = activatedNumberCell.numberValueToBeCommitted
    let location = activatedNumberCell.location
    
    // Validate comitting changes
    let validChange = self.puzzle.validate(value: value, at: location)
    activatedNumberCell
      .toggleValidation(valid: validChange, valueCleared: value.isEmpty)
    
    // Commit changes
    self.puzzle.updatePlayer(value: value, at: location)
    activatedNumberCell.commitValueChange()

    if value.isNotEmpty {
      // Committed a non-empty value to the cell
      // Clear any previous notes from it
      self.clearActivatedNumberCellNotes(recordMove: false)
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

    // Record the move, if allowed
    if recordMove {
      self.recordMoveToHistory(
        locationNotation: location.notation,
        type: value.isEmpty ? .removeNumber : .setNumber,
        value: CellValueNotationHelper.encodeNumber(value)
      )
    }
    
    // Auto-save
    try! DataManager.default.saveGamesService.autoSave(
      self.saveGameId,
      puzzle: self.puzzle,
      duration: self.durationInSeconds,
      score: self.score
    )
    
    self.highlightAllPeerCellsRelatedToCursor()

    // Check if game over now
    self.isGameOver = self.checkGameOver()
  }
  
  private func commitNoteChange(recordMove: Bool = false) -> Void {
    guard let activatedNumberCell = self.activatedNumberCell else {
      return
    }
    
    let value = activatedNumberCell.noteValueToBeCommitted
    let location = activatedNumberCell.location
    
    activatedNumberCell.toggleNote(value: value)
    self.puzzle.toggleNote(value: value, at: location)
    
    // Record the move, if allowed
    if recordMove {
      self.recordMoveToHistory(
        locationNotation: location.notation,
        type: value.isEmpty ? .removeNote : .setNote,
        value: CellValueNotationHelper.encodeNumber(value)
      )
    }
    
    // Auto-save
    try! DataManager.default.saveGamesService.autoSave(
      self.saveGameId,
      puzzle: self.puzzle,
      duration: self.durationInSeconds,
      score: self.score
    )
  }
  
  private func checkGameOver() -> Bool {
    return self.puzzle.checkGameOver()
  }
}
