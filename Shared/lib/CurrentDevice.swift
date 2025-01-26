//
//  CurrentDevice.swift
//  sudoku
//
//  Created by Kishan Jadav on 25/01/2025.
//

#if os(iOS)
var currentDevice: Device = .iphone
#elseif os(watchOS)
var currentDevice: Device = .appleWatch
#endif

