//
//  SettingsScreen.swift
//  sudoku
//
//  Created by Kishan Jadav on 04/01/2025.
//

import SwiftUI
import SpriteKit

struct SettingsScreen: View {
  @ObservedObject var styleManager: StyleManager
  
  @AppStorage(
    UserDefaultKey.offline.rawValue
  ) private var offline: Bool = true

  @AppStorage(
    UserDefaultKey.highlightOrientation.rawValue
  ) var highlightOrientation: String = LocationIndexOrientation.topToBottom.rawValue
  
  @AppStorage(
    UserDefaultKey.colorSchemeName.rawValue
  ) private var colorSchemeName: String = ColorSchemeName.darkYellow.rawValue

  var body: some View {
    List {
      Section(
        footer: Text("Choose the direction the highlight moves on clockwise crown rotation.")
          .font(.caption2)
          .foregroundStyle(.gray)
      ) {
        Picker(selection: $highlightOrientation) {
          Text("Top to bottom").tag(LocationIndexOrientation.topToBottom.rawValue)
          Text("Left to right").tag(LocationIndexOrientation.leftToRight.rawValue)
        } label: {
          HStack {
            Image(systemName: "digitalcrown.arrow.clockwise")
            Text("Highlight orientation")
          }
        }
      }
      
      Section {
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
      
      Section(
        footer: Text(
          "(Experimental) When enabled, your progress will be automatically synced with your other devices so you can continue from where you left off (e.g. your iPhone).\n\n" +
          "Please note that this feature is currently experimental and requires internet connection to work. More optimisations will be made in the upcoming app updates."
        ).font(.caption2)
          .foregroundStyle(.gray),
      ) {
        Toggle(
          "Sync progress across your devices",
          isOn: Binding(
            get: { !self.offline },
            set: { self.offline = !$0 }
          ),
        )
      }
      
      VStack(alignment: .leading) {
        Divider()
        Text("App version: \(Bundle.main.appVersionNumber)").font(.caption2)
        Text("sudoku@kishanjadav.com").font(.system(size: 11))
      }.listRowBackground(Color.clear)
      
    }
    .navigationTitle {
      HStack {
        Image(systemName: "gear")
        Text("Settings")
      }
      .foregroundStyle(
        Color(self.styleManager.colorScheme.ui.game.control.numpad.button.normal.text)
      )
    }
  }
}
