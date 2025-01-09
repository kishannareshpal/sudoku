//
//  SessionDelegator.swift
//  sudoku
//
//  Created by Kishan Jadav on 04/01/2025.
//

import Combine
import WatchConnectivity

public class SessionDelegator: NSObject, WCSessionDelegate {
  let valueSubject: PassthroughSubject<OTASaveGameEntity, Never>
  
  init(valueSubject: PassthroughSubject<OTASaveGameEntity, Never>) {
    self.valueSubject = valueSubject
    super.init()
  }
  
  public func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
  }
  
  public func session(
    _ session: WCSession,
    didReceiveMessage message: [String: Any]
  ) {
    DispatchQueue.main.async {
      if let serializedValue = message["saveGameEntity"] as? String {
        if let value = OTASaveGameEntity.fromJSON(serializedValue) {
          self.valueSubject.send(value)
        }
      } else {
        print("There was an error")
      }
    }
  }

#if os(iOS)
  public func sessionDidBecomeInactive(_ session: WCSession) {
    print("\(#function): activationState = \(session.activationState.rawValue)")
  }
  
  public func sessionDidDeactivate(_ session: WCSession) {
    // Activate the new session after having switched to a new watch.
    session.activate()
  }
  
  public func sessionWatchStateDidChange(_ session: WCSession) {
    print("\(#function): activationState = \(session.activationState.rawValue)")
  }
#endif
}
