//
//  AppDelegate.swift
//  sudoku
//
//  Created by Kishan Jadav on 23/02/2025.
//

import SwiftUI
import CloudKit.CKNotification

class AppDelegate: NSObject, WKApplicationDelegate {
  var syncManager: SyncManager?
  
  func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
    print("Successfully registered for remote notifications.")
  }
  
  func didFailToRegisterForRemoteNotificationsWithError(_ error: any Error) {
    print("Failed to register for remote notifications: \(error.localizedDescription)")
  }
  
  func didReceiveRemoteNotification(
    _ userInfo: [AnyHashable : Any],
    fetchCompletionHandler completionHandler: @escaping (WKBackgroundFetchResult) -> Void
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
