//
//  GameOverOverlay.swift
//  sudoku
//
//  Created by Kishan Jadav on 28/08/2024.
//

import SwiftUI
import UIColorHexSwift

struct GameOverOverlay: View {
  @Environment(\.dismiss) var dismissScreen: DismissAction
  @State private var animateGameOverOverlayBackground: Bool = false
  
  @State private var animate: Bool = false
  
  var body: some View {
    LinearGradient(
      colors: [Color(Theme.Colors.primaryDark), .black],
      startPoint: .top,
      endPoint: .bottom
    )
      .hueRotation(.degrees(animateGameOverOverlayBackground ? 360 : 0))
      .onAppear {
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
          animateGameOverOverlayBackground.toggle()
        }
      }
      .blur(radius: 5)
      .ignoresSafeArea()
      .onAppear() {
        animate.toggle()
      }
    
    GeometryReader { geometry in
      ScrollView(showsIndicators: false) {
        VStack {
          Spacer()
          
          Image("Trophy")
            .resizable()
            .frame(width: 64, height: 64)
            .tint(.white)
          
          Spacer(minLength: 8)

          Text("Well done!")
            .font(.headline)
            .fontWeight(.black)
          
          Text("You've completed this puzzle.")
            .font(.system(size: 12))
            .fontWeight(.regular)
            .multilineTextAlignment(.center)
          
          Text("Up for another challenge?")
            .font(.system(size: 12))
            .fontWeight(.regular)
            .multilineTextAlignment(.center)
          
          Spacer(minLength: 12)
          
          Button {
            // Navigate back to home
            self.dismissScreen()
          } label: {
            Image(systemName: "plus")
            Text("New game")
          }
          
          Spacer()
        }
          .frame(width: geometry.size.width)
          .frame(minHeight: geometry.size.height)
      }
      .frame(maxWidth: .infinity, maxHeight:.infinity)
    }
  }
}


#Preview {
  Color.clear
    .ignoresSafeArea()
    .overlay(alignment: .center) {
      GameOverOverlay()
    }
}
