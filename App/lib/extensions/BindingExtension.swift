//
//  BindingExtension.swift
//  Sudoku WatchKit Extension
//
//  Created by Kishan Jadav on 14/01/2023.
//

import SwiftUI

extension Binding {
  func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
    Binding(
      get: { self.wrappedValue },
      set: { newValue in
        self.wrappedValue = newValue
        handler(newValue)
      }
    )
  }
}
