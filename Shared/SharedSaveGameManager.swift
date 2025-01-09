//
//  Counter.swift
//  sudoku
//
//  Created by Kishan Jadav on 04/01/2025.
//

import Foundation
import Combine
import WatchConnectivity

public class SharedSaveGameManager: ObservableObject {
  static let instance = SharedSaveGameManager()

  let session: WCSession = .default

  let delegate: WCSessionDelegate
  
  let subject = PassthroughSubject<OTASaveGameEntity, Never>()
  @Published private(set) var currentValue: OTASaveGameEntity = .init(
    durationInSeconds: 0,
    score: 0
  )
  
  private init() {
    self.delegate = SessionDelegator(valueSubject: subject)
    self.session.delegate = self.delegate
    self.session.activate()
    
    subject
      .receive(on: DispatchQueue.main)
      .assign(to: &$currentValue)
  }
  
  
  func share(entity: OTASaveGameEntity) {
    currentValue = entity
    
    let serializedValue = entity.toJSON()
    session.transferUserInfo(["saveGameEntity": serializedValue])
    
    session
      .sendMessage(
        ["saveGameEntity": serializedValue],
        replyHandler: nil
      ) { error in
        print(error.localizedDescription)
      }
  }
  
  func sendSample() {
    let newValue = OTASaveGameEntity(
      updatedAt: Date()
    )
    
    currentValue = newValue
    
    let serializedValue = newValue.toJSON()
    session.transferUserInfo(["saveGameEntity": serializedValue])
    
    session
      .sendMessage(
        ["saveGameEntity": serializedValue],
        replyHandler: nil
      ) { error in
      print(error.localizedDescription)
    }
  }
}
