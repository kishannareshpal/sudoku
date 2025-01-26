//
//  MoveEntryEntityDataService.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

class MoveEntryEntityService {
  let repository: MoveEntryEntityRepository
  
  init(
    repository: MoveEntryEntityRepository
  ) {
    self.repository = repository
  }
}
