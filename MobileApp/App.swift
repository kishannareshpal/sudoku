//
//  MobileAppApp.swift
//  MobileApp
//
//  Created by Kishan Jadav on 04/01/2025.
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
