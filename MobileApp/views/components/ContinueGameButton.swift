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

            if !AppConfig.prefersOffline() && syncResult == .offline {
              HStack(spacing: 6) {
                Image(systemName: "icloud.slash.fill")
                  .font(.caption)
                
                Text("Offline")
                  .font(.caption)
              }
              .foregroundStyle(Color(self.currentColorScheme.board.cell.text.given))
              
            } else if syncResult == .success {
              HStack(spacing: 6) {
                Image(systemName: "checkmark.icloud")
                  .font(.caption)
                
                Text("Synced")
                  .font(.caption)
              }
              .foregroundStyle(
                Color(self.currentColorScheme.board.cell.text.given)
              )
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
        .foregroundStyle(
          Color(self.currentColorScheme.board.cell.text.given)
        )
        .tint(
          Color(self.currentColorScheme.board.cell.text.given)
        )
      }
    }
  }
}

struct ContinueGameButton: View {
  private let currentColorScheme = StyleManager.current.colorScheme
  
  var difficulty: Difficulty
  @ObservedObject var activeLocalSaveGame: SaveGameEntity
  
  @State private var restartGameConfirmationShowing: Bool = false
  @State private var restartGameConfirmed: Bool = false
  
  var isEnabled: Bool = true
  
  private let vibrator = UIImpactFeedbackGenerator(style: .rigid)
  
  private func restartGame(confirmed: Bool = false) -> Void {
    // If not confirmed, ask for confirmation
    guard confirmed else {
      self.restartGameConfirmationShowing = true
      return
    }
    
    // Reset the current game
    DispatchQueue.global(qos: .userInteractive).async {
      try! DataManager.default.saveGamesService.resetSaveGame(activeLocalSaveGame.objectID)
    }
    
    // Update the UI on the main thread
    DispatchQueue.main.async {
      withAnimation(.interpolatingSpring) {
        self.restartGameConfirmed = true
      }
    }
  }
  
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
              if #available(iOS 16.0, *) {
                view.contentTransition(.numericText())
              } else {
                view
              }
            }
          }
          .foregroundStyle(
            Color(currentColorScheme.board.cell.text.given)
          )
          
          Spacer().frame(height: 8)
          
          Text("Tap to continue")
            .font(.system(size: 14, weight: .medium))
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
    .buttonStyle(
      ContinueGameButtonStyle(
        backgroundColor: Color(currentColorScheme.board.cell.text.player.valid),
        isEnabled: self.isEnabled
      )
    )
    .onAppear(perform: vibrator.prepare)
    .contextMenu {
      NavigationLink(destination: GameScreen()) {
        Text("Resume")
        Image(systemName: "play.circle.fill")
      }
      
      Divider()

      Button (
        role: .destructive,
        action: { self.restartGame(confirmed: false) }
      ) {
        Text("Restart")
      }
    }
    .overlay {
      // Note: This is a workaround, in order to support watchOS 8. Navigating in SwiftUI is cumbersome,
      // especially when you want to do so from an alert or a dialog. Because dialogs are rendered out of scope
      // of the navigation container, having a "NavigationLink" button as an action within a dialog is not supported.
      // There's no static API to use to navigate other than using these Navigation* views.
      // - For that reason, here we're taking advantage of using the isActive: property to programmatically navigate to the view.
      // - When we navigate back, the isActive: bound value is toggled back to false! So this works out great.
      // - We are hiding this view as we're only using it for navigating.
      NavigationLink(
        destination: GameScreen(),
        isActive: $restartGameConfirmed
      ) {}.hidden()
    }
    .confirmationDialog(
      "Restart your current game?",
      isPresented: $restartGameConfirmationShowing,
      titleVisibility: .visible
    ) {
      Button("Cancel", role: .cancel) {}
      Button("Restart", role: .destructive) {
        self.restartGame(confirmed: true)
      }

    } message: {
      Text(
        "Restarting will erase your previous progress. Proceed?"
      )
    }
    .hoverEffect(.highlight)
    .apply { view in
      if #available(iOS 17.0, *) {
        view
          .hoverEffectDisabled(!self.isEnabled)
      } else {
        view
      }
    }
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
  var backgroundColor: Color
  var isEnabled: Bool = false
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaledToFit()
      .padding(12)
      .background(backgroundColor.opacity(0.3))
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
      .hoverEffect(.lift)
      .apply { view in
        if #available(iOS 17.0, *) {
          view
            .hoverEffectDisabled(!self.isEnabled)
        } else {
          view
        }
      }
  }
}
