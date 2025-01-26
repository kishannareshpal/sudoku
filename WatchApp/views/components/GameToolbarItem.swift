//
//  GameToolbarItem.swift
//  sudoku
//
//  Created by Kishan Jadav on 28/08/2024.
//

import SwiftUI

struct GameToolbarItem: View {
  private let label: String?
  private let labelColor: Color
  private let symbolColor: Color
  private let symbolName: String?
  private let action: (() -> Void)?
  
  init(
    label: String? = nil,
    labelColor: Color = .white,
    symbolColor: Color = .white,
    symbolName: String? = nil,
    action: (() -> Void)? = nil
  ) {
    self.label = label
    self.labelColor = labelColor
    self.symbolName = symbolName
    self.symbolColor = symbolColor
    self.action = action
  }
  
  init(
    label: String? = nil,
    tint: Color = .white,
    symbolName: String? = nil,
    action: (() -> Void)? = nil
  ) {
    self.init(
      label: label,
      labelColor: tint,
      symbolColor: tint,
      symbolName: symbolName,
      action: action
    )
  }
  
  var body: some View {
    GameToolbarItemContainer(action: action) {
      HStack(alignment: .center) {
        Group {
          if let symbolName {
            Image(systemName: symbolName)
              .foregroundStyle(symbolColor)
          }
          
          if let label {
            Text(label)
              .font(.caption)
              .fontWeight(.medium)
              .foregroundStyle(labelColor)
          }
        }
      }
    }
  }
}

private struct GameToolbarItemContainer<Content: View>: View {
  private(set) var action: (() -> Void)? = nil
  private(set) var content: Content
  
  init(action: (() -> Void)?, @ViewBuilder content: () -> Content) {
    self.init(content: content)
    self.action = action
  }
  
  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  
  var body: some View {
    if let action {
      // If action is provided, wrap the content into a button
      Button(action: action) {
        content
      }
      .buttonStyle(.plain)

    } else {
      // If no action is provided, just display the content
      content
    }
  }
}


#Preview {
  ScrollView {
    VStack(alignment: .leading, spacing: 12) {
      GameToolbarItem(symbolName: "person.wave.2.fill")
      
      GameToolbarItem(label: "Label on its own")
      
      GameToolbarItem(label: "Label with icon", symbolName: "scribble.variable")
      
      GameToolbarItem(
        label: "Label with colored icon",
        symbolColor: Color(Theme.Colors.primary),
        symbolName: "pencil.circle.fill"
      )
      
      GameToolbarItem(
        label: "Colored label and icon",
        labelColor: .blue,
        symbolColor: .blue,
        symbolName: "magazine.fill"
      )
      
      GameToolbarItem(
        label: "Tappable",
        symbolName: "plus.circle"
      ) {
        print("Hello")
      }
    }
  }.ignoresSafeArea(edges: .horizontal)
}
