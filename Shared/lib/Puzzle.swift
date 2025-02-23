//
//  Puzzle.swift
//  sudoku
//
//  Created by Kishan Jadav on 07/01/2023.
//

import Foundation

typealias RemainingNumbersWithCount = [Int: Int]

public class Puzzle: ObservableObject {
  private(set) var player: BoardGridNotation = BoardNotationHelper.emptyGridNotation();
  private(set) var given: BoardGridNotation = BoardNotationHelper.emptyGridNotation();
  private(set) var solution: BoardGridNotation = BoardNotationHelper.emptyGridNotation();
  @Published private(set) var notes: BoardGridNoteNotation = BoardNotationHelper.emptyGridNoteNotation();
  private(set) var moves: BoardGridMoveNotation = BoardNotationHelper.emptyGridMoveNotation()
  
  @Published var moveIndex: Int = -1
  @Published var remainingNumbersWithCount: RemainingNumbersWithCount = Puzzle.emptyRemainingNumbersWithCount()
  
  /// Initialize an empty puzzle
  init() {}
  
  init(
    givenNotation: BoardPlainStringNotation,
    solutionNotation: BoardPlainStringNotation,
    playerNotation: BoardPlainStringNotation,
    notesNotation: BoardPlainNoteStringNotation,
    movesNotation: BoardPlainMoveStringNotation,
    moveIndex: Int
  ) {
    self.loadPuzzle(
      givenNotation: givenNotation,
      solutionNotation: solutionNotation,
      playerNotation: playerNotation,
      notesNotation: notesNotation,
      movesNotation: movesNotation,
      moveIndex: moveIndex
    )
    
    self.calculateAndUpdateRemainingNumbersWithCount()
  }
  
  init(saveGameStruct: SaveGame) {
    self.loadPuzzle(
      givenNotation: saveGameStruct.givenNotation,
      solutionNotation: saveGameStruct.solutionNotation,
      playerNotation: saveGameStruct.playerNotation,
      notesNotation: saveGameStruct.notesNotation,
      movesNotation: saveGameStruct.movesNotation,
      moveIndex: Int(saveGameStruct.moveIndex)
    )
    
    self.calculateAndUpdateRemainingNumbersWithCount()
  }
  
  init(saveGame: SaveGameEntity) {
    self.loadPuzzle(
      givenNotation: saveGame.givenNotation,
      solutionNotation: saveGame.solutionNotation,
      playerNotation: saveGame.playerNotation,
      notesNotation: saveGame.notesNotation,
      movesNotation: saveGame.movesNotation,
      moveIndex: Int(saveGame.moveIndex)
    )

    self.calculateAndUpdateRemainingNumbersWithCount()
  }
  
  var currentMoveEntry: MoveEntry? {
    self.moves.first { $0.index == self.moveIndex }
  }
  
  var isMoveUndoable: Bool {
    self.moveIndex >= 0
  }
  
  var isMoveRedoable: Bool {
    self.moveIndex < self.moves.count - 1
  }
  
  func updatePlayer(value: Int, at location: Location) -> Void {
    self.player[location.row][location.col] = value
    self.calculateAndUpdateRemainingNumbersWithCount()
  }
  
  func clearNotes(at location: Location) -> Void {
    self.notes[location.row][location.col].removeAll()
  }
  
  func toggleNotes(values: [Int], at location: Location, forceAdd: Bool? = nil) -> Void {
    values.forEach { value in
      self.toggleNote(value: value, at: location, forceAdd: forceAdd)
    }
    
  }
  
  func toggleNote(value: Int, at location: Location, forceAdd: Bool? = nil) -> Void {
    if let existingNoteIndex = self.notes[location.row][location.col].firstIndex(of: value) {
      // A note with this value already exists at this location

      if (forceAdd == true) {
        return;
      }
      
      self.notes[location.row][location.col].remove(at: existingNoteIndex)
    } else {
      // A note with this value does not exist at this location
      
      if (forceAdd == false) {
        return;
      }

      self.notes[location.row][location.col].append(value)
    }
  }
  
  func isNoteToggled(value: Int, at location: Location) -> Bool {
    return self.notes[location.row][location.col].contains(value)
  }

  /// Returns whether or not a value at a given location is correct for the current puzzle
  func validate(value: Int, at location: Location) -> Bool {
    let solutionValue = self.solution[location.row][location.col]
    return value == solutionValue
  }
  
  func checkGameOver() -> Bool {
    return self.player.enumerated().allSatisfy { (rowIndex, row) in
      return row.enumerated().allSatisfy { (colIndex, playerValue) in
        // Player input array will have a default valu of 0 on given cells
        // so we need to replace those on this check.
        let givenValue = self.given[rowIndex][colIndex]
        let value = givenValue.isEmpty ? playerValue : givenValue
        
        return self.solution[rowIndex][colIndex] == value
      }
    }
  }
  
  func recordMove(
    locationNotation: String,
    type: MoveType,
    value: String
  ) {
    self.moveIndex += 1

    let entry = MoveEntry(
      index: self.moveIndex,
      locationNotation: locationNotation,
      type: type,
      value: value
    )

    self.moves.removeAll { entry in entry.index >= self.moveIndex }
    self.moves.append(entry)
  }
  
  func findLastMoveMade(
    at locationNotation: String,
    before index: Int
  ) -> MoveEntry? {
    return self.moves.first {
      ($0.index < index) && ($0.locationNotation == locationNotation)
    }
  }
  
  private func loadPuzzle(
    givenNotation: BoardPlainStringNotation? = nil,
    solutionNotation: BoardPlainStringNotation? = nil,
    playerNotation: BoardPlainStringNotation? = nil,
    notesNotation: BoardPlainNoteStringNotation? = nil,
    movesNotation: BoardPlainMoveStringNotation? = nil,
    moveIndex: Int? = nil
  ) {
    if let givenNotation {
      self.given = BoardNotationHelper.toGridNotation(from: givenNotation)
    }
    
    if let solutionNotation {
      self.solution = BoardNotationHelper.toGridNotation(from: solutionNotation)
    }
    
    if let playerNotation {
      self.player = BoardNotationHelper .toGridNotation(from: playerNotation)
    }
    
    if let notesNotation {
      self.notes = BoardNotationHelper.toGridNoteNotation(from: notesNotation)
    }
    
    if let movesNotation {
      self.moves = BoardNotationHelper.toGridMoveNotation(from: movesNotation)
      print("Moves notation set to: \(movesNotation)")
      print("Added moves: \(moves.count)")
    }
    
    if let moveIndex {
      self.moveIndex = moveIndex
    }
  }
  
  private func calculateAndUpdateRemainingNumbersWithCount() -> Void {
    // Reset
    self.remainingNumbersWithCount = Puzzle.emptyRemainingNumbersWithCount()
    
    self.player.enumerated().forEach { (rowIndex, row) in
      return row.enumerated().forEach { (colIndex, playerValue) in
        // Player input array will have a default valu of 0 on given cells
        // so we need to replace those on this check.
        let givenValue = self.given[rowIndex][colIndex]
        let value = givenValue.isEmpty ? playerValue : givenValue
        
        let valid = self.solution[rowIndex][colIndex] == value
        if valid, let count = self.remainingNumbersWithCount[value] {
          self.remainingNumbersWithCount[value] = count - 1
        }
      }
    }
  }
  
  static func emptyRemainingNumbersWithCount() -> RemainingNumbersWithCount {
    return [
      1: 9,
      2: 9,
      3: 9,
      4: 9,
      5: 9,
      6: 9,
      7: 9,
      8: 9,
      9: 9,
    ]
  }
}
