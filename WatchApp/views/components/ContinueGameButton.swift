//
//  ExistingGameCard.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

import SwiftUI

struct ContinueGameSection: View {
  var syncManager: SyncManager
  
  private let currentColorScheme = StyleManager.current.colorScheme
  
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
        Logo()
        Text("Welcome back!").fontWeight(.bold)
        Text("Continue from where you left off:").font(.system(size: 12))
      }.foregroundStyle(Color(self.currentColorScheme.board.cell.text.given)) : nil,
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
          .foregroundStyle(
            Color(self.currentColorScheme.board.cell.text.given)
          )
          .tint(.white)

        } else if case .completed(let syncResult) = self.syncManager.status {
          if syncResult == .offline {
            HStack(spacing: 8) {
              Image(systemName: "icloud.slash.fill")
                .font(.system(size: 10))
              
              Text("Offline")
                .font(.system(size: 10))
            }
            .foregroundStyle(
              Color(self.currentColorScheme.board.cell.text.given)
            )
            
          } else if syncResult == .success {
            HStack(spacing: 8) {
              Image(systemName: "checkmark.icloud")
                .font(.system(size: 10))
              
              Text("Synced")
                .font(.system(size: 10))
            }
            .foregroundStyle(
              Color(self.currentColorScheme.board.cell.text.given)
            )
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
  private let currentColorScheme = StyleManager.current.colorScheme
  
  var difficulty: Difficulty
  @ObservedObject var activeLocalSaveGame: SaveGameEntity
  
  var isEnabled: Bool = true
  
  var body: some View {
    NavigationLink(
      destination: GameScreen()
    ) {
      HStack(alignment: .top) {
        VStack(alignment: .leading) {
          Group {
            Text(activeLocalSaveGame.difficulty ?? "Unknown difficulty")
              .font(.system(size: 18, weight: .black))
            
            Text("Points: \(activeLocalSaveGame.score)")
              .font(.system(size: 12, weight: .regular))
            
            Text(
              "Played for: \(GameDurationHelper.format(Int(activeLocalSaveGame.durationInSeconds), pretty: true))"
            )
            .font(.system(size: 12, weight: .regular))
            .apply { view in
              if #available(watchOS 9.0, *) {
                view.contentTransition(.numericText())
              } else {
                view
              }
            }
          }
          .foregroundStyle(
            Color(self.currentColorScheme.board.cell.text.given)
          )
          
          Spacer().frame(height: 8)
          
          Text("Tap to continue")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(
              Color(currentColorScheme.board.cell.text.player.valid)
            )
        }.scaledToFit()
        
        Spacer().frame(width: 24)
        
        Image(systemName: "play.circle.fill")
          .font(.system(size: 28))
          .foregroundStyle(
            Color(currentColorScheme.board.cell.text.player.valid)
          )
      }
    }
    .disabled(!self.isEnabled)
    .listItemTint(
      Color(
        currentColorScheme.board.cell.text.player.valid
      ).opacity(0.3)
    )
  }
}
