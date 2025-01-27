//
//  representing.swift
//  PKSNavigation
//
//  Created by Ömer Hamid Kamışlı on 1/27/25.
//

import Foundation

/// A struct representing a navigation step.
///
/// - Parameters:
///   - page: The page to navigate to.
///   - presentation: The presentation method to use. Defaults to `.stack`.
public struct PKSNavigationStep {
    /// The page to navigate to.
    public let page: any PKSPage

    /// The presentation method to use. Defaults to `.stack`.
    public let presentation: PKSPresentationMethod

    /// Initializes a new navigation step.
    ///
    /// - Parameters:
    ///   - page: The page to navigate to.
    ///   - presentation: The presentation method to use. Defaults to `.stack`.
    public init(page: any PKSPage, presentation: PKSPresentationMethod = .stack) {
        self.page = page
        self.presentation = presentation
    }
}
