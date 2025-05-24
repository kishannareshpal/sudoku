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
  @ObservedObject var styleManager: StyleManager

  @AppStorage(
    UserDefaultKey.startGameInNotesMode.rawValue
  ) private var startGameInNotesMode: Bool = false
  
  @AppStorage(
    UserDefaultKey.autoRemoveNotes.rawValue
  ) private var autoRemoveNotes: Bool = true
  
  @AppStorage(
    UserDefaultKey.showTimer.rawValue
  ) private var showTimer: Bool = true
  
  @AppStorage(
    UserDefaultKey.colorSchemeName.rawValue
  ) private var colorSchemeName: String = ColorSchemeName.darkYellow.rawValue
  
  @AppStorage(
    UserDefaultKey.offline.rawValue
  ) private var offline: Bool = true
  
  @AppStorage(
    UserDefaultKey.useGridNumberPadStyle.rawValue
  ) private var useGridNumberPadStyle: Bool = true
  
  var body: some View {
    ZStack {
      ScreenBackgroundColor(
        currentColorScheme: self.styleManager.colorScheme
      )
      
      VStack {
        Form {
          Section(
            header: Text("General")
          ) {
            VStack(alignment: .leading, spacing: 8) {
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
          .listRowBackground(
            Color(
              self.styleManager.colorScheme.mode == .dark ? (
                self.styleManager.colorScheme.ui.game.control.numpad.button.normal.background
              ) : (
                self.styleManager.colorScheme.ui.game.control.numpad.button.normal.text
              )
            )
          )
          .foregroundStyle(
            Color(
              self.styleManager.colorScheme.mode == .dark ? (
                self.styleManager.colorScheme.ui.game.control.numpad.button.normal.text
              ) : (
                self.styleManager.colorScheme.ui.game.control.numpad.button.normal.background
              )
            )
          )
          
          Section(
            header: Text("Gameplay")
          ) {
            Toggle("Show timer", isOn: $showTimer)
            
            Toggle("Start in notes mode", isOn: $startGameInNotesMode)
            
            VStack(alignment: .leading, spacing: 8) {
              Toggle("Auto remove notes", isOn: $autoRemoveNotes)
              Text(
                "Automatically remove invalid notes from all related cells once you place a number."
              )
              .font(.footnote)
            }
          }
          .listRowBackground(
            Color(
              self.styleManager.colorScheme.mode == .dark ? (
                self.styleManager.colorScheme.ui.game.control.numpad.button.normal.background
              ) : (
                self.styleManager.colorScheme.ui.game.control.numpad.button.normal.text
              )
            )
          )
          .foregroundStyle(
            Color(
              self.styleManager.colorScheme.mode == .dark ? (
                self.styleManager.colorScheme.ui.game.control.numpad.button.normal.text
              ) : (
                self.styleManager.colorScheme.ui.game.control.numpad.button.normal.background
              )
            )
          )
          
          Section {
            VStack(alignment: .leading, spacing: 8) {
              HStack {
                Text("Number pad style")
                Spacer()
                Picker("Number pad style", selection: Binding(
                  get: { useGridNumberPadStyle ? "3x3" : "5x2" },
                  set: { newValue in
                    useGridNumberPadStyle = (newValue == "3x3")
                  }
                )) {
                  Text("3x3").tag("3x3")
                  Text("5x2").tag("5x2")
                }
                .pickerStyle(SegmentedPickerStyle())
                .scaledToFit()
                .frame(minWidth: 0)
              }

              Text(
                "Tip: Prefer 5x2 on devices with smaller screens."
              ).font(.footnote)
            }
          }
          .listRowBackground(
            Color(
              self.styleManager.colorScheme.mode == .dark ? (
                self.styleManager.colorScheme.ui.game.control.numpad.button.normal.background
              ) : (
                self.styleManager.colorScheme.ui.game.control.numpad.button.normal.text
              )
            )
          )
          .foregroundStyle(
            Color(
              self.styleManager.colorScheme.mode == .dark ? (
                self.styleManager.colorScheme.ui.game.control.numpad.button.normal.text
              ) : (
                self.styleManager.colorScheme.ui.game.control.numpad.button.normal.background
              )
            )
          )

          Section {
            Picker("Theme", selection: $colorSchemeName) {
              ForEach(ColorSchemeName.allCases, id: \.self) { name in
                Text(name.rawValue).tag(name.rawValue)
              }
            }
            .colorMultiply(
              Color(
                self.styleManager.colorScheme.board.cell.text.player.valid
              )
            )
            .tint(.white)
            .onChange(of: self.colorSchemeName) { newColorSchemeName in
              StyleManager.current
                .switchColorScheme(
                  to: ColorSchemeName(rawValue: newColorSchemeName) ?? .darkYellow
                )
            }
          }
          .listRowBackground(
            Color(
              self.styleManager.colorScheme.mode == .dark ? (
                self.styleManager.colorScheme.ui.game.control.numpad.button.normal.background
              ) : (
                self.styleManager.colorScheme.ui.game.control.numpad.button.normal.text
              )
            )
          )
          .foregroundStyle(
            Color(
              self.styleManager.colorScheme.mode == .dark ? (
                self.styleManager.colorScheme.ui.game.control.numpad.button.normal.text
              ) : (
                self.styleManager.colorScheme.ui.game.control.numpad.button.normal.background
              )
            )
          )
          
          Section(
            header: Text("About")
          ) {
            Text("App version: \(Bundle.main.appVersionNumber)")
            Link("sudoku@kishanjadav.com", destination: URL(string: "mailto:sudoku@kishanjadav.com")!)
          }
          .listRowBackground(
            Color(
              self.styleManager.colorScheme.mode == .dark ? (
                self.styleManager.colorScheme.ui.game.control.numpad.button.normal.background
              ) : (
                self.styleManager.colorScheme.ui.game.control.numpad.button.normal.text
              )
            )
          )
          .foregroundStyle(
            Color(
              self.styleManager.colorScheme.mode == .dark ? (
                self.styleManager.colorScheme.ui.game.control.numpad.button.normal.text
              ) : (
                self.styleManager.colorScheme.ui.game.control.numpad.button.normal.background
              )
            )
          )
        }
        .apply({ view in
          if #available(iOS 16.0, *) {      
            view.scrollContentBackground(.hidden)
          } else {
            view
          }
        })
      }
    }
  }
}
