//
//  ViewExtension.swift
//  sudoku
//
//  Created by Kishan Jadav on 28/08/2024.
//

import SwiftUI

extension View {
  func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
}
