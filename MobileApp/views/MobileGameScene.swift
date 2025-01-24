//
//  MobileGameScene.swift
//  sudoku
//
//  Created by Kishan Jadav on 08/01/2025.
//

import SwiftUI
import SpriteKit
import UIKit

class MobileGameScene: GameScene {
  @Published private(set) var cursorState: CursorState = .init()
  
  private var lastCursorLocation: Location = .zero
  private var cellSelectionVibrator = UIImpactFeedbackGenerator(style: .light)
  
  private var validNumberKeys = "1"..."9"
  
  override init(
    size: CGSize,
    difficulty: Difficulty
  ) {
    super.init(size: size, difficulty: difficulty)
    
    cellSelectionVibrator.prepare()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func sceneDidLoad() {
    super.sceneDidLoad()
    
    // Activate the initial cell on load
    self.game.moveCursor(
      to: self.game.cursorLocation,
      activateCellImmediately: true
    )
    
    self.lastCursorLocation = self.game.cursorLocation
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let touchLocation = touch.location(in: self)
    
    // Retrieve all nodes at the touch location, and iterate through each one that is a cell node
    let nodesAtTouchLocation = self.nodes(at: touchLocation)
    for node in nodesAtTouchLocation {
      guard let nodeName = node.name else { continue }
      guard Location.validateNotationFormat(nodeName) else { continue }
      
      // Cell nodes have their names as their location in notation format
      let newCursorLocation = Location(notation: nodeName)
      self.game.moveCursor(
        to: newCursorLocation,
        activateCellImmediately: true
      )
      
      let hasCursorLocationChanged = newCursorLocation != self.lastCursorLocation
      if hasCursorLocationChanged {
        self.lastCursorLocation = newCursorLocation
        self.onCursorLocationChanged()
      }
      
      print("Touched node: \(nodeName)")
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let touchLocation = touch.location(in: self)
    
    // Retrieve all nodes at the touch location
    let nodesAtTouchLocation = self.nodes(at: touchLocation)
    
    // Print the names of the nodes, if they have names
    for node in nodesAtTouchLocation {
      guard let nodeName = node.name else { continue }
      guard Location.validateNotationFormat(nodeName) else { continue }
      
      // Cell nodes have their names as their location in notation format
      let newCursorLocation = Location(notation: nodeName)
      self.game.moveCursor(
        to: newCursorLocation,
        activateCellImmediately: true
      )
      
      self.onCursorLocationChanged()
      
      print("Touched node: \(nodeName)")
    }
  }
  
  @available(iOS 17.0, *)
  func keyPressed(_ keyPress: KeyPress) -> KeyPress.Result {
    if self.isNumberKey(keyPress.characters) {
      let number = Int(keyPress.characters)!
      self.changeOrToggleActivatedNumberCellValueOrNote(with: number)
      return .handled
    }
    
    if keyPress.key == .delete || keyPress.key == .delete || keyPress.key == .clear || keyPress.characters == "0" {
      self.clearActivatedNumberCellValueAndNotes()
    }
    
    return .ignored
  }
  
  func changeOrToggleActivatedNumberCellValueOrNote(with number: Int) {
    if self.cursorState.mode == .note {
      self.toggleActivatedNumberCellNoteValue(with: number)
    } else {
      self.changeActivatedNumberCellValue(to: number)
    }
  }
  
  private func onCursorLocationChanged() {
    cellSelectionVibrator.impactOccurred()
  }
  
  private func isNumberKey(_ key: String) -> Bool {
    return validNumberKeys.contains(key)
  }
}
