//
//  LocationTest.swift
//  sudoku
//
//  Created by Kishan Jadav on 24/08/2024.
//

import Testing
@testable import WatchApp

@Suite("Location")
struct LocationTests {
  @Test("#init(row:, col:)")
  func initUsingRowCol() {
    let subject = Location(row: 2, col: 4)
    
    // 0 1 2 3 4 5 6 …
    // 1 . . . . . . …
    // 2 . . . x . . …
    // 3 . . . . . . …
    // 4 . . . . . . …
    // …
    
    #expect(subject.row == 2)
    #expect(subject.col == 4)
    
    #expect(subject.indexOrientation == .topToBottom)
    #expect(subject.index == 38)
  }
  
  @Test("#init(index:, orientation:) with orientation .topToBottom")
  func initUsingIndexWithtopToBottomOrientation() {
    let subject = Location(index: 11, orientation: .topToBottom)
    
    #expect(subject.row == 2)
    #expect(subject.col == 1)
    
    #expect(subject.indexOrientation == .topToBottom)
    #expect(subject.index == 11)
  }
  
  @Test("#init(index:, orientation:) with orientation .LeftToRight")
  func initUsingIndexWithLeftToRightOrientation() {
    let subject = Location(index: 11, orientation: .leftToRight)
    
    #expect(subject.row == 1)
    #expect(subject.col == 2)

    #expect(subject.indexOrientation == .leftToRight)
    #expect(subject.index == 11)
  }
  
  @Suite("#moveToNextIndex(wrap:)", .serialized)
  struct MoveToNextIndex {
    @Suite("when the index orientation is set as .topToBottom")
    struct TopToBottomIndexOrientation {
      @Test("correctly moves the location to the next index")
      func moves() {
        var subject = Location(index: 6, orientation: .topToBottom)

        #expect(subject.index == 6)
        #expect(subject.row == 6 && subject.col == 0)
        
        subject.moveToNextIndex()
        #expect(subject.index == 7)
        #expect(subject.row == 7 && subject.col == 0)
        
        subject.moveToNextIndex()
        #expect(subject.index == 8)
        #expect(subject.row == 8 && subject.col == 0)

        subject.moveToNextIndex()
        #expect(subject.index == 9)
        #expect(subject.row == 0 && subject.col == 1)
        
        subject.moveToNextIndex()
        #expect(subject.index == 10)
        #expect(subject.row == 1 && subject.col == 1)
      }
      
      @Test("with wrap enabled, when already at the last column and row, it continues back from the first column and row")
      func wrapsAround() {
        var subject = Location(row: 8, col: 8, orientation: .topToBottom)
        
        #expect(subject.index == 80)
        
        subject.moveToNextIndex(wrap: true)
        #expect(subject.index == 0)
        #expect(subject.col == 0 && subject.row == 0)
        
        subject.moveToNextIndex(wrap: true)
        #expect(subject.index == 1)
        #expect(subject.col == 0 && subject.row == 1)
      }
      
      @Test("with wrap disabled, when already at the last column and row, it stays at the last column and row")
      func doesNotWrapAround() {
        var subject = Location(row: 8, col: 8, orientation: .topToBottom)
        
        #expect(subject.index == 80)
        
        subject.moveToNextIndex(wrap: false)
        #expect(subject.index == 80)
        #expect(subject.col == 8 && subject.row == 8)
        
        subject.moveToNextIndex(wrap: false)
        #expect(subject.index == 80)
        #expect(subject.col == 8 && subject.row == 8)
      }
    }
    
    @Suite("when the index orientation is set as .LeftToRight")
    struct LeftToRightIndexOrientation {
      @Test("correctly moves the location to the next index")
      func moves() {
        var subject = Location(index: 6, orientation: .leftToRight)
        
        // Initially the index will be 0
        #expect(subject.index == 6)
        #expect(subject.row == 0 && subject.col == 6)
        
        subject.moveToNextIndex()
        #expect(subject.index == 7)
        #expect(subject.row == 0 && subject.col == 7)
        
        subject.moveToNextIndex()
        #expect(subject.index == 8)
        #expect(subject.row == 0 && subject.col == 8)
        
        subject.moveToNextIndex()
        #expect(subject.index == 9)
        #expect(subject.row == 1 && subject.col == 0)
        
        subject.moveToNextIndex()
        #expect(subject.index == 10)
        #expect(subject.row == 1 && subject.col == 1)
      }
      
      @Test("with wrap enabled, when already at the last column and row, it continues back from the first column and row")
      func wrapsAround() {
        var subject = Location(row: 8, col: 8, orientation: .leftToRight)
        
        #expect(subject.index == 80)
        #expect(subject.row == 8 && subject.col == 8)
        
        subject.moveToNextIndex(wrap: true)
        #expect(subject.index == 0)
        #expect(subject.row == 0 && subject.col == 0)
        
        subject.moveToNextIndex(wrap: true)
        #expect(subject.index == 1)
        #expect(subject.row == 0 && subject.col == 1)
      }
      
      @Test("with wrap disabled, when already at the last column and row, it stays at the last column and row")
      func doesNotWrap() {
        var subject = Location(row: 8, col: 8, orientation: .leftToRight)
        
        #expect(subject.index == 80)
        
        subject.moveToNextIndex(wrap: false)
        #expect(subject.index == 80)
        #expect(subject.row == 8 && subject.col == 8)
        
        subject.moveToNextIndex(wrap: false)
        #expect(subject.index == 80)
        #expect(subject.row == 8 && subject.col == 8)
      }
    }
  }
  
  @Suite("#moveToPreviousIndex(wrap:)")
  struct MoveToPreviousIndex {
    @Suite("when the index orientation is set as .topToBottom")
    struct TopToBottomIndexOrientation {
      @Test("correctly moves the location to the previous index")
      func moves() {
        var subject = Location(index: 10, orientation: .topToBottom)
        
        // Initially the index will be 0
        #expect(subject.index == 10)
        #expect(subject.row == 1 && subject.col == 1)
        
        subject.moveToPreviousIndex()
        #expect(subject.index == 9)
        #expect(subject.row == 0 && subject.col == 1)
        
        subject.moveToPreviousIndex()
        #expect(subject.index == 8)
        #expect(subject.row == 8 && subject.col == 0)
        
        subject.moveToPreviousIndex()
        #expect(subject.index == 7)
        #expect(subject.row == 7 && subject.col == 0)
        
        subject.moveToPreviousIndex()
        #expect(subject.index == 6)
        #expect(subject.row == 6 && subject.col == 0)
      }
      
      @Test("with wrap enabled, when already at the first column and row, it continues from the last column and row")
      func wrapsAround() {
        var subject = Location(index: 0, orientation: .topToBottom)
        
        #expect(subject.index == 0)
        #expect(subject.col == 0 && subject.row == 0)
        
        subject.moveToPreviousIndex(wrap: true)
        #expect(subject.index == 80)
        #expect(subject.col == 8 && subject.row == 8)
        
        subject.moveToPreviousIndex(wrap: true)
        #expect(subject.index == 79)
        #expect(subject.col == 8 && subject.row == 7)
      }
      
      @Test("with wrap disabled, when already at the last column and row, it stays at the last column and row")
      func doesNotWrapAround() {
        var subject = Location(index: 0, orientation: .topToBottom)
        
        #expect(subject.index == 0)
        #expect(subject.col == 0 && subject.row == 0)
        
        subject.moveToPreviousIndex(wrap: false)
        #expect(subject.index == 0)
        #expect(subject.col == 0 && subject.row == 0)
        
        subject.moveToPreviousIndex(wrap: false)
        #expect(subject.index == 0)
        #expect(subject.col == 0 && subject.row == 0)
      }
    }
    
    @Suite("when the index orientation is set as .LeftToRight")
    struct LeftToRightIndexOrientation {
      @Test("correctly moves the location to the previous index")
      func moves() {
        var subject = Location(index: 10, orientation: .leftToRight)
        
        // Initially the index will be 0
        #expect(subject.index == 10)
        #expect(subject.row == 1 && subject.col == 1)
        
        subject.moveToPreviousIndex()
        #expect(subject.index == 9)
        #expect(subject.row == 1 && subject.col == 0)
        
        subject.moveToPreviousIndex()
        #expect(subject.index == 8)
        #expect(subject.row == 0 && subject.col == 8)
        
        subject.moveToPreviousIndex()
        #expect(subject.index == 7)
        #expect(subject.row == 0 && subject.col == 7)
        
        subject.moveToPreviousIndex()
        #expect(subject.index == 6)
        #expect(subject.row == 0 && subject.col == 6)
      }
      
      @Test("with wrap enabled, when already at the first column and row, it continues from the last column and row")
      func wrapsAround() {
        var subject = Location(index: 0, orientation: .leftToRight)
        
        #expect(subject.index == 0)
        #expect(subject.col == 0 && subject.row == 0)
        
        subject.moveToPreviousIndex(wrap: true)
        #expect(subject.index == 80)
        #expect(subject.col == 8 && subject.row == 8)
        
        subject.moveToPreviousIndex(wrap: true)
        #expect(subject.index == 79)
        #expect(subject.col == 7 && subject.row == 8)
      }

      @Test("with wrap disabled, when already at the last column and row, it stays at the last column and row")
      func doesNotWrapAround() {
        var subject = Location(index: 0, orientation: .topToBottom)
        
        #expect(subject.index == 0)
        #expect(subject.col == 0 && subject.row == 0)
        
        subject.moveToPreviousIndex(wrap: false)
        #expect(subject.index == 0)
        #expect(subject.col == 0 && subject.row == 0)
        
        subject.moveToPreviousIndex(wrap: false)
        #expect(subject.index == 0)
        #expect(subject.col == 0 && subject.row == 0)
      }
    }
  }
  
  @Suite("Location.indexFrom(col:, row:, for orientation:)")
  struct IndexFrom {
    @Suite("when orientation is .topToBottom")
    struct TopToBottomOrientation {
      @Test("returns the correct index", arguments: [
        ["col": 0, "row": 0, "expectedIndex": 0],
        ["col": 0, "row": 1, "expectedIndex": 1],
        ["col": 0, "row": 2, "expectedIndex": 2],
        ["col": 0, "row": 3, "expectedIndex": 3],
        ["col": 0, "row": 8, "expectedIndex": 8],
        ["col": 1, "row": 0, "expectedIndex": 9],
        ["col": 1, "row": 1, "expectedIndex": 10],
        ["col": 1, "row": 2, "expectedIndex": 11],
      ])
      func indexFrom(args: Dictionary<String, Int>) async throws {
        let subject = Location.indexFrom(
          col: args["col"]!,
          row: args["row"]!,
          for: .topToBottom
        )
        #expect(subject == args["expectedIndex"]!)
      }
    }
    
    @Suite("when orientation is .LeftToRight")
    struct LeftToRightOrientation {
      @Test("returns the correct index", arguments: [
        ["col": 0, "row": 0, "expectedIndex": 0],
        ["col": 1, "row": 0, "expectedIndex": 1],
        ["col": 2, "row": 0, "expectedIndex": 2],
        ["col": 3, "row": 0, "expectedIndex": 3],
        ["col": 8, "row": 0, "expectedIndex": 8],
        ["col": 0, "row": 1, "expectedIndex": 9],
        ["col": 1, "row": 1, "expectedIndex": 10],
        ["col": 2, "row": 1, "expectedIndex": 11],
      ])
      func indexFrom(args: Dictionary<String, Int>) async throws {
        let subject = Location.indexFrom(
          col: args["col"]!,
          row: args["row"]!,
          for: .leftToRight
        )
        #expect(subject == args["expectedIndex"]!)
      }
    }
  }
  
  @Suite("Location.colFrom(index:, for orientation:)")
  struct ColFrom {
    @Suite("when orientation is .topToBottom")
    struct TopToBottomOrientation {
      @Test("returns the correct column for index", arguments: [
        ["index": 0, "expectedCol": 0],
        ["index": 1, "expectedCol": 0],
        ["index": 2, "expectedCol": 0],
        ["index": 7, "expectedCol": 0],
        ["index": 8, "expectedCol": 0],
        ["index": 9, "expectedCol": 1],
        ["index": 12, "expectedCol": 1],
        ["index": 14, "expectedCol": 1],
        ["index": 17, "expectedCol": 1],
        ["index": 18, "expectedCol": 2],
        ["index": 80, "expectedCol": 8],
      ])
      func colFrom(args: Dictionary<String, Int>) async throws {
        let subject = Location.colFrom(
          index: args["index"]!,
          for: .topToBottom
        )
        #expect(subject == args["expectedCol"]!)
      }
    }
    
    @Suite("when orientation is .LeftToRight")
    struct LeftToRightOrientation {
      @Test("returns the correct column for index", arguments: [
        ["index": 0, "expectedCol": 0],
        ["index": 1, "expectedCol": 1],
        ["index": 2, "expectedCol": 2],
        ["index": 7, "expectedCol": 7],
        ["index": 8, "expectedCol": 8],
        ["index": 9, "expectedCol": 0],
        ["index": 12, "expectedCol": 3],
        ["index": 14, "expectedCol": 5],
        ["index": 17, "expectedCol": 8],
        ["index": 18, "expectedCol": 0],
        ["index": 80, "expectedCol": 8],
      ])
      func colFrom(args: Dictionary<String, Int>) async throws {
        let subject = Location.colFrom(
          index: args["index"]!,
          for: .leftToRight
        )
        #expect(subject == args["expectedCol"]!)
      }
    }
  }

  @Suite("Location.rowFrom(index:, for orientation:)")
  struct RowFrom {
    @Suite("when orientation is .topToBottom")
    struct TopToBottomOrientation {
      @Test("returns the correct row for index", arguments: [
        ["index": 0, "expectedRow": 0],
        ["index": 1, "expectedRow": 1],
        ["index": 2, "expectedRow": 2],
        ["index": 7, "expectedRow": 7],
        ["index": 8, "expectedRow": 8],
        ["index": 9, "expectedRow": 0],
        ["index": 12, "expectedRow": 3],
        ["index": 14, "expectedRow": 5],
        ["index": 17, "expectedRow": 8],
        ["index": 18, "expectedRow": 0],
        ["index": 80, "expectedRow": 8],
      ])
      func rowFrom(args: Dictionary<String, Int>) async throws {
        let subject = Location.rowFrom(
          index: args["index"]!,
          for: .topToBottom
        )
        #expect(subject == args["expectedRow"]!)
      }
    }
    
    @Suite("when orientation is .LeftToRight")
    struct LeftToRightOrientation {
      @Test("returns the correct row for index", arguments: [
        ["index": 0, "expectedRow": 0],
        ["index": 1, "expectedRow": 0],
        ["index": 2, "expectedRow": 0],
        ["index": 7, "expectedRow": 0],
        ["index": 8, "expectedRow": 0],
        ["index": 9, "expectedRow": 1],
        ["index": 12, "expectedRow": 1],
        ["index": 14, "expectedRow": 1],
        ["index": 17, "expectedRow": 1],
        ["index": 18, "expectedRow": 2],
        ["index": 80, "expectedRow": 8],
      ])
      func rowFrom(args: Dictionary<String, Int>) async throws {
        let subject = Location.rowFrom(
          index: args["index"]!,
          for: .leftToRight
        )
        #expect(subject == args["expectedRow"]!)
      }
    }
  }
}
