//
//  PKSPresentationMethod.swift
//
//
//  Created by Ömer Hamid Kamışlı on 7/1/24.
//  Copyright © 2024 POIKUS LLC. All rights reserved.
//

import Foundation

/// An enumeration that defines the different presentation methods for displaying a page.
///
/// Use `PKSPresentationMethod` to specify how a page should be presented
/// within your app. The enumeration supports three methods: stack, sheet, and cover.
///
/// Example:
///
///     let method: PKSPresentationMethod = .stack
///
/// - stack: The page is presented in a stack.
/// - sheet: The page is presented as a sheet.
/// - cover: The page is presented in fullscreen.
///
/// Each case is associated with a string value for encoding and decoding purposes.
@available(iOS 16.0, *)
public enum PKSPresentationMethod: String, Codable, Hashable {
    /// The page is presented in a stack.
    case stack = "STACK"

    /// The page is presented as a sheet.
    case sheet = "SHEET"

    /// The page is presented in fullscreen.
    case cover = "FULLSCREEN"
}
