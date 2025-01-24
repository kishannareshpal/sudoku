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
  
  @State private var currentGame: SaveGameEntity?
  
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
          
          ContinueGameButton()
          
          VStack(spacing: 12) {
            Text("Start a new game:")
              .fontWeight(.bold)
              .foregroundStyle(.white)
            
            VStack(spacing: 8) {
              ForEach(Difficulty.allCases) { difficulty in
                if currentGame != nil {
                  Button {
                    self.newGameConfirmationDifficulty = difficulty
                    self.newGameConfirmationShowing = true
                  } label: {
                    NewGameButtonContent(difficulty: difficulty)
                  }.buttonStyle(NormalButtonStyle())
                } else {
                  NavigationLink(
                    destination: GameScreen(difficulty: difficulty)
                      .navigationBarBackButtonHidden()
                  ) {
                    NewGameButtonContent(difficulty: difficulty)
                  }.buttonStyle(NormalButtonStyle())
                }
              }
              .confirmationDialog(
                "Start a new game?",
                isPresented: $newGameConfirmationShowing,
                titleVisibility: .visible
              ) {
                Button("Cancel", role: .cancel) {}
                Button("New game", role: .destructive) {
                  SaveGameEntityDataService.delete()
                  self.currentGame = nil
                  self.newGameConfirmed = true
                }
    
              } message: {
                VStack {
                  Text(
                    "Your existing game progress will be discarded when you start a new game of \(newGameConfirmationDifficulty?.rawValue ?? "") difficulty."
                  )
                }
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
        destination: GameScreen(difficulty: self.newGameConfirmationDifficulty ?? .easy)
          .navigationBarBackButtonHidden(),
        isActive: $newGameConfirmed
      ) {}.hidden()
    }
    .onAppear {
      self.loadLastGame()
    }

  }
  
  private func loadLastGame() {
    self.currentGame = SaveGameEntityDataService.findCurrentGame()
  }
}

#Preview {
  ContentView()
}
