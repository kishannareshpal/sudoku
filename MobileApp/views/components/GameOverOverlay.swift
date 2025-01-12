//
//  GameOverOverlay.swift
//  sudoku
//
//  Created by Kishan Jadav on 12/01/2025.
//

import SwiftUI

struct GameOverOverlay: View {
  @Environment(\.dismiss) var dismissScreen: DismissAction
  
  var body: some View {
    ZStack {
      Color(UIColor("#352800"))
        .opacity(0.9)
        .ignoresSafeArea()
      
      VStack {
        Spacer()

        Image("Trophy")
          .tint(.white)
        
        VStack(alignment: .center) {
          Text("Well done!")
            .font(.system(size: 48, weight: .bold))
            .foregroundStyle(.accent)
          
          Text("You solved this Hard puzzle in 1h43m23s.")
            .font(.system(size: 24, weight: .regular))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
        }
        
        Spacer()
        
        VStack(spacing: 14) {
          Text("Up for another challenge?")
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.white)
          
          Button(action: { dismissScreen() }) {
            HStack {
              Text("New game")
                .fontWeight(.bold)
                .foregroundStyle(.black)
              
              Spacer()
              
              Image(systemName: "plus")
                .foregroundStyle(.black)
            }
          }.buttonStyle(NormalButtonStyle(backgroundColor: .accent))
        }
      }
      .padding(24)
    }
  }
}
