//
//  sudokuApp.swift
//  sudoku
//
//  Created by Kishan Jadav on 17/08/2024.
//

import SwiftUI

@main
struct SudokuApp: App {
  @StateObject var syncManager = SyncManager()

  @StateObject var dataProvider = AppDataProvider.shared
  @WKApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  func requestNotificationPermission() {
    DispatchQueue.main.async {
      WKApplication.shared().registerForRemoteNotifications()
      print("Registered for remote notifications")
      
      Task {
        await DataManager.default.saveGamesService.subscribeToCloudActiveSaveGameChanges()
      }
    }
  }
  
  var body: some Scene {
    WindowGroup {
      AppNavigationStack {
        HomeScreen(syncManager: self.syncManager)
      }
      .background(.clear)
      .onAppear {
        self.appDelegate.syncManager = self.syncManager
        self.requestNotificationPermission()
      }
    }
    .environment(\.managedObjectContext, dataProvider.container.viewContext)
  }
}
