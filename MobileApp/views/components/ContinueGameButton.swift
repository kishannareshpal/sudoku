//
//  ContinueGameButton.swift
//  sudoku
//
//  Created by Kishan Jadav on 12/01/2025.
//

import SwiftUI
import CoreData
import UIKit.UIColor
import UIColorHexSwift

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
    VStack(spacing: 12) {
      if let activeLocalSaveGame {
        if case .completed(let syncResult) = self.syncManager.status {
          if syncResult == .conflict {
            ResolveGameConflictButton(
              onConfirmed: { syncResult in
                self.syncManager.status = .completed(result: syncResult)
              },
              isEnabled: self.syncManager.status != .syncing
            )

          } else {
            ContinueGameButton(
              difficulty: Difficulty(rawValue: activeLocalSaveGame.difficulty!)!,
              activeLocalSaveGame: activeLocalSaveGame,
              isEnabled: self.syncManager.status != .syncing
            )

            if syncResult == .offline {
              HStack(spacing: 6) {
                Image(systemName: "icloud.slash.fill")
                  .font(.caption)
                
                Text("Offline")
                  .font(.caption)
              }
              .foregroundStyle(.white)
              
            } else if syncResult == .success {
              HStack(spacing: 6) {
                Image(systemName: "checkmark.icloud")
                  .font(.caption)
                
                Text("Synced")
                  .font(.caption)
              }
              .foregroundStyle(.white)
            }
          }

        } else {
          ContinueGameButton(
            difficulty: Difficulty(rawValue: activeLocalSaveGame.difficulty!)!,
            activeLocalSaveGame: activeLocalSaveGame,
            isEnabled: self.syncManager.status != .syncing
          )
        }
      }
      
      if self.syncManager.status == .syncing {
        // Syncing
        HStack(spacing: 6) {
          ProgressView()
            .font(.caption)
          
          Text("Syncing your progress...")
            .font(.caption)
        }
        .foregroundStyle(.white)
        .tint(.white)
      }
    }
  }
}

struct ContinueGameButton: View {
  var difficulty: Difficulty
  @ObservedObject var activeLocalSaveGame: SaveGameEntity
  
  var isEnabled: Bool = true
  
  private let vibrator = UIImpactFeedbackGenerator(style: .rigid)
  
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
            if #available(iOS 16.0, *) {
              view.contentTransition(.numericText())
            } else {
              view
            }
          }
          
          Spacer().frame(height: 8)
          
          Text("Tap to continue")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(Color(TheTheme.Colors.primary))
        }.scaledToFit()
        
        Spacer().frame(width: 24)
        
        Image(systemName: "play.circle.fill")
          .font(.system(size: 28))
          .foregroundStyle(Color(TheTheme.Colors.primary))
      }
    }
    .disabled(!self.isEnabled)
    .buttonStyle(ContinueGameButtonStyle(isEnabled: self.isEnabled))
    .onAppear(perform: vibrator.prepare)
  }
}

struct ResolveGameConflictButton: View {
  @State private var saveGameConflictResolutionScreenShowing: Bool = false
  
  var onConfirmed: (_ syncResult: SyncResult) -> Void
  var isEnabled: Bool = true

  private let vibrator = UIImpactFeedbackGenerator(style: .rigid)

  var body: some View {
    Button(
      action: { self.saveGameConflictResolutionScreenShowing.toggle() }
    ) {
      VStack(alignment: .leading, spacing: 8) {
        Image(systemName: "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90")
          .font(.system(size: 18))
          .foregroundStyle(.white)
        
        Text("Found conflicting save games")
          .foregroundStyle(.white)
          .font(.system(size: 14, weight: .regular))
        
        Text("Tap to review")
          .font(.system(size: 14, weight: .bold))
          .foregroundStyle(.white)
      }.scaledToFit()
    }
    .buttonStyle(ResolveGameConflictButtonStyle(isEnabled: self.isEnabled))
    .onAppear(perform: self.vibrator.prepare)
    .sheet(isPresented: $saveGameConflictResolutionScreenShowing) {
      SaveGameConflictResolutionScreen(
        onConfirmed: self.onConfirmed
      )
    }
  }
}

struct ContinueGameButtonStyle: ButtonStyle {
  var isEnabled: Bool = false
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaledToFit()
      .padding(12)
      .background(Color(TheTheme.Colors.primary).opacity(0.3))
      .clipShape(RoundedRectangle(cornerRadius: 14))
      .scaleEffect(configuration.isPressed ? 0.9 : 1)
      .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
      .disabled(!isEnabled)
      .opacity(isEnabled ? 1 : 0.6)
  }
}

struct ResolveGameConflictButtonStyle: ButtonStyle {
  var isEnabled: Bool = false
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaledToFit()
      .padding(12)
      .background(Color(UIColor("#161616")))
      .clipShape(RoundedRectangle(cornerRadius: 14))
      .scaleEffect(configuration.isPressed ? 0.9 : 1)
      .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
      .disabled(!isEnabled)
      .opacity(isEnabled ? 1 : 0.6)
  }
}
