//
//  ContentView.swift
//  MobileApp
//
//  Created by Kishan Jadav on 04/01/2025.
//

import SwiftUI
import Combine
import WatchConnectivity

struct ContentView: View {
  @StateObject var manager = SharedSaveGameManager.instance
  
  var body: some View {
    VStack {
      Text("MiniSudoku")
        .font(.largeTitle)
        .fontWeight(.bold)
      
      Text("Data: \(manager.currentValue.playerNotation)")
        .font(.callout)
      
      Button("Send") {
        manager.sendSample()
      }.buttonStyle(.bordered)
        .foregroundStyle(.black)
    }
    .padding()
  }
}

#Preview {
    ContentView()
}
