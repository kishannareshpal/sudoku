//
//  BoardNotationTest.swift
//  sudoku
//
//  Created by Kishan Jadav on 22/09/2024.
//

import Testing
@testable import App

@Suite("BoardNotationHelper")
struct BoardNotationHelperTest {
  @Test(".emptyPlainNoteStringNotation")
  func emptyPlainNoteStringNotation() {
    let subject = BoardNotationHelper.emptyPlainNoteStringNotation()
    
    // Is a string with "," comprising of 81 cells
    #expect(subject.split(separator: ",", omittingEmptySubsequences: false).count == 81)
    
    // Is a string comprising of 80 commas and no values in between
    #expect(subject == ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,")
  }
  
  @Test(".emptyGridNoteNotation")
  func emptyGridNoteNotation() {
    let subject = BoardNotationHelper.emptyGridNoteNotation()
    
    // Has 9 arrays representing each "row"
    #expect(subject.count == 9)
    
    // Each "row" also has 9 arrays representing each cell
    #expect(subject.allSatisfy({ row in
      row.count == 9
    }))
    
    // Each "cell" contains up to 9 notes
    #expect(subject.allSatisfy({ row in
      row.allSatisfy { cellNotes in
        let containsUpToNineNotes = cellNotes.count <= 9
        return containsUpToNineNotes
      }
    }))
  }
  
  @Test(".toGridNoteNotation")
  func toGridNoteNotation() {
    let plainNoteStringNotation = BoardNotationHelper.emptyPlainNoteStringNotation()
    let subject = BoardNotationHelper.toGridNoteNotation(from: plainNoteStringNotation)
    
    // Has 9 arrays representing each "row"
    #expect(subject.count == 9)
    
    // Each "row" also has 9 arrays representing each cell
    #expect(subject.allSatisfy({ row in
      row.count == 9
    }))
    
    // Each "cell" contains up to 9 notes
    #expect(subject.allSatisfy({ row in
      row.allSatisfy { cellNotes in
        let containsUpToNineNotes = cellNotes.count <= 9
        return containsUpToNineNotes
      }
    }))
  }
  
  @Test(".toPlainNoteStringNotation")
  func toPlainNoteStringNotation() {
    let plainNoteStringNotation = BoardNotationHelper.emptyPlainNoteStringNotation()
    let subject = BoardNotationHelper.toGridNoteNotation(from: plainNoteStringNotation)
    
    // Has 9 arrays representing each "row"
    #expect(subject.count == 9)
    
    // Each "row" also has 9 arrays representing each cell
    #expect(subject.allSatisfy({ row in
      row.count == 9
    }))
    
    // Each "cell" contains up to 9 notes
    #expect(subject.allSatisfy({ row in
      row.allSatisfy { cellNotes in
        let containsUpToNineNotes = cellNotes.count <= 9
        return containsUpToNineNotes
      }
    }))
  }
}
