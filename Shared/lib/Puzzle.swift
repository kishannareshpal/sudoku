//
//  Puzzle.swift
//  sudoku
//
//  Created by Kishan Jadav on 07/01/2023.
//

import Foundation

public class Puzzle: ObservableObject {
  private let saveGame: SaveGameEntity
  
  private(set) var player: BoardGridNotation = BoardNotationHelper.emptyGridNotation();
  private(set) var given: BoardGridNotation = BoardNotationHelper.emptyGridNotation();
  private(set) var solution: BoardGridNotation = BoardNotationHelper.emptyGridNotation();
  private(set) var notes: BoardGridNoteNotation = BoardNotationHelper.emptyGridNoteNotation();
  
  @Published var remainingNumbersWithCount: [Int: Int] = [
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
  
  init(saveGame: SaveGameEntity) {
    self.saveGame = saveGame

    self.loadPuzzleFromSaveGame()
    self.calculateAndUpdateRemainingNumbersWithCount()
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
  
  private func loadPuzzleFromSaveGame() {
    self.given = BoardNotationHelper
      .toGridNotation(from: saveGame.givenNotation!)

    self.solution = BoardNotationHelper
      .toGridNotation(from: saveGame.solutionNotation!)

    self.player = BoardNotationHelper
      .toGridNotation(from: saveGame.playerNotation!)
    
    self.notes = BoardNotationHelper
      .toGridNoteNotation(from: saveGame.notesNotation!)
  }
  
  private func calculateAndUpdateRemainingNumbersWithCount() -> Void {
    // Reset
    self.remainingNumbersWithCount = [
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
}
