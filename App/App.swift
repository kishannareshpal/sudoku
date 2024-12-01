//
//  sudokuApp.swift
//  sudoku
//
//  Created by Kishan Jadav on 17/08/2024.
//

import SwiftUI

@main
struct SudokuApp: App {
  @StateObject var dataProvider = AppDataProvider.shared
  
  var body: some Scene {
    WindowGroup {
      NavigationView {
        HomeScreen()
      }
    }
    .environment(\.managedObjectContext, dataProvider.container.viewContext)
  }
}
