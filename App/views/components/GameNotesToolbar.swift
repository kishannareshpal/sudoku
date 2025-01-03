//
//  GameNotesToolbar.swift
//  sudoku
//
//  Created by Kishan Jadav on 31/08/2024.
//

import SwiftUI
import SpriteKit

enum GameNotesToolbarPosition {
  case top
  case bottom
}


struct GameNotesToolbar: View {
  var gameScene: GameScene
  @Binding var cursorState: CursorState
  
  @State private var releaseNoteModeConfirmationShowing: Bool = false

  var selectedNumber: Int {
    // Applying the `preActivationModeChangeCrownRotationValue` offset ensures that the selectedNumber always
    // starts with zero when the notes toolbar is shown to the user
    let value = round(self.cursorState.crownRotationValue).toInt()
    return (value % 9) + 1
  }
  
  var position: GameNotesToolbarPosition {
    let pastMiddleRow = self.cursorState.location.row.toDouble() > Board.rowsCount.half()
    
    // Show the notes toolbar at the top if the cursor is past somewhere at one of the last rows,
    // otherwise show the toolbar at the bottom.
    return pastMiddleRow ? .top : .bottom
  }
  
  func untoggleCellUnderCursor() {
    let newCursorState = self.gameScene.toggleCellUnderCursor(mode: .none, cancelled: true)
    
    withAnimation(.smooth) {
      self.cursorState = newCursorState
    }
  }
  
  var tappableTargetView: some View {
    Color.clear
      .contentShape(Rectangle())
      .onTapGesture {
        Task {
          await self.gameScene
            .applyActivatedNumberCellNoteValue(to: selectedNumber)
        }
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
    if (self.cursorState.activationMode == .note) {
      ZStack {
        VStack {
          if (position == .bottom) {
            tappableTargetView
          }
          
          Content(
            gameScene: gameScene,
            selectedNumber: selectedNumber,
            position: position
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

struct Content: View {
  var gameScene: GameScene
  var selectedNumber: Int
  var position: GameNotesToolbarPosition
  
  var body: some View {
    VStack {
      HStack() {
        // Cancel currently active number cell
        ForEach(1..<10) { number in
          Spacer()
          
          Button {
            Task {
              await gameScene
                .applyActivatedNumberCellNoteValue(to: number)
            }
          } label: {
            VStack {
              Circle()
                .frame(width: 8, height: 8)
                .foregroundStyle(
                  self.selectedNumber == number
                  ? Color(NumberCellNoteSprite.color(for: number))
                  : Color(NumberCellNoteSprite.color(for: number)).opacity(0.3)
                )
              
              Text(number.toString())
                .font(.custom(Theme.Fonts.mono, size: 12))
            }
          }
          .buttonStyle(.plain)
          .foregroundStyle(
            self.selectedNumber == number
            ? Color(NumberCellNoteSprite.color(for: number))
            : .white.opacity(0.3)
          )
          
          Spacer()
        }
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
  }
}


@available(watchOS 10.0, *)
#Preview {
  @Previewable @State var cursorState: CursorState = .init(
    activationMode: .none,
    location: .zero,
    crownRotationValue: 0.0,
    preActivationModeChangeCrownRotationValue: 0.0
  )
  
  VStack {
    // For preview purposes only:
    // - Simulates the cursor activation that on a real application is triggered
    // by tapping on the game scene.
    Button("Simulate cursor activation") {
      withAnimation(.snappy) {
        cursorState.activationMode = cursorState.activationMode == .none ? .note : .none
      }
    }
    
    Spacer()
    
    GameNotesToolbar(
      gameScene: GameScene(
        size: CGSize(width: 20, height: 20),
        crownRotationValue: .constant(0),
        gameOver: .constant(false),
        difficulty: .easy,
        existingGame: nil
      ),
      cursorState: $cursorState
    ).scaledToFit()
  }
}

