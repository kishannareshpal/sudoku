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
      if self.styleManager.colorScheme.mode == .light {
        LinearGradient(
          gradient: Gradient(stops: [
            .init(color: Color(UIColor("#C2C2C2")), location: 0.01),
            .init(color: Color(self.styleManager.colorScheme.ui.game.background), location: 1.0)
          ]),
          startPoint: .topTrailing,
          endPoint: .bottom
        )
        .ignoresSafeArea()
        
      } else {
        Color(
          self.styleManager.colorScheme.mode == .dark ? (
            self.styleManager.colorScheme.ui.game.control.numpad.button.selected.background
          ) : (
            self.styleManager.colorScheme.ui.game.background
          )
        )
        .opacity(self.styleManager.colorScheme.mode == .dark ? 0.1 : 1)
        .apply({ view in
          if self.styleManager.colorScheme.mode == .dark {
            view.background(.black)
          } else {
            view
          }
        })
        .ignoresSafeArea()
      }
      
      VStack {
        List {
          if loadingNewGameForDifficulty == nil {
            ContinueGameSection(
              syncManager: self.syncManager
            )
          }
          
          Section(
            header: VStack(alignment: .leading) {
              if activeSaveGame == nil {
                Logo()
                Text("Welcome!").fontWeight(.bold)
                Text("Start a new game:").font(.system(size: 12))
              } else {
                Text("Start a new game:")
              }
            }
              .padding(.vertical)
              .foregroundStyle(Color(self.styleManager.colorScheme.board.cell.text.given))
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
              .listItemTint(
                Color(
                  self.styleManager.colorScheme.mode == .dark ? (
                    self.styleManager.colorScheme.ui.game.control.numpad.button.normal.background
                  ) : (
                    self.styleManager.colorScheme.ui.game.control.numpad.button.normal.text
                  )
                )
              )
              .foregroundColor(
                Color(
                  self.styleManager.colorScheme.mode == .dark ? (
                    self.styleManager.colorScheme.ui.game.control.numpad.button.normal.text
                  ) : (
                    self.styleManager.colorScheme.ui.game.control.numpad.button.normal.background
                  )
                )
              )
              .disabled(self.loadingNewGameForDifficulty != nil)
            }.confirmationDialog(
              Text("Start a new game?"),
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
                "Starting a new game will erase your current progress. Proceed?"
              )
            }
          }
          
          Section() {
            NavigationLink(
              destination:
                SettingsScreen(styleManager: self.styleManager)
            ) {
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
            .foregroundStyle(
              Color(self.styleManager.colorScheme.board.cell.text.player.valid)
            )
          }
        }
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
        isActive: $newGameConfirmed
      ) {}.hidden()
    }
    .onAppear() {
      Task {
        await self.syncManager.sync()        
      }
    }
  }
}

//#Preview {
//  NavigationView {
//    HomeScreen()
//      .environment(
//        \.managedObjectContext,
//         AppDataProvider.shared.container.viewContext
//      )
//  }
//}
