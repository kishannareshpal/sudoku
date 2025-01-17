//
//  GameNotesToolbar.swift
//  sudoku
//
//  Created by Kishan Jadav on 31/08/2024.
//

import SwiftUI
import SpriteKit

struct GameNotesToolbar: View {
  var gameScene: WatchGameScene
  @ObservedObject var cursorState: CursorState

  @State private var releaseNoteModeConfirmationShowing: Bool = false

  var selectedNumber: Int {
    // TODO: Applying the `preModeChangeCrownRotationValue` offset ensures that the selectedNumber always
    // starts with zero when the notes toolbar is shown to the user
    let value = round(self.cursorState.crownRotationValue).toInt()
    return (value % 9) + 1
  }
  
  var position: GameNotesToolbarPosition {
    let pastMiddleRow = self.gameScene.game.cursorLocation.row.toDouble() > Board.rowsCount.half()
    
    // Show the notes toolbar at the top if the cursor is past somewhere at one of the last rows,
    // otherwise show the toolbar at the bottom.
    return pastMiddleRow ? .top : .bottom
  }
  
  func untoggleCellUnderCursor() {
    self.gameScene.toggleCellUnderCursor(mode: .none, cancelled: true)
  }
  
  var tappableTargetView: some View {
    Color.clear
      .contentShape(Rectangle())
      .onTapGesture {
        self.gameScene.toggleActivatedNumberCellNoteValue(
          with: selectedNumber
        )
      }
      .onLongPressGesture {
        // Toggle notes mode OFF?
        self.releaseNoteModeConfirmationShowing = true
      }
      .confirmationDialog(
        "Notes",
        isPresented: $releaseNoteModeConfirmationShowing
      ) {
        Button("Just Dismiss") {
          // Just untoggle and maintain the current notes
          self.untoggleCellUnderCursor()
          self.releaseNoteModeConfirmationShowing = false
        }
        Button("Clear & Dismiss", role: .destructive) {
          // Clear all of the notes from this cell
          self.gameScene.clearActivatedNumberCellNotes()
          
          // Then untoggle the cell from notes mode
          self.untoggleCellUnderCursor()
        }
      } message: {
        Text(
          "Tap 'Dismiss' to close notes input, or 'Clear' to erase all notes from this cell."
        )
      }
  }

  var body: some View {
    if (self.cursorState.mode == .note) {
      ZStack {
        VStack {
          if (position == .bottom) {
            tappableTargetView
          }
          
          HStack {
            ForEach(1..<10) { number in
              Spacer()
              
              GameNotesToolbarNumberButton(
                number: number,
                selected: self.selectedNumber == number,
                onPress: {
                  self.gameScene.toggleActivatedNumberCellNoteValue(with: number)
                }
              )
              
              Spacer()
            }
          }
          .padding(.top, self.position == .bottom ? 6 : 0)
          .padding(.bottom, self.position == .top ? 6 : 0)
          .background(
            Color.black
              .opacity(0.8)
              .shadow(color: .black, radius: 10)
              .ignoresSafeArea()
          )
          
          if (position == .top) {
            tappableTargetView
          }
        }
        
      }
      .frame(
        maxWidth: .infinity,
        maxHeight: .infinity,
        alignment: position == .bottom ? .bottom : .top
      )
      .transition(
        .opacity
          .combined(
            with: .move(edge: position == .bottom ? .bottom : .top)
          ).animation(.smooth)
      )
    }
  }
}




//@available(watchOS 10.0, *)
//#Preview {
//  @Previewable @State var cursorState: CursorState = .init(
//    mode: .none,
//    crownRotationValue: 0.0,
//    preModeChangeCrownRotationValue: 0.0
//  )
//  
//  VStack {
//    // For preview purposes only:
//    // - Simulates the cursor activation that on a real application is triggered
//    // by tapping on the game scene.
//    Button("Simulate cursor activation") {
//      withAnimation(.snappy) {
//        cursorState.mode = cursorState.mode == .none ? .note : .none
//      }
//    }
//    
//    Spacer()
//    
//    GameNotesToolbar(
//      gameScene: WatchGameScene(
//        size: CGSize(width: 20, height: 20),
//        gameOver: .constant(false),
//        difficulty: .easy,
//        existingGame: nil,
//        cursorState: $cursorState
//      ),
//      cursorState: $cursorState
//    ).scaledToFit()
//  }
//}
//
