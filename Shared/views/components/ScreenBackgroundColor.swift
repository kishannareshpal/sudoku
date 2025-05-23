//
//  ScreenBackgroundColor.swift
//  sudoku
//
//  Created by Kishan Jadav on 23/05/2025.
//

import SwiftUI

struct ScreenBackgroundColor: View {
  let currentColorScheme: ColorScheme
  
  var body: some View {
    Color(
      self.currentColorScheme.ui.game.control.numpad.button.selected.background
    )
    .opacity(0.1)
    .apply({ view in
      if self.currentColorScheme.mode == .dark {
        view.background(.black)
      } else {
        view.background(Color(UIColor("#EEF0F2")))
      }
    })
    .ignoresSafeArea()
  }
}
