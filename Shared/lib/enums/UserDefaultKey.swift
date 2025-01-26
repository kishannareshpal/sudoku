//
//  UserDefaultKey.swift
//  sudoku
//
//  Created by Kishan Jadav on 25/01/2025.
//

enum UserDefaultKey: String {
  public var id: RawValue { rawValue }
  
  /// Stores the current session's User ID on app startup.
  case userId
}
