//
//  SettingsScreen.swift
//  sudoku
//
//  Created by Kishan Jadav on 28/01/2025.
//

import SwiftUI
import SpriteKit
import UIKit.UIColor
import UIColorHexSwift

struct SettingsScreen: View {
  @ObservedObject var tm: StyleManager = StyleManager.current
  
  @AppStorage(
    UserDefaultKey.hapticFeedbackEnabled.rawValue
  ) private var hapticFeedbackEnabled: Bool = true

  @AppStorage(
    UserDefaultKey.startGameInNotesMode.rawValue
  ) private var startGameInNotesMode: Bool = true
  
  @AppStorage(
    UserDefaultKey.autoRemoveNotes.rawValue
  ) private var autoRemoveNotes: Bool = true
  
  @AppStorage(
    UserDefaultKey.showTimer.rawValue
  ) private var showTimer: Bool = true
  
  @AppStorage(
    UserDefaultKey.colorSchemeName.rawValue
  ) private var colorSchemeName: String = ColorSchemeName.lightBlue.rawValue
  
  @AppStorage(
    UserDefaultKey.offline.rawValue
  ) private var offline: Bool = false
  
  @AppStorage(
    UserDefaultKey.useGridNumberPadStyle.rawValue
  ) private var useGridNumberPadStyle: Bool = false
  
  var body: some View {
    ZStack {
      Color(UIColor("#100D01"))
        .ignoresSafeArea()
      
      Form {
        Section("Gameplay") {
          Toggle("Offline", isOn: $offline)
          Toggle("Haptic feedback", isOn: $hapticFeedbackEnabled)
          Toggle("Start in notes mode", isOn: $startGameInNotesMode)
          Toggle("Auto remove notes", isOn: $autoRemoveNotes)
          Toggle("Show timer", isOn: $showTimer)
          Toggle("Use grid styled number pad", isOn: $useGridNumberPadStyle)
          
          Picker("Theme", selection: $colorSchemeName) {
            ForEach(ColorSchemeName.allCases, id: \.self) { name in
              Text(name.rawValue).tag(name.rawValue)
            }
          }
          .onChange(of: self.colorSchemeName) { newColorSchemeName in
            StyleManager.current
              .switchColorScheme(
                to: ColorSchemeName(rawValue: newColorSchemeName) ?? .darkYellow
              )
          }
        }
      }
    }
  }
}
