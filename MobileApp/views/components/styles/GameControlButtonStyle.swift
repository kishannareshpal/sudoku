//
//  GameControlButtonStyle.swift
//  MobileApp
//
//  Created by Kishan Jadav on 17/01/2025.
//

import SwiftUI

struct GameControlButtonStyle: ButtonStyle {
  var isChecked: Bool = false
  var isEnabled: Bool = false
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(self.isChecked ? .accent : Color(UIColor("#141414")))
      .opacity(self.isEnabled ? 1 : 0.3)
      .clipShape(.capsule)
      .scaleEffect(configuration.isPressed ? 0.9 : 1)
      .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
      .hoverEffect()
      .apply { view in
        if #available(iOS 17.0, *) {
          view
            .hoverEffectDisabled(!self.isEnabled)
        } else {
          view
        }
      }
  }
}
