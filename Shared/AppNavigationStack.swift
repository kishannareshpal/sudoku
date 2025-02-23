//
//  AppNavigationStack.swift
//  sudoku
//
//  Created by Kishan Jadav on 23/02/2025.
//

import SwiftUI

struct AppNavigationStack<Content: View>: View {
  let content: Content
  
  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  
  var body: some View {
    if #available(iOS 16.0, *), #available(watchOS 9.0, *) {
      NavigationStack {
        content
      }
    } else {
      NavigationView {
        content
      }
    }
  }
}
