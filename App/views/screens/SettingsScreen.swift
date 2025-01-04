//
//  SettingsScreen.swift
//  sudoku
//
//  Created by Kishan Jadav on 04/01/2025.
//

import SwiftUI
import SpriteKit

struct SettingsScreen: View {
  @AppStorage(AppConfig.Keys.highlightOrientation) var highlightOrientation: String = LocationIndexOrientation.topToBottom.rawValue

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
      
      VStack(alignment: .leading) {
        Divider()
        Text("App version: \(Bundle.main.appVersionNumber)").font(.caption2)
        Text("sudoku@kishanjadav.com").font(.system(size: 12))
      }.listRowBackground(Color.clear)
      
    }.navigationTitle {
      HStack {
        Image(systemName: "gear")
        Text("Settings")
      }
    }
  }
}
