//
//  CursorState.swift
//  sudoku
//
//  Created by Kishan Jadav on 02/09/2024.
//

import Foundation

class CursorState: ObservableObject {
  @Published var mode: CursorMode = .number
}
