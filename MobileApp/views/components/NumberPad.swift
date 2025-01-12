//
//  NumberPad.swift
//  sudoku
//
//  Created by Kishan Jadav on 07/01/2025.
//

import SwiftUI
import SpriteKit
import UIKit.UIColor
import UIColorHexSwift

struct NumberPad: View {
  private var onNumberKeyPress: (_ number: Int) -> Void
  private var onClearKeyPress: () -> Void
  
  private var numberKeyVibrator = UIImpactFeedbackGenerator(style: .light)
  private var clearKeyVibrator = UIImpactFeedbackGenerator(style: .medium)
  
  
  init(
    onNumberKeyPress: @escaping (_ number: Int) -> Void,
    onClearKeyPress: @escaping () -> Void
  ) {
    self.onClearKeyPress = onClearKeyPress
    self.onNumberKeyPress = onNumberKeyPress
  }
  
  var body: some View {
    VStack(spacing: 8) {
      HStack(spacing: 8) {
        ForEach(1...5, id: \.self) { number in
          Button("\(number)") {
            numberKeyVibrator.impactOccurred()
            onNumberKeyPress(number)
          }
          .buttonStyle(NumberButtonStyle())
        }
      }
      
      HStack(spacing: 8) {
        ForEach(6...9, id: \.self) { number in
          Button("\(number)") {
            numberKeyVibrator.impactOccurred()
            onNumberKeyPress(number)
          }
          .buttonStyle(NumberButtonStyle())
        }
        
        Button(
          action: {
            clearKeyVibrator.impactOccurred()
            onClearKeyPress()
          },
          label: {
            Image(systemName: "delete.left")
          }
        ).buttonStyle(NumberButtonStyle())
      }
    }
  }
}

struct NumberButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.custom(Theme.Fonts.mono, size: 22))
      .frame(width: 56, height: 56)
      .background(Color(UIColor("#141414")))
      .foregroundStyle(.white)
      .clipShape(RoundedRectangle(cornerSize: .init(width: 8, height: 8)))
      .scaleEffect(configuration.isPressed ? 0.9 : 1)
      .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
  }
}

#Preview {
  ContentView()
}
