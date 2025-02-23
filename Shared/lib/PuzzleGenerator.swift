//
//  PuzzleGenerator.swift
//  sudoku
//
//  Created by Kishan Jadav on 26/01/2025.
//

import Foundation

public class PuzzleGenerator {
  // TODO: Improve processor performance
  private let generator: QQWing;
  
  private(set) var player: BoardGridNotation = BoardNotationHelper.emptyGridNotation();
  private(set) var given: BoardGridNotation = BoardNotationHelper.emptyGridNotation();
  private(set) var solution: BoardGridNotation = BoardNotationHelper.emptyGridNotation();
  private(set) var notes: BoardGridNoteNotation = BoardNotationHelper.emptyGridNoteNotation();
  private(set) var moves: BoardGridMoveNotation = BoardNotationHelper.emptyGridMoveNotation();

  init() {
    self.generator = QQWing()
  }
  
  func generate() -> Void {
    if (!self.generator.generatePuzzle()) {
      print("TODO: Failed to generate puzzle! Do something")
    }
    
    self.given = BoardNotationHelper.toGridNotation(from: self.generator.getPuzzle())
    
    if (!self.generator.solve()) {
      print("Failed to solve! TODO: regenerate")
    }
    self.solution = BoardNotationHelper.toGridNotation(from: self.generator.getSolution())
    
    // The generator doesn't support notes generation, so we're just instatiating it as empty.
    // - In the future, you may consider implementing notes generation as there are some users who likes having them.
    self.notes = BoardNotationHelper.emptyGridNoteNotation()
  }
}
