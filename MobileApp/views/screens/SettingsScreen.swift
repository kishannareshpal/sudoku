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
  
  var body: some View {
    Text("Current theme")
//    
//    Button("Change to light") {
//      tm.change(to: .lightYellow)
////      tm.theme.name = "From settings"
//    }.buttonStyle(.bordered)
  }
}
