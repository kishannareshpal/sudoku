//
//  HighlightCell.swift
//  Sudoku WatchKit Extension
//
//  Created by Kishan Jadav on 15/01/2023.
//

import SpriteKit

class CursorCellSprite: SKShapeNode {
  private(set) var size: CGSize
  private(set) var location: Location
  private(set) var active: Bool = false
  private(set) var activeMode: CursorActivationMode = .none
  
  init(size: CGSize, initialPostion: CGPoint, initialLocation: Location) {
    self.size = size
    self.location = initialLocation

    super.init()

    self.position = initialPostion
    self.draw()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented. This should never be called")
  }
  
  func activate(mode: CursorActivationMode) {
    if (self.active) {
      // Already activated, do nothing
      return
    }
    
    self.active = true
    self.activeMode = mode
    self.startBlinking()
  }
  
  func deactivate() {
    if (!self.active) {
      // Already deactivated, do nothing
      return
    }
    
    self.active = false
    self.activeMode = .none
    self.stopBlinking()
  }
  
  func move(to position: CGPoint, location: Location) {
    self.position = position
    self.location = location
  }
  
  private func draw() {
    let bottomLeftPoint = CGPoint(x: -self.size.width / 2.0,
                                  y: -self.size.height / 2.0)

    self.path = UIBezierPath(
      rect: CGRect(
        origin: bottomLeftPoint,
        size: size
      )
    ).cgPath
                             
    self.name = "Cursor"
    self.lineWidth = Theme.Cell.Cursor.outlineWidth
    self.fillColor = Theme.Cell.Cursor.bg
    self.strokeColor = Theme.Cell.Cursor.outline
    self.zPosition = ZIndex.Cell.cursor
  }
  
  private func startBlinking() {
    let blink = SKAction.sequence([
      SKAction.fadeOut(withDuration: 0.4),
      SKAction.fadeIn(withDuration: 0.4)
    ])
    let blinkForever = SKAction.repeatForever(blink)
    self.run(blinkForever, withKey: "blink")
  }
  
  private func stopBlinking() {
    self.alpha = 1
    self.removeAction(forKey: "blink")
  }
}
