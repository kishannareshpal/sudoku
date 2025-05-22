//
//  HomeScreen.swift
//  sudoku
//
//  Created by Kishan Jadav on 09/01/2025.
//

import SwiftUI
import SpriteKit
import UIKit.UIColor
import UIColorHexSwift

struct HomeScreen: View {
  @ObservedObject var styleManager: StyleManager
  @ObservedObject var syncManager: SyncManager

  @State private var newGameConfirmationShowing: Bool = false
  @State private var newGameConfirmationDifficulty: Difficulty? = nil
  @State private var newGameConfirmed: Bool = false
  @State private var loadingNewGameForDifficulty: Difficulty? = nil

  @FetchRequest(
    fetchRequest:
      FetchRequestHelper.buildFetchRequest(
        predicate: NSPredicate(
          format: "active == %d",
          true
        ),
        limit: 1
      ),
    animation: .interpolatingSpring
  ) private var activeSaveGames: FetchedResults<SaveGameEntity>

  private var activeSaveGame: SaveGameEntity? {
    return self.activeSaveGames.first
  }
  
  private func startNewGame(difficulty: Difficulty, confirmed: Bool = false) -> Void {
    if ((self.activeSaveGame != nil) && !confirmed) {
      // Attempting to start a new game, but there already is one in progress.
      // - Confirm:
      self.newGameConfirmationDifficulty = difficulty
      self.newGameConfirmationShowing = true
      return
    }
    
    withAnimation(.interpolatingSpring) {
      self.loadingNewGameForDifficulty = difficulty
      self.newGameConfirmationDifficulty = nil
    }
    
    DispatchQueue.global(qos: .userInteractive).async {
      try! DataManager.default.saveGamesService.createNewSaveGame(
        difficulty: difficulty
      )
      
      // Update the UI on the main thread
      DispatchQueue.main.async {
        withAnimation(.interpolatingSpring) {
          self.loadingNewGameForDifficulty = nil
          self.newGameConfirmed = true
        }
      }
    }
  }
  
  var body: some View {
    ZStack {
      Color(
        self.styleManager.colorScheme.mode == .dark ? (
          self.styleManager.colorScheme.ui.game.control.numpad.button.selected.background
        ) : (
          self.styleManager.colorScheme.ui.game.background
        )
      )
        .brightness(self.styleManager.colorScheme.mode == .dark ? -0.93 : 0)
        .ignoresSafeArea()

      ScrollView {
        VStack(spacing: 48) {
          VStack(spacing: -50) {
            Text("SUD")
            Text("OKU")
          }
          .font(.system(size: 140, weight: .black).italic())
          .foregroundStyle(Color(self.styleManager.colorScheme.board.cell.text.player.valid))
          
          if loadingNewGameForDifficulty == nil {
            ContinueGameSection(
              syncManager: self.syncManager
            )
          }
          
          VStack(spacing: 12) {
            Text("Start a new game:")
              .fontWeight(.bold)
              .foregroundStyle(Color(self.styleManager.colorScheme.board.cell.text.given))
            
            VStack(spacing: 8) {
              ForEach(Difficulty.allCases) { difficulty in
                Button(
                  action: {
                    self.startNewGame(difficulty: difficulty)
                  },
                  label: {
                    NewGameButtonContent(
                      difficulty: difficulty,
                      loading: self.loadingNewGameForDifficulty == difficulty
                    )
                  }
                )
                .disabled(self.loadingNewGameForDifficulty != nil)
                .buttonStyle(
                  NormalButtonStyle(
                    backgroundColor: Color(
                      self.styleManager.colorScheme.mode == .dark ? (
                        self.styleManager.colorScheme.ui.game.control.numpad.button.normal.background
                      ) : (
                        self.styleManager.colorScheme.ui.game.control.numpad.button.normal.text
                      )
                    ),
                    foregroundColor:
                      Color(
                        self.styleManager.colorScheme.mode == .dark ? (
                          self.styleManager.colorScheme.ui.game.control.numpad.button.normal.text
                        ) : (
                          self.styleManager.colorScheme.ui.game.control.numpad.button.normal.background
                        )
                      ),
                    isEnabled: self.loadingNewGameForDifficulty == nil
                  )
                )
                .frame(maxWidth: 400)
                .hoverEffect()
                .apply { view in
                  if #available(iOS 17.0, *) {
                    view
                      .hoverEffectDisabled(self.loadingNewGameForDifficulty != nil)
                  } else {
                    view
                  }
                }
              }
              .confirmationDialog(
                "Start a new game?",
                isPresented: $newGameConfirmationShowing,
                titleVisibility: .visible
              ) {
                Button("Cancel", role: .cancel) {
                  self.newGameConfirmationDifficulty = nil
                }
                Button("New game", role: .destructive) {
                  self.startNewGame(
                    difficulty: newGameConfirmationDifficulty!,
                    confirmed: true
                  )
                }
    
              } message: {
                Text(
                  "Starting a new game will erase your current progress. Proceed?"
                )
              }
            }
          }
          
          NavigationLink(
            destination:
              SettingsScreen(styleManager: StyleManager.current)
          ) {
            HStack {
              Image(systemName: "gear")
              Text("Settings")
            }
          }
          .foregroundStyle(
            Color(self.styleManager.colorScheme.board.cell.text.player.valid)
          )
          .hoverEffect()
        }
        .padding()
        .padding(.vertical, 32)
      }
    }
    .overlay {
      // Note: Navigating in SwiftUI is cumbersome,
      // especially when you want to do so from an alert or a dialog. Because dialogs are rendered out of scope
      // of the navigation container, having a "NavigationLink" button as an action within a dialog is not supported.
      // There's no static API to use to navigate other than using these Navigation* views.
      // - For that reason, here we're taking advantage of using the isActive: property to programmatically navigate to the view.
      // - When we navigate back, the isActive: bound value is toggled back to false! So this works out great.
      // - We are hiding this view as we're only using it for navigating.
      NavigationLink(
        destination: GameScreen(),
        isActive: $newGameConfirmed
      ) {}.hidden()
    }
    .task {
      await self.syncManager.sync()
    }
    .refreshable {
      await self.syncManager.sync()
    }
    .onAppear() {
      UIRefreshControl.appearance().tintColor = self.styleManager.colorScheme.board.cell.text.player.valid
    }
    .navigationBarHidden(true)
    .preferredColorScheme(self.styleManager.colorScheme.mode == .dark ? .dark : .light)
    .tint(
      Color(self.styleManager.colorScheme.board.cell.text.player.valid)
    )
  }
}
