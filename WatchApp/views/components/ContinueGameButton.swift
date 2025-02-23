//
//  ExistingGameCard.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

import SwiftUI

struct ContinueGameSection: View {
  var syncManager: SyncManager
  
  @FetchRequest(
    fetchRequest:
      FetchRequestHelper.buildFetchRequest(
        predicate: NSPredicate(
          format: "active == %d",
          true
        )
      ),
    animation: .interpolatingSpring
  ) private var activeLocalSaveGames: FetchedResults<SaveGameEntity>
  
  private var activeLocalSaveGame: SaveGameEntity? {
    return self.activeLocalSaveGames.first
  }
  
  var body: some View {
    Section(
      header: activeLocalSaveGame != nil ? VStack(alignment: .leading) {
        Text("Welcome back!").fontWeight(.bold)
        Text("Continue from where you left off:").font(.system(size: 12))
      } : nil,
      footer: VStack(alignment: .center) {
        if self.syncManager.status == .syncing {
          // Syncing
          HStack(spacing: 8) {
            ProgressView()
              .frame(width: 10, height: 10)
              .progressViewStyle(.circular)
            
            Text("Syncing...")
              .font(.system(size: 10))
          }
          .foregroundStyle(.white)
          .tint(.white)

        } else if case .completed(let syncResult) = self.syncManager.status {
          if syncResult == .offline {
            HStack(spacing: 8) {
              Image(systemName: "icloud.slash.fill")
                .font(.system(size: 10))
              
              Text("Offline")
                .font(.system(size: 10))
            }
            .foregroundStyle(.white)
            
          } else if syncResult == .success {
            HStack(spacing: 8) {
              Image(systemName: "checkmark.icloud")
                .font(.system(size: 10))
              
              Text("Synced")
                .font(.system(size: 10))
            }
            .foregroundStyle(.white)
          }
        }
      }
    ) {
      if let activeLocalSaveGame {
        ContinueGameButton(
          difficulty: Difficulty(rawValue: activeLocalSaveGame.difficulty!)!,
          activeLocalSaveGame: activeLocalSaveGame,
          isEnabled: self.syncManager.status != .syncing
        )
      }
    }.padding(.vertical)
  }
}

struct ContinueGameButton: View {
  var difficulty: Difficulty
  @ObservedObject var activeLocalSaveGame: SaveGameEntity
  
  var isEnabled: Bool = true
  
  var body: some View {
    NavigationLink(
      destination: GameScreen()
    ) {
      HStack(alignment: .top) {
        VStack(alignment: .leading) {
          Text(activeLocalSaveGame.difficulty ?? "Unknown difficulty")
            .font(.system(size: 18, weight: .black))
            .foregroundStyle(.white)
          
          Text("Points: \(activeLocalSaveGame.score)")
            .foregroundStyle(.white)
            .font(.system(size: 12, weight: .regular))
          
          Text(
            "Played for: \(GameDurationHelper.format(Int(activeLocalSaveGame.durationInSeconds), pretty: true))"
          )
          .font(.system(size: 12, weight: .regular))
          .foregroundStyle(.white)
          .apply { view in
            if #available(watchOS 9.0, *) {
              view.contentTransition(.numericText())
            } else {
              view
            }
          }
          
          Spacer().frame(height: 8)
          
          Text("Tap to continue")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Color(TheTheme.Colors.primary))
        }.scaledToFit()
        
        Spacer().frame(width: 24)
        
        Image(systemName: "play.circle.fill")
          .font(.system(size: 28))
          .foregroundStyle(Color(TheTheme.Colors.primary))
      }
    }
    .disabled(!self.isEnabled)
    .listItemTint(Color(TheTheme.Colors.primary).opacity(0.3))
  }
}
