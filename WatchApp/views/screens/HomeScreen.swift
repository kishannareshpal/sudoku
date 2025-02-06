//
//  HomeScreen.swift
//  sudoku
//
//  Created by Kishan Jadav on 13/01/2023.
//

import SwiftUI
import SpriteKit
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
    VStack {
      Spacer(minLength: 4)
      
      List {
        if loadingNewGameForDifficulty == nil {
          ContinueGameSection()
        }
      
        Section(
          header: VStack(alignment: .leading) {
            if activeSaveGame == nil {
              Text("Welcome!").fontWeight(.bold)
              Text("Start a new game:").font(.system(size: 12))
            } else {
              Text("Start a new game:")
            }
          }.padding(.vertical)
        ) {
          ForEach(Difficulty.allCases) { difficulty in
            Button(
              action: {
                self.startNewGame(difficulty: difficulty)
              },
              label: {
                NewGameButtonContent(
                  difficulty: difficulty,
                  loading:
                    self.loadingNewGameForDifficulty == difficulty
                )
              }
            )
            .disabled(self.loadingNewGameForDifficulty != nil)
            
//            if activeSaveGame != nil {
//              Button {
//                self.newGameConfirmationDifficulty = difficulty
//                self.newGameConfirmationShowing = true
//              } label: {
//                NewGameCard(difficulty: difficulty)
//              }
//            } else {
//              NavigationLink(
//                destination: GameScreen(difficulty: difficulty)
//                  .navigationBarBackButtonHidden()
//              ) {
//                NewGameCard(difficulty: difficulty)
//              }
//            }
          }.confirmationDialog(
            Text("New game?"),
            isPresented: $newGameConfirmationShowing
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
        
        Section() {
          NavigationLink(destination: SettingsScreen()) {
            Button(
              action: {},
              label: {
                HStack {
                  Image(systemName: "gear")
                  Text("Settings")
                }
              }
            )
          }
        }
      }
    }
    .navigationTitle("MiniSudoku")
    .overlay {
      // Note: This is a workaround, in order to support watchOS 8. Navigating in SwiftUI is cumbersome,
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
  NavigationView {
    HomeScreen()
      .environment(
        \.managedObjectContext,
         AppDataProvider.shared.container.viewContext
      )
  }
}
