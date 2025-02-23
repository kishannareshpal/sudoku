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
        HomeScreen(syncManager: self.syncManager)
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

struct AppNavigationStack<Content: View>: View {
  let content: Content
  
  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  
  var body: some View {
    if #available(iOS 16.0, *) {
      NavigationStack {
        content
      }
    } else {
      NavigationView {
        content
      }
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  var syncManager: SyncManager?
  
  func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    print("Successfully registered for remote notifications.")
  }
  
  func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("Failed to register for remote notifications: \(error.localizedDescription)")
  }
  
  // Silent notifications do not display an alert or sound but allow the app to perform background tasks.
  // - Used when a notification about a save game change in the cloud is received.
  func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)
    let hasActiveSaveGameChanged = notification?.subscriptionID == DataManager.default.saveGamesService.cloudSaveGameRepository.ACTIVE_SAVE_GAME_CHANGED_NOTIFICATION_KEY
    if (hasActiveSaveGameChanged) {
      Task {
        await syncManager?.sync()
        completionHandler(.newData)
      }

    } else {
      completionHandler(.noData)
    }
  }
}
