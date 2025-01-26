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
  
  static func findCurrentGame() -> SaveGameEntity? {
    return SaveGameEntityDataRepository.findCurrent()
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
  }
  
  static func updateMoveIndex(_ newPosition: Int32) -> Void {
    SaveGameEntityDataRepository.updateMoveIndex(newPosition)
  }
  
  static func updateDuration(seconds: Int64) -> Void {
    SaveGameEntityDataRepository.updateDuration(seconds: seconds)
  }
  
  static func autoSave(
    puzzle: Puzzle,
    duration: Int64? = nil,
    score: Int64? = nil
  ) -> Void {
    let serializedPlayerNotation = BoardNotationHelper.toPlainStringNotation(from: puzzle.player)
    let serializedNotesNotation = BoardNotationHelper.toPlainNoteStringNotation(from: puzzle.notes)
    
    SaveGameEntityDataRepository.save(
      playerNotation: serializedPlayerNotation,
      notesNotation: serializedNotesNotation,
      score: score,
      duration: duration
    )
    print("Auto saved!")
  }
  
  static func delete() -> Void {
    SaveGameEntityDataRepository.delete()
  }
  
  // MARK: -
  
  static func saveMove(
    position: Int32,
    locationNotation: String,
    type: MoveType,
    value: String
  ) -> MoveEntryEntity? {
    let currentSaveGame = SaveGameEntityDataRepository.findCurrent()
    guard let currentSaveGame else { return nil }
    
    MoveEntryEntityDataRepository.deleteAllEntriesAfterAndIncluding(position: position)
    SaveGameEntityDataRepository.updateMoveIndex(position)
    let moveEntry = MoveEntryEntityDataRepository.create(
      position: position,
      locationNotation: locationNotation,
      type: type,
      value: value
    )
    currentSaveGame.addToMoves(moveEntry!)
    return moveEntry

  }
}
