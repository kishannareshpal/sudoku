//
//  NumberCellSprite.swift
//  sudoku
//
//  Created by Kishan Jadav on 08/01/2023.
//

import SpriteKit
import UIColorHexSwift

class NumberCellSprite: SKSpriteNode {
  static let NUMBER_VALUE_CHANGING_AMOUNT = 0.1
  static let NOTE_VALUE_CHANGING_AMOUNT = 0.1
  
  private(set) var label: SKLabelNode = SKLabelNode(fontNamed: Theme.Fonts.mono)

  private var notesNode: SKNode = SKNode()
  private(set) var notes: [NumberCellNoteSprite] = []

  private(set) var isStatic: Bool
  private(set) var location: Location
  private(set) var highlighted: Bool = false
  
  private(set) var value: Int = 0
  private(set) var valid: Bool = true

  private var draftNumberValue: Double = 0.0
  private var draftNoteValue: Double = 0.0
  
  var numberValueToBeCommitted: Int {
    return round(self.draftNumberValue).toInt()
  }
  
  var noteValueToBeCommitted: Int {
    return round(self.draftNoteValue).toInt()
  }

  var isChangeable: Bool {
    return !self.isStatic
  }
  
  /// Whether or not a note can be added or removed from this cell
  /// - Can only add notes to a changeable cell and when it has no value on it
  var isNotable: Bool {
    return self.value == 0
  }
  
  init(
    size: CGSize,
    location: Location,
    value: Int,
    isStatic: Bool
  ) {
    self.value = value
    self.isStatic = isStatic
    self.location = location
    
    if (!self.isStatic) {
      self.draftNumberValue = value.toDouble()
    }

    super.init(texture: nil, color: .clear, size: size)
    
    // Use the cell's location notation as the name for easy identification
    self.name = location.notation
    self.draw()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func move(to position: CGPoint) {
    self.position = position
  }

  func changeDraftNumberValue(direction: Direction) -> Void {
    guard self.isChangeable else { return }
    
    if direction == .forward {
      self.draftNumberValue += NumberCellSprite.NUMBER_VALUE_CHANGING_AMOUNT
    } else {
      self.draftNumberValue -= NumberCellSprite.NUMBER_VALUE_CHANGING_AMOUNT
    }
    
    // Clamp the value to 0 through 9:
    if (self.draftNumberValue > 9) {
      self.draftNumberValue = 9.0
      
    } else if (self.draftNumberValue <= 0) {
      self.draftNumberValue = 0.0
    }

    // Only show the notes note when changing to a non-empty value
    self.toggleNotesVisibility(visible: self.draftNumberValue == 0)

    self.updateLabelText(with: self.numberValueToBeCommitted)
  }
  
  func hasNotes() -> Bool {
    return !self.notes.isEmpty
  }
  
  func clearNotes() -> Void {
    self.notes.removeAll()
    self.notesNode.removeAllChildren()
  }
  
  func toggleNotesVisibility(visible: Bool) {
    // TODO: Use this non-animated version if the other one is too much
//    self.notesNode.isHidden = !visible

    // TODO: Experiment with animated first
    if visible {
      self.notesNode.run(SKAction.fadeIn(withDuration: 0.1))
    } else {
      self.notesNode.run(SKAction.fadeOut(withDuration: 0.1))
    }
  }
  
  func toggleNotes(of values: [Int], animate: Bool = true) async {
    values.forEach { value in
      Task {
        await self.toggleNote(of: value, animate: animate)
      }
    }
  }
  
  func toggleNote(of value: Int, animate: Bool = true) async {
    let existingNote = self.notes.first { record in
      record.value == value
    }

    if let existingNote = existingNote {
      await existingNote.toggleVisibility(visible: false, animated: animate)
      
      existingNote.removeFromParent()
      self.notes.removeAll { record in
        record.value == value
      }

    } else {
      let noteSprite = NumberCellNoteSprite(containerSize: size, value: value)
      self.notes.append(noteSprite)
      self.notesNode.addChild(noteSprite)

      await noteSprite.toggleVisibility(visible: true, animated: animate)
    }
  }
  
  func changeDraftNoteValue(direction: Direction) async {
    guard self.isChangeable else { return }

    if direction == .forward {
      self.draftNoteValue += NumberCellSprite.NOTE_VALUE_CHANGING_AMOUNT
    } else {
      self.draftNoteValue -= NumberCellSprite.NOTE_VALUE_CHANGING_AMOUNT
    }
    
    // Clamp the value to 0 through 9:
    if (self.draftNoteValue > 9) {
      self.draftNoteValue = 9.0
      
    } else if (self.draftNoteValue <= 0) {
      self.draftNoteValue = 0.0
    }
  }
  
  func discardDraftNumberValueChange() -> Void {
    self.draftNumberValue = self.value.toDouble()
    self.updateLabelText(with: self.value)

    // Only show the notes note when the cell value is empty
    self.toggleNotesVisibility(visible: self.value == 0)
  }
  
  func commitValueChange() -> Void {
    self.value = self.numberValueToBeCommitted
    self.updateLabelText(with: self.value)
  }
  
  func resetValidation() {
    // The same as a valid cell
    self.toggleValidation(valid: true)
  }
  
  func toggleValidation(valid: Bool) {
    guard self.isChangeable else { return }
    
    if (valid) {
      self.label.fontColor = Theme.Cell.Number.Dynamic.text
    } else {
      self.label.fontColor = Theme.Cell.Number.Dynamic.invalidText
    }
    
    self.valid = valid
  }
  
  func highlight() {
    guard !self.highlighted else { return }
    
    self.color = Theme.Cell.Number.Highlight.bg
    self.highlighted = true;
  }
  
  func unhighlight() {
    guard self.highlighted else { return }
    
    self.color = Theme.Cell.Number.bg
    self.highlighted = false
  }

  private func draw() {
    self.updateLabelText(with: self.value)

    self.label.fontColor = self.isStatic
      ? Theme.Cell.Number.Static.text
      : Theme.Cell.Number.Dynamic.text

    self.label.fontSize = self.size.width * 0.65
    self.label.numberOfLines = 1
    self.label.verticalAlignmentMode = .center
    self.label.horizontalAlignmentMode = .center
    self.label.zPosition = ZIndex.Cell.label
    self.addChild(self.label)
    
    self.notesNode.zPosition = ZIndex.Cell.label
    self.addChild(self.notesNode)
  }
  
  private func updateLabelText(with value: Int) {
    self.label.text = (value != 0) ? value.toString() : ""

    let scale = SKAction.sequence([
      SKAction.scale(to: 1.3, duration: 0.1),
      SKAction.scale(to: 1.0, duration: 0.1)
    ])
    self.label.run(scale)
  }
}
