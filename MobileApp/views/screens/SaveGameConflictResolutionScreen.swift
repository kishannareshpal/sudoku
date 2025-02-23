//
//  SaveGameConflictResolutionScreen.swift
//  sudoku
//
//  Created by Kishan Jadav on 13/02/2025.
//

import SwiftUI
import SpriteKit
import UIKit.UIColor
import UIColorHexSwift
import SwiftDate

struct SaveGameConflictResolutionScreen: View {
  @Environment(\.dismiss) var dismissScreen
  
  @State private var saveGameOptions: [SaveGameOption] = []
  @State private var selectedOptionId: UUID?
  @State private var confirming: Bool = false
  
  var onConfirmed: (_ syncResult: SyncResult) -> Void

  private func handleConfirm() async {
    guard
      let selectedOptionId,
      let selectedOption = saveGameOptions.first(where: { $0.id == selectedOptionId })
    else {
      return
    }
    
    Task {
      self.confirming = true
      
      let syncResult = await DataManager.default.saveGamesService.sync(
        forceOverwriteLocalWithCloud: selectedOption.location == .cloud,
        forceOverwriteCloudWithLocal: selectedOption.location == .device
      )

      self.onConfirmed(syncResult)

      self.confirming = false
      self.dismissScreen()
    }
  }

  var body: some View {
    ZStack(alignment: .topLeading) {
      Color(UIColor("#141414")).ignoresSafeArea()
      
      VStack(spacing: 0) {
        VStack {
          HStack(alignment: .center) {
            HStack(alignment: .center, spacing: 8) {            
              Button(
                action: {
                  self.dismissScreen()
                },
                label: {
                  Image(systemName: "multiply.circle.fill")
                    .font(.title2.bold())
                }
              )
              .tint(.white)
              
              Text("Your progress")
                .font(.title2.bold())
                .foregroundStyle(.white)
            }
            
            Spacer()
            
            Button(
              action: { Task { await self.handleConfirm() } },
              label: {
                HStack(spacing: 8) {
                  Text("Choose")
                  
                  if self.confirming {
                    ProgressView()
                  }
                }
              }
            )
            .tint(.accentColor)
            .disabled(self.selectedOptionId == nil || self.confirming)
          }
        }
        .padding()
        
        Divider().background(Color(UIColor("#222223")))
        
        ScrollView {
          VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
              Text("Different save games were found between your device and the cloud.")
              Text("Please choose the one you wish to keep everywhere:")
            }
            .font(.system(size: 14))
            .foregroundStyle(.white)
            
            ForEach(self.saveGameOptions, id: \.id) { option in
              SaveGameOptionCard(
                titleText: option.location == .device ? "On this device:" : "In the cloud:",
                difficultyText: option.difficultyText,
                updatedAt: option.updatedAt,
                isMostRecent: option.isMostRecent,
                puzzle: option.puzzle,
                isSelected: option.id == self.selectedOptionId
              ) {
                if self.selectedOptionId == option.id {
                  self.selectedOptionId = nil
                } else {
                  self.selectedOptionId = option.id
                }
              }
            }
          }
          .padding()
          .task {
            await loadSaveGames()
          }
        }
      }
    }
  }
  
  private func loadSaveGames() async {
    let activeCloudSaveGame = await DataManager.default.saveGamesService
      .findActiveCloudSaveGame()
    
    let activeLocalSaveGame = DataManager.default.saveGamesService
      .findActiveLocalSaveGame()

    if let activeLocalSaveGame {
      let isMostRecent: Bool = activeCloudSaveGame != nil
        ? activeLocalSaveGame.updatedAt! > activeCloudSaveGame!.updatedAt
        : true
      
      self.saveGameOptions.append(
        .init(
          location: .device,
          updatedAt: activeLocalSaveGame.updatedAt!,
          isMostRecent: isMostRecent,
          difficultyText: activeLocalSaveGame.difficulty!,
          puzzle: .init(saveGame: activeLocalSaveGame)
        )
      )
    }
    
    if let activeCloudSaveGame {
      let isMostRecent: Bool = activeLocalSaveGame != nil
        ? activeCloudSaveGame.updatedAt > activeLocalSaveGame!.updatedAt!
        : true
      
      self.saveGameOptions.append(
        .init(
          location: .cloud,
          updatedAt: activeCloudSaveGame.updatedAt,
          isMostRecent: isMostRecent,
          difficultyText: activeCloudSaveGame.difficulty,
          puzzle: .init(saveGameStruct: activeCloudSaveGame)
        )
      )
      
      // Sort options by updatedAt in descending order
      self.saveGameOptions.sort { $0.updatedAt > $1.updatedAt }
    }
  }
}

struct SaveGameOption: Identifiable {
  var id = UUID()

  var location: SaveGameLocation
  var updatedAt: Date
  var isMostRecent: Bool
  var difficultyText: Difficulty.RawValue
  var puzzle: Puzzle
  
  enum SaveGameLocation {
    case device, cloud
  }
}

struct SaveGameOptionCard: View {
  var titleText: String
  var difficultyText: Difficulty.RawValue
  var updatedAt: Date
  var isMostRecent: Bool
  var puzzle: Puzzle
  var isSelected: Bool
  var onTap: () -> Void
    
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(alignment: .center) {
        Image(
          systemName: self.isSelected
            ? "checkmark.circle.fill"
            : "circle"
        )
        .foregroundStyle(self.isSelected ? Color(UIColor("#F0B719")) : .white)
        .font(.system(size: 24))
        
        Spacer()
        
        if isMostRecent {
          Text("Most recent")
            .font(.caption)
        }
      }
      
      VStack(alignment: .leading, spacing: 4) {
        Text(titleText).fontWeight(.bold)
        
        VStack(alignment: .leading, spacing: 2) {
          Text("Last played: \(self.updatedAt.toFormat("dd MMM yyyy 'at' HH:mm"))").font(.caption)
          Text("Difficulty: \(self.difficultyText)").font(.caption)
        }
      }
      
      Spacer(minLength: 1)
      
      PreviewGameSceneView(
        puzzle: puzzle
      ).scaledToFill()
    }
    .foregroundStyle(.white)
    .padding()
    .background(Color(UIColor("#0F0F0F")))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(self.isSelected ? Color(UIColor("#F0B719")) : Color(UIColor("#303030")), lineWidth: 1)
    )
    .scaleEffect(self.isSelected ? 1.01 : 1)
    .animation(.easeOut(duration: 0.2), value: self.isSelected)
    .onTapGesture {
      self.onTap()
    }
  }
}
