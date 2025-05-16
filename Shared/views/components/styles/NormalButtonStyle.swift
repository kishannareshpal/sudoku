//
//  ButtonStyle.swift
//  sudoku
//
//  Created by Kishan Jadav on 12/01/2025.
//

import SwiftUI

struct NormalButtonStyle: ButtonStyle {
  var backgroundColor: Color = Color(UIColor("#141414"))
  var foregroundColor: Color = .white;
  var isEnabled: Bool = true
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(.vertical, 18)
      .padding(.horizontal, 22)
      .background(backgroundColor)
      .foregroundStyle(foregroundColor)
      .opacity(self.isEnabled ? 1 : 0.3)
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .scaleEffect(configuration.isPressed ? 0.95 : 1)
      .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
  }
}
