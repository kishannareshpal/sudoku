//
//  BoardSprite.swift
//  sudoku
//
//  Created by Kishan Jadav on 03/04/2022.
//

import SpriteKit


class BoardSprite: SKSpriteNode {
  convenience init?(boardSize: CGSize, cellSize: CGSize) {
    let currentColorScheme = StyleManager.current.colorScheme
    
    UIGraphicsBeginImageContext(boardSize)
    
    guard let context = UIGraphicsGetCurrentContext() else {
      // Failed to initialize graphics context
      print("Failed to initialize graphics context")
      return nil
    }

    context.setShouldAntialias(false)
    
    // Draw the grid vertical and horizontal lines
    context.setLineWidth(1.0)
    context.setStrokeColor(currentColorScheme.board.stroke.inner.cgColor)
    
    for i in 1..<Board.rowsCount {
      if (i % 3 == 0) {
        // Skip the 3x3 grid division lines, as these have a thicker line width
        // so will be drawn on top, afterwards.
        continue
      }
      
      // Horizontal
      let y = CGFloat(i) * cellSize.height
      context.addLines(between: [CGPoint(x: 0, y: y), CGPoint(x: Double(boardSize.width), y: y)])

      // Vertical
      let x = CGFloat(i) * cellSize.width
      context.addLines(between: [CGPoint(x: x, y: 0), CGPoint(x: x, y: Double(boardSize.height))])
    }
    context.strokePath()
    
    // Draw the 3x3 grid division lines a bit thicker
    context.setLineWidth(2.0)
    context.setStrokeColor(currentColorScheme.board.stroke.outer.cgColor)
    for i in [3, 6] {
      // Horizontal
      let y = CGFloat(i) * cellSize.height
      context.addLines(between: [CGPoint(x: 0, y: y), CGPoint(x: Double(context.width), y: y)])
      // Vertical
      let x = CGFloat(i) * cellSize.width
      context.addLines(between: [CGPoint(x: x, y: 0), CGPoint(x: x, y: Double(context.height))])
    }
    context.strokePath()
    
    // Draw the board outer stroke
    let outerLineWidth = 1
    context.setLineWidth(Double(outerLineWidth))
    let outerRect = CGRect(
      x: 0,
      y: outerLineWidth,
      width: context.width - outerLineWidth,
      height: context.height - outerLineWidth
    )
    context.stroke(outerRect)
    context.strokePath()

    // Convert to UIImage to render
    if let image = UIGraphicsGetImageFromCurrentImageContext() {
      // Terminate all graphic related stuff
      UIGraphicsEndImageContext()
      
      // And apply the texture
      let boardTexture = SKTexture(image: image)
      boardTexture.filteringMode = currentDevice == .iphone ? .linear : .nearest

      self.init(texture: boardTexture, color: .clear, size: boardSize)
      return

    } else {
      print("Failed to get the final drawn image context")
      return nil
    }
  }
}
