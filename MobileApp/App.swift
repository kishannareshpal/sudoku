//
//  MobileAppApp.swift
//  MobileApp
//
//  Created by Kishan Jadav on 04/01/2025.
//

import SwiftUI
import CloudKit

@main
struct SudokuApp: App {
  @StateObject var styleManager = StyleManager.current
  @StateObject var syncManager = SyncManager()
  @StateObject var dataProvider = AppDataProvider.shared
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  func requestNotificationPermission() {
    DispatchQueue.main.async {
      UIApplication.shared.registerForRemoteNotifications()
      print("Registered for remote notifications")
      
      Task {
        await DataManager.default.saveGamesService.subscribeToCloudActiveSaveGameChanges()
      }
    }
  }
  
  var body: some Scene {
    WindowGroup {
      AppNavigationStack {
        HomeScreen(
          styleManager: self.styleManager,
          syncManager: self.syncManager
        )
      }
      .background(.clear)
      .onAppear {
        self.appDelegate.syncManager = self.syncManager
        self.requestNotificationPermission()
      }
    }
    .environment(\.managedObjectContext, self.dataProvider.container.viewContext)
  }
}
