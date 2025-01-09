//
//  ControlButton.swift
//  sudoku
//
//  Created by Kishan Jadav on 08/01/2025.
//

import SwiftUI
import SpriteKit
import UIKit.UIColor
import UIColorHexSwift

struct ControlButton: View {
  var title: String
  var subtitle: String?
  var imageSystemName: String?
  var onPress: () -> Void
  
  private let vibrator = UIImpactFeedbackGenerator(style: .rigid)
  
  var body: some View {
    Button(
      action: {
        self.onPress()
        vibrator.impactOccurred()
      },
      label: {
        HStack(spacing: 8) {
          if let imageSystemName = self.imageSystemName {
            Image(systemName: imageSystemName)
              .font(.system(size: 24))
          }
          
          VStack(alignment: .leading) {
            Text(title).fontWeight(.bold)
            
            if let subtitle = self.subtitle {
              Text(subtitle)
                .foregroundStyle(Color(UIColor("#5A5A5A")))
                .font(.system(size: 14, weight: .bold))
            }
          }
        }
      }
    )
    .buttonStyle(ControlButtonStyle())
  }
}

struct ControlButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(12)
      .background(Color(UIColor("#222223")))
      .foregroundStyle(.white)
      .clipShape(RoundedRectangle(cornerSize: .init(width: 12, height: 12)))
      .scaleEffect(configuration.isPressed ? 0.9 : 1)
      .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
  }
}

#Preview {
    ContentView()
}
