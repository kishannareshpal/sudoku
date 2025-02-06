//
//  ContentView.swift
//  MobileApp
//
//  Created by Kishan Jadav on 04/01/2025.
//

import SwiftUI

struct DatabaseScreen: View {
  @StateObject var game: Game
  
  var body: some View {
    VStack {
      Button("Clear all moves") {
//        MoveEntryEntityDataRepository.deleteAll()
//        SaveGameEntityDataService.updateMoveIndex(-1)
      }.buttonStyle(.bordered)
      
      List {
        if self.game.moves.isEmpty {
          Text("No moves recorded.")
        }
        
        ForEach(self.game.moves) { move in
          VStack(alignment: .leading) {
            HStack {
              if self.game.moveIndex == move.position {
                Image(systemName: "checkmark.circle.fill")
                  .foregroundStyle(.green)
              }

              Text("Move position: \(move.position)")
              Spacer()
//              Text("Value: \(move.value)")
            }
            
            Text("Location: \(move.locationNotation ?? "No value")")
            Text("Type: \(move.type ?? "No type")")
          }
        }
      }
    }
    .padding(.top, 12)
    
  }
}
