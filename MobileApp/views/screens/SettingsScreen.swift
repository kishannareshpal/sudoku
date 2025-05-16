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
  ) private var offline: Bool = true
  
  @AppStorage(
    UserDefaultKey.useGridNumberPadStyle.rawValue
  ) private var useGridNumberPadStyle: Bool = true
  
  var body: some View {
      VStack {
        Form {
          Section {
            VStack(spacing: 8) {
              Toggle("Sync progress across your devices", isOn: Binding(
                get: { !self.offline },
                set: { self.offline = !$0 }
              ))
              Text(
                "(Experimental) When enabled, your progress will be automatically synced with your other devices so you can continue from where you left off (e.g. your Apple watch).\n\n" +
                "Please note that this feature is currently experimental and requires internet connection to work. More optimisations will be made in the upcoming app updates."
              ).font(.footnote)
            }
          }
          
          Section {
            Toggle("Start in notes mode", isOn: $startGameInNotesMode)
            
            VStack(spacing: 8) {
              Toggle("Auto remove notes", isOn: $autoRemoveNotes)
              Text(
                "Automatically remove invalid notes from all related cells once you place a number on a cell."
              ).font(.footnote)
            }
          }
          
          Section {
            Toggle("Use grid styled number pad", isOn: $useGridNumberPadStyle)
            
            Toggle("Haptic feedback", isOn: $hapticFeedbackEnabled)
            
            Toggle("Show timer", isOn: $showTimer)
            
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
