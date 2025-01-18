//
//  GameControlButtonStyle.swift
//  MobileApp
//
//  Created by Kishan Jadav on 17/01/2025.
//

import SwiftUI

struct GameControlButtonStyle: ButtonStyle {
  var disabled: Bool = false
  var toggled: Bool = false
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(toggled ? .accent : Color(UIColor("#141414")))
      .opacity(self.disabled ? 0.3 : 1)
      .clipShape(.capsule)
      .scaleEffect(configuration.isPressed ? 0.9 : 1)
      .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
  }
}
