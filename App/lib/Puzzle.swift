//
//  Puzzle.swift
//  sudoku
//
//  Created by Kishan Jadav on 07/01/2023.
//

import Foundation

public class Puzzle {
  // TODO: Improve processor performance
  private let processor: QQWing;
  private let difficulty: Difficulty
  private let existingGame: SaveGameEntity?
  
  private(set) var player: BoardGridNotation = BoardNotationHelper.emptyGridNotation();
  private(set) var given: BoardGridNotation = BoardNotationHelper.emptyGridNotation();
  private(set) var solution: BoardGridNotation = BoardNotationHelper.emptyGridNotation();
  private(set) var notes: BoardGridNoteNotation = BoardNotationHelper.emptyGridNoteNotation();
  
  init(difficulty: Difficulty, existingGame: SaveGameEntity? = nil) {
    self.processor = QQWing()
    self.difficulty = difficulty
    self.existingGame = existingGame
  }
  
  func generate() -> Void {
    if (existingGame != nil) {
      generateFromExistingGame()
    } else {
      generateNewUsingProcessor()
    }
  }
  
  func updatePlayer(value: Int, at location: Location) -> Void {
    self.player[location.row][location.col] = value
  }
  
  func clearNotes(at location: Location) -> Void {
    self.notes[location.row][location.col].removeAll()
  }
  
  func updateNote(value: Int, at location: Location) -> Void {
    if let existingNoteIndex = self.notes[location.row][location.col].firstIndex(of: value) {
      self.notes[location.row][location.col].remove(at: existingNoteIndex)
    } else {
      self.notes[location.row][location.col].append(value)
    }
  }

  func validate(value: Int, at location: Location) -> Bool {
    let solutionValue =  self.solution[location.row][location.col]
    return value == solutionValue
  }
  
  private func generateFromExistingGame() {
    guard let existingGame = existingGame else {
      precondition(existingGame != nil, "No existing game to generate the puzzle from.")
      return
    }
    
    self.given = BoardNotationHelper
      .toGridNotation(from: existingGame.givenNotation!)

    self.solution = BoardNotationHelper
      .toGridNotation(from: existingGame.solutionNotation!)

    self.player = BoardNotationHelper
      .toGridNotation(from: existingGame.playerNotation!)
    
    self.notes = BoardNotationHelper
      .toGridNoteNotation(from: existingGame.notesNotation!)
  }
  
  private func generateNewUsingProcessor() {
    if (!self.processor.generatePuzzle()) {
      print("TODO: Failed to generate puzzle! Do something")
    }
    self.given = BoardNotationHelper.toGridNotation(from: self.processor.getPuzzle())
    
    if (!self.processor.solve()) {
      print("Failed to solve! TODO: regenerate")
    }
    self.solution = BoardNotationHelper.toGridNotation(from: self.processor.getSolution())
    
    // The processor doesn't support notes generation, so we're just instatiating as empty.
    // - In the future, you may consider fetching the notes generated using the processor.
    self.notes = BoardNotationHelper.emptyGridNoteNotation()
  }
}
