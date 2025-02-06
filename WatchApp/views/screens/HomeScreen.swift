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

  init() {
    try! DataManager.default.usersService.ensureCurrentUserExists()
  }
  
  private func loadLastGame() {
    print("Reloaded last game")
    self.activeSaveGame = DataManager.default.usersService.findActiveSaveGame()
  }
  
  var body: some View {
    VStack {
      Spacer(minLength: 4)
      
      List {
        if activeSaveGame != nil {
          Section(
            header: VStack(alignment: .leading) {
              Text("Welcome back!").fontWeight(.bold)
              Text("Continue where you left off:").font(.system(size: 12))
            }
          ) {
            ContinueGameButton()
          }.padding(.vertical)
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
            if activeSaveGame != nil {
              Button {
                self.newGameConfirmationDifficulty = difficulty
                self.newGameConfirmationShowing = true
              } label: {
                NewGameCard(difficulty: difficulty)
              }
            } else {
              NavigationLink(
                destination: GameScreen(difficulty: difficulty)
                  .navigationBarBackButtonHidden()
              ) {
                NewGameCard(difficulty: difficulty)
              }
            }
          }.confirmationDialog(
            Text("New game?"),
            isPresented: $newGameConfirmationShowing
          ) {
            Button("Cancel", role: .cancel) {}
            Button("New game", role: .destructive) {
              try! DataManager.default.usersService.detachActiveSaveGame()
              self.activeSaveGame = nil
              self.newGameConfirmed = true
            }
            
          } message: {
            Text("Your existing game progress will be discarded when you start a new game.")
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
        destination: GameScreen(difficulty: self.newGameConfirmationDifficulty ?? .easy)
          .navigationBarBackButtonHidden(),
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
