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
  @StateObject var dataProvider = AppDataProvider.shared
//  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  func requestNotificationPermission() {
    DispatchQueue.main.async {
      UIApplication.shared.registerForRemoteNotifications()
      print("Registered for remote notifications")
    }
  }
  
  var body: some Scene {
    WindowGroup {
      NavigationView {
        HomeScreen()
      }
      .onAppear {
        requestNotificationPermission()
      }
    }
    .environment(\.managedObjectContext, dataProvider.container.viewContext)
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
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
  
  // Silent notifications do not display an alert or sound but allow the app to perform background tasks. Use the didReceiveRemoteNotification method to handle them.
  func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)
    
    if notification?.subscriptionID == "cloud-savegames-changes" {
      print("Silent notification received for counter changes.")
      
      // Fetch updated data from CloudKit
      Task {
//        await DataManager.default.saveGamesService.sync()
        completionHandler(.newData)
      }

    } else {
      print("No silent notification received for counter changes")
      completionHandler(.noData)
    }
  }
}
