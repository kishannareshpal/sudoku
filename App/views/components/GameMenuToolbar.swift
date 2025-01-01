//
//  GameMenuToolbar.swift
//  sudoku
//
//  Created by Kishan Jadav on 28/08/2024.
//

import SwiftUI
import SpriteKit

struct GameMenuToolbar: View {
  @Environment(\.dismiss) var dismissScreen: DismissAction
  
  var gameScene: GameScene
  @Binding var cursorActivationMode: CursorActivationMode
  @Binding var exitedGame: Bool
  @State var backConfirmationShowing: Bool = false
  
  var body: some View {
    HStack {
      if (cursorActivationMode != .none) {
        // Cancel currently active number cell
        GameToolbarItem(
          label: cursorActivationMode == .note ? "Dismiss" : "Cancel",
          tint: cursorActivationMode == .note ? .yellow : .red,
          symbolName: "xmark.circle.fill"
        ) {
          withAnimation(.interactiveSpring) {
            let cursorState = gameScene.toggleCellUnderCursor(
              mode: .number,
              cancelled: true
            )
            self.cursorActivationMode = cursorState.activationMode
          }
        }
        .transition(
          .scale(scale: 1.1)
          .combined(with: .opacity)
        )
      } else {
        // Back button
        GameToolbarItem(
          label: "Back",
          tint: .white,
          symbolName: "chevron.backward.circle.fill"
        ) {
          self.backConfirmationShowing = true
        }
        .transition(
          .scale(scale: 1.1)
          .combined(with: .opacity)
        )
        .confirmationDialog(
          "Exit game?",
          isPresented: $backConfirmationShowing
        ) {
          Button("Cancel", role: .cancel) {}
          Button("Exit") {
            self.exitedGame = true
            self.dismissScreen()
          }
        } message: {
          Text(
            "Your progress is saved. You can resume at any time."
          )
        }
      }
    }
    .frame(
      maxWidth: .infinity,
      maxHeight: .infinity,
      alignment: .leading
    )
    .padding(
      .top,
      // We want to make the toolbar items inline with the clock
      // - To make it inline with that, on 40mm and lower watches,
      // there doesn't seem to be a need for the top padding but on other
      // watches higher than that there is a need.
      // - There's probably a better way of handling this! I couldn't for the
      // life of me figure it out. I
      WKInterfaceDevice.current().needsSafeTopPadding() ? 0 : nil
    )
    .padding(.leading)
  }
}

@available(watchOS 10.0, *)
#Preview {
  @Previewable @State var cursorCellActivationMode: CursorActivationMode = .none

  VStack {
    GameMenuToolbar(
      gameScene: GameScene(
        size: CGSize(width: 20, height: 20),
        crownRotationValue: .constant(0),
        gameOver: .constant(false),
        difficulty: .easy,
        existingGame: nil
      ),
      cursorActivationMode: $cursorCellActivationMode,
      exitedGame: .constant(false)
    )
    
    Spacer()
    
    // For preview purposes only:
    // - Simulates the activation of a cursor
    Button("Simulate cursor activation") {
      withAnimation(.snappy) {
        // Toggle
        cursorCellActivationMode =  cursorCellActivationMode == .none ? .number : .none
      }
    }
    
    // - Simulates the note mode activation on a cursor
    Button("Simulate note mode") {
      withAnimation(.snappy) {
        // Toggle
        cursorCellActivationMode =  cursorCellActivationMode == .none ? .note : .none
      }
    }
  }
}
