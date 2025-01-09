//
//  typealiases.swift
//  sudoku
//
//  Created by Kishan Jadav on 05/01/2025.
//

import Foundation

/// Typealias representing a single row in the board grid notation.
typealias BoardGridNotationRow = [Int]

/// Typealias representing a single cell in the board grid note notation row.
typealias BoardGridNoteNotationCell = [Int]

/// Typealias representing a single row in the board grid note notation.
typealias BoardGridNoteNotationRow = [BoardGridNoteNotationCell]

/// Typealias representing the entire board grid notation.
typealias BoardGridNotation = [BoardGridNotationRow]

/// Typealias representing the plain string notation of the board.
typealias BoardPlainStringNotation = String

/// Typealias representing the plain string notation for notes on the board.
typealias BoardPlainNoteStringNotation = String

/// Typealias representing the parsed notes notation on the board.
typealias BoardGridNoteNotation = [BoardGridNoteNotationRow]

/// Typealias representing the plain integer notation of the board.
/// TODO: deprecate?
typealias BoardPlainIntNotation = [Int]
