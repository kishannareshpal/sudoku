//
//  CellValueNotationHelper.swift
//  sudoku
//
//  Created by Kishan Jadav on 19/01/2025.
//

struct CellValueNotationHelper {
  static func encodeNumber(_ number: Int) -> String {
    return number.toString()
  }
  
  static func encodeNote(_ note: Int) -> String {
    return note.toString()
  }
  
  static func encodeNotes(_ notes: [Int]) -> String {
    return notes.map { self.encodeNote($0) }
      .joined(separator: ",")
  }

  static func decodeNumber(_ encodedNumber: String) -> Int {
    return Int(encodedNumber) ?? 0
  }
  
  static func decodeNote(_ encodedNote: String) -> Int {
    return Int(encodedNote) ?? 0
  }
  
  static func decodeNotes(_ encodedNotes: String) -> [Int] {
    return encodedNotes.split(separator: ",").map { self.decodeNote(String($0)) }
  }
}
