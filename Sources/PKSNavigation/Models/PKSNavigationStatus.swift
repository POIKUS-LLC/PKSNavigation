//
//  PKSNavigationStatus.swift
//  PKSNavigation
//
//  Created by Ömer Hamid Kamışlı on 1/27/25.
//

import Foundation

/// The navigation status of the current navigation manager.
public struct PKSNavigationStatus {
    /// The presentation method used to navigate.
    public var presentationType: PKSPresentationMethod

    /// The state of the navigation manager.
    public var state: PKSNavigationState
}
