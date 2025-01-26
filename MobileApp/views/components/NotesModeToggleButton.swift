//
//  ControlButton.swift
//  sudoku
//
//  Created by Kishan Jadav on 08/01/2025.
//

import SwiftUI
import SpriteKit
import UIKit.UIColor
import UIColorHexSwift

struct NotesModeToggleButton: View {
  @ObservedObject var game: Game
  @ObservedObject var cursorState: CursorState

  private let vibrator = UIImpactFeedbackGenerator(style: .rigid)
  
  var iconSystemName: String {
    return self.isNotesModeToggled ? "circle.grid.3x3.fill" : "circle.grid.3x3"
  }
  
  var isNotesModeToggled: Bool {
    return self.cursorState.mode == .note
  }
  
  var isNotesModeToggleable: Bool {
    return !self.game.isGameOver && !self.game.isGamePaused
  }
  
  var body: some View {
    SegmentedPicker(
      selection: Binding(
        get: { cursorState.mode.rawValue },
        set: { cursorState.mode = CursorMode(rawValue: $0) ?? .number }
      ),
      options: ["Pen", "Notes"],
      isEnabled: isNotesModeToggleable
    )
    .scaledToFit()
    .frame(minWidth: 0)
  }
}

struct SegmentedPicker: UIViewRepresentable {
  @Binding var selection: Int
  var options: [String]
  var isEnabled: Bool = true
  
  func makeUIView(context: Context) -> UISegmentedControl {
    let segmentedControl = UISegmentedControl(items: options)
    segmentedControl.selectedSegmentIndex = selection
    segmentedControl.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged), for: .valueChanged)
    
    // Apply custom appearance locally
    let normalAttributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: UIColor.gray
    ]
    let selectedAttributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: UIColor.black,
      .font: UIFont.systemFont(ofSize: 14, weight: .bold)
    ]
    
    segmentedControl.setTitleTextAttributes(normalAttributes, for: .normal)
    segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
    
    segmentedControl.selectedSegmentTintColor = UIColor("#fff")
    segmentedControl.backgroundColor = UIColor("#141414")
    segmentedControl.isEnabled = isEnabled
    
    return segmentedControl
  }
  
  func updateUIView(_ uiView: UISegmentedControl, context: Context) {
    uiView.selectedSegmentIndex = selection
    uiView.isEnabled = isEnabled
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject {
    var parent: SegmentedPicker
    
    init(_ parent: SegmentedPicker) {
      self.parent = parent
    }
    
    @objc func valueChanged(_ sender: UISegmentedControl) {
      parent.selection = sender.selectedSegmentIndex
    }
  }
}
