//
//  SyncManager.swift
//  sudoku
//
//  Created by Kishan Jadav on 15/02/2025.
//

import Foundation
import SwiftUICore

class SyncManager: ObservableObject {
  enum SyncStatus: Equatable {
    case idle, syncing, completed(result: SyncResult)
  }

  @Published var status: SyncStatus = .idle

  func sync() async {
    guard self.status != .syncing else {
      return
    }
    
    await MainActor.run {
      withAnimation(.interactiveSpring) {
        self.status = .syncing
      }
    }

    let syncResult = await DataManager.default.saveGamesService.sync()

    await MainActor.run {
      withAnimation(.interactiveSpring) {
        self.status = .completed(result: syncResult)
      }
    }
  }
}
