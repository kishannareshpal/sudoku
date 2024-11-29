//
//  retry.utils.swift
//  Sudoku WatchKit Extension
//
//  Created by Kishan Jadav on 26/04/2022.
//  - Adapted from https://github.com/dmytro-anokhin/retry by Dmytro Anokhin
//

import Foundation


/// Executes the closure, that throws an exception, till it succeeds or exceeds number of retries.
/// The closure is executed at least once. In worst scenario the closure is executed `retryCount` + 1.
/// - Parameters:
///   - retryCount: Number of times to retry after the first execution throws.
///   - closure: The closure to execute
/// - Throws: The exception catched at the final attempt to execute the closure. Exceptions catched during retries are ignored.
/// - Returns: Result returned from the closure
@discardableResult
public func retry<T>(times retryCount: UInt = 0, _ closure: () throws -> T) rethrows -> T {
  // Retry executing the closure with delay till the last attempt
  if retryCount > 0 {
    for _ in 1...retryCount {
      do {
        return try closure()
      }
      catch {
        // ignore, and retry the closure if can
      }
    }
  }
  // Last attempt to execute the closure
  return try closure()
}
