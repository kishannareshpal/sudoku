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
  @State private var newGameConfirmationShowing: Bool = false
  @State private var newGameConfirmationDifficulty: Difficulty? = nil
  @State private var newGameConfirmed: Bool = false

  @State private var activeSaveGame: SaveGameEntity?
  @State private var loadingNewGameForDifficulty: Difficulty? = nil
  
  init() {
    try! DataManager.default.usersService.ensureCurrentUserExists()
  }
  
  private func loadLastGame() {
    print("Reloaded last game")
    self.activeSaveGame = DataManager.default.usersService.findActiveSaveGame()
  }
  
  private func startNewGame(difficulty: Difficulty, confirmed: Bool = false) -> Void {
    if (self.activeSaveGame != nil && !confirmed) {
      // Attempting to start a new game, but there already is one in progress.
      // - Confirm:
      self.newGameConfirmationDifficulty = difficulty
      self.newGameConfirmationShowing = true
      return
    }
    
    withAnimation(.interpolatingSpring) {
      self.loadingNewGameForDifficulty = difficulty
    }
    
    self.activeSaveGame = nil
    self.newGameConfirmationDifficulty = nil
    
    // Run the whole process on the MainActor context
    Task.detached {
      try! DataManager.default.usersService.detachActiveSaveGame()
      let newSaveGame = try! DataManager.default.saveGamesService.createNewSaveGame(difficulty: difficulty)
      
      await MainActor.run {
        self.activeSaveGame = newSaveGame
        
        withAnimation(.interpolatingSpring) {
          self.loadingNewGameForDifficulty = nil
          self.newGameConfirmed = true
        }
      }
    }
  }
  
  var body: some View {
    ZStack {
      Color(UIColor("#100D01"))
        .ignoresSafeArea()

      ScrollView {
        VStack(spacing: 48) {
          Spacer().frame(height: 48)
          
          VStack(spacing: 8) {
            Image("Softly rounded logo")
              .resizable()
              .frame(width: 82, height: 82)
              .scaledToFit()
            
            Text("Sudoku")
              .font(.system(size: 48, weight: .medium))
              .foregroundStyle(.accent)
          }
          
          ThemePicker()
          
          if loadingNewGameForDifficulty == nil {
            ContinueGameSection()
          }
          
          VStack(spacing: 12) {
            Text("Start a new game:")
              .fontWeight(.bold)
              .foregroundStyle(.white)
            
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
                    isEnabled: self.loadingNewGameForDifficulty == nil
                  )
                )
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
                  "Starting a new game will discard your current progress in the existing game. You will be playing on \(newGameConfirmationDifficulty?.rawValue ?? "Normal") difficulty.\nAre you sure you want to proceed?"
                )
              }
            }
          }
        }
        .padding()
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
        destination: GameScreen().navigationBarBackButtonHidden(),
        isActive: $newGameConfirmed
      ) {}.hidden()
    }
    .onAppear {
      self.loadLastGame()
    }
  }
}

#Preview {
  HomeScreen()
}
