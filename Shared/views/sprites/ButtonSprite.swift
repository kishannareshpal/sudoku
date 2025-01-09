//
//  ButtonSprite.swift
//  sudoku
//
//  Created by Kishan Jadav on 25/08/2024.
//

import SpriteKit

class ButtonSprite: SKShapeNode {
  private(set) var label: SKLabelNode = SKLabelNode(
    fontNamed: Theme.Fonts.emphasis
  )
  
  init(position: CGPoint, labelText: String, fontColor: SKColor) {
    super.init()
    self.position = position

    self.draw(labelText: labelText, fontColor: fontColor)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented. This should never be called")
  }
  
  func toggleVisibility(hidden: Bool) {
    self.isHidden = hidden
  }
  
  private func draw(labelText: String, fontColor: SKColor) {
    self.name = "Button"
    self.zPosition = ZIndex.Cell.cursor

    self.label.fontColor = fontColor
    self.label.fontSize = 15
    self.label.numberOfLines = 1
    self.label.verticalAlignmentMode = .center
    self.label.horizontalAlignmentMode = .left
    self.label.zPosition = ZIndex.Cell.label
    self.label.text = labelText

    self.addChild(self.label)
  }
}
