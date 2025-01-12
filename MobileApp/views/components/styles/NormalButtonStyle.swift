//
//  ButtonStyle.swift
//  sudoku
//
//  Created by Kishan Jadav on 12/01/2025.
//

import SwiftUI

struct NormalButtonStyle: ButtonStyle {
  var backgroundColor = Color(UIColor("#141414"))
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(.vertical, 18)
      .padding(.horizontal, 22)
      .background(backgroundColor)
      .foregroundStyle(.white)
      .clipShape(RoundedRectangle(cornerSize: .init(width: 12, height: 12)))
      .scaleEffect(configuration.isPressed ? 0.95 : 1)
      .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
  }
}
