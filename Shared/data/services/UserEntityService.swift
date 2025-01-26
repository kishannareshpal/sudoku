//
//  UserEntityDataService.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

class UserEntityService {
  let repository: UserEntityRepository
  
  init(
    repository: UserEntityRepository
  ) {
    self.repository = repository
  }
}
