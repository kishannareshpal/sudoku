//
//  AppConfig.swift
//  sudoku
//
//  Created by Kishan Jadav on 04/01/2025.
//

import Foundation

public class AppConfig {
  static func getHighlightOrientation() -> LocationIndexOrientation {
    UserDefaults.standard.register(defaults: [UserDefaultKey.highlightOrientation.rawValue: LocationIndexOrientation.topToBottom.rawValue])

    return LocationIndexOrientation(
      rawValue: UserDefaults.standard.string(
        forKey: UserDefaultKey.highlightOrientation.rawValue
      )!
    )!
  }
  
  static func preferredColorSchemeName() -> ColorSchemeName {
    UserDefaults.standard.register(defaults: [UserDefaultKey.colorSchemeName.rawValue: ColorSchemeName.darkYellow.rawValue])

    let rawColorSchemeName = UserDefaults.standard.string(
      forKey: UserDefaultKey.colorSchemeName.rawValue,
    )!;
    
    return ColorSchemeName(
      rawValue: rawColorSchemeName
    )!
  }
  
  static func isHapticFeedbackEnabled() -> Bool {
    UserDefaults.standard.register(defaults: [UserDefaultKey.hapticFeedbackEnabled.rawValue: true])

    return UserDefaults.standard.bool(
      forKey: UserDefaultKey.hapticFeedbackEnabled.rawValue,
    );
  }
  
  static func prefersOffline() -> Bool {
    UserDefaults.standard.register(defaults: [UserDefaultKey.offline.rawValue: true])

    return UserDefaults.standard.bool(
      forKey: UserDefaultKey.offline.rawValue,
    );
  }
  
  static func shouldAutoRemoveNotes() -> Bool {
    UserDefaults.standard.register(defaults: [UserDefaultKey.autoRemoveNotes.rawValue: true])

    return UserDefaults.standard.bool(
      forKey: UserDefaultKey.autoRemoveNotes.rawValue,
    )
  }
  
  static func prefersStartingInNotesMode() -> Bool {
    UserDefaults.standard.register(defaults: [UserDefaultKey.startGameInNotesMode.rawValue: false])

    return UserDefaults.standard.bool(
      forKey: UserDefaultKey.startGameInNotesMode.rawValue,
    );
  }
}
