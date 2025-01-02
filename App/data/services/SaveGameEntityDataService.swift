//
//  SaveGameEntityDataService.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

class SaveGameEntityDataService {
  static func hasSaveGame() -> Bool {
    return SaveGameEntityDataRepository.hasAny()
  }
  
  static func findLastGame() -> SaveGameEntity? {
    return SaveGameEntityDataRepository.findLast()
  }
  
  static func createNewSaveGame(difficulty: Difficulty, puzzle: Puzzle) -> Void {
    let serializedGivenNotation = BoardNotationHelper.toPlainStringNotation(from: puzzle.given)
    let serializedSolutionNotation = BoardNotationHelper.toPlainStringNotation(from: puzzle.solution)
    let serializedPlayerNotation = BoardNotationHelper.toPlainStringNotation(from: puzzle.player)
    let serializedNotesNotation = BoardNotationHelper.toPlainNoteStringNotation(from: puzzle.notes)
    
    SaveGameEntityDataRepository
      .new(
        difficulty: difficulty,
        givenNotation: serializedGivenNotation,
        solutionNotation: serializedSolutionNotation,
        playerNotation: serializedPlayerNotation,
        notesNotation: serializedNotesNotation
      )
    
    print("New game with difficulty '\(difficulty)' created!")
  }
  
  static func incrementSessionDuration(durationInSeconds: Int64) -> Void {
    SaveGameEntityDataRepository.incrementSessionDuration(lastSessionDurationInSeconds: durationInSeconds)
  }
  
  static func autoSave(puzzle: Puzzle) -> Void {
    let serializedPlayerNotation = BoardNotationHelper.toPlainStringNotation(from: puzzle.player)
    let serializedNotesNotation = BoardNotationHelper.toPlainNoteStringNotation(from: puzzle.notes)
        
    SaveGameEntityDataRepository.save(
      playerNotation: serializedPlayerNotation,
      notesNotation: serializedNotesNotation
    )
    print("Auto saved!")
  }
  
  static func clear() -> Void {
    SaveGameEntityDataRepository.clear()
  }
}
