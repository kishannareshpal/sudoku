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

struct BackButton: View {
  private let currentColorScheme: ColorScheme = StyleManager.current.colorScheme
  @Environment(\.dismiss) var dismissScreen: DismissAction

  var body: some View {
    Button(
      action: {
        self.dismissScreen()
      },
      label: {
        Image(systemName: "chevron.left")
          .font(.system(size: 24))
          .foregroundStyle(Color(currentColorScheme.ui.game.nav.text))
      }
    )
    .hoverEffect()
    .apply { view in
      if #available(iOS 17.0, *) {
        view.focusable()
      } else {
        view
      }
    }
  }
}
