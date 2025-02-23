//
//  AppDelegate.swift
//  sudoku
//
//  Created by Kishan Jadav on 23/02/2025.
//

import SwiftUI
import CloudKit.CKNotification

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
