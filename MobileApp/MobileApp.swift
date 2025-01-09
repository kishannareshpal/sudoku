//
//  MobileAppApp.swift
//  MobileApp
//
//  Created by Kishan Jadav on 04/01/2025.
//

import SwiftUI

@main
struct MobileApp: App {
  @StateObject var dataProvider = AppDataProvider.shared
  
  var body: some Scene {
    WindowGroup {
      NavigationView {
        GameScreen(difficulty: .easy)
      }
    }
    .environment(\.managedObjectContext
                  , dataProvider.container.viewContext)
  }
}
