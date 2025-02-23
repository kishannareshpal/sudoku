//
//  MoveEntry.swift
//  sudoku
//
//  Created by Kishan Jadav on 09/02/2025.
//

struct MoveEntry {
  var index: Int
  var locationNotation: String
  var type: MoveType
  var value: String
  
  func encode() -> String {
    // Set a number:
    // {locationNotation}={number}
    
    // Set a note:
    // {locationNotation}+={number}
    
    // Remove a number:
    // {locationNotation}-={number}
    
    // Remove notes:
    // {locationNotation}-=({number|multiple_numbers_separated_by_comma})
    
    let moveTypeNotationStart = MoveEntry.getMoveTypeNotationStart(for: self.type)
    let moveTypeNotationEnd = MoveEntry.getMoveTypeNotationEnd(for: self.type) ?? ""
    
    return "\(self.locationNotation)\(moveTypeNotationStart)\(self.value)\(moveTypeNotationEnd)"
  }
  
  static func determineMoveType(from entryPlainMoveStringNotation: BoardPlainMoveStringNotation) -> MoveType? {
    if (entryPlainMoveStringNotation.contains(self.getMoveTypeNotationStart(for: .removeNotes))) {
      return .removeNotes

    } else if (
      entryPlainMoveStringNotation
        .contains(self.getMoveTypeNotationStart(for: .setNote))
    ) {
      return .setNote

    } else if (
      entryPlainMoveStringNotation
        .contains(self.getMoveTypeNotationStart(for: .removeNumber))
    ) {
      return .removeNumber

    } else if (
      entryPlainMoveStringNotation
        .contains(self.getMoveTypeNotationStart(for: .setNumber))
    ) {
      return .setNumber
    }

    return nil
  }
  
  static func getMoveTypeNotationStart(for moveType: MoveType) -> String {
    switch moveType {
    case .setNumber:
      return "+="
    case .removeNumber:
      return "-="
    case .setNote:
      return "+=("
    case .removeNotes:
      return "-=("
    }
  }
  
  static func getMoveTypeNotationEnd(for moveType: MoveType) -> String? {
    switch moveType {
    case .setNote, .removeNotes:
      return ")"
    default:
      return nil
    }
  }
}
