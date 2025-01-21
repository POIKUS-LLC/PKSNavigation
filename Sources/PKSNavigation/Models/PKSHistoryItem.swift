//
//  PKSHistoryItem.swift
//
//
//  Created by Ömer Hamid Kamışlı on 7/4/24.
//  Copyright © 2024 POIKUS LLC. All rights reserved.
//

import Foundation

/// A struct that represents a navigation history item.
struct PKSHistoryItem: Identifiable, Equatable, Hashable {
    // Identifiable
    var id: UUID

    // The page that was navigated to.
    var page: (any PKSPage)? = nil

    // The presentation method used to navigate to the page.
    var presentation: PKSPresentationMethod

    // The timestamp of the navigation event.
    var timestamp: Date = .now

    // The message for the navigation event.
    var message: String? = nil

    // Whether the item is appended to the history.
    var isAppended: Bool = false

    // Whether the navigation is handled by a parent.
    var isParent: Bool = false
    
//    var childManagerID: UUID

    // MARK: - Equatable
    static func == (lhs: PKSHistoryItem, rhs: PKSHistoryItem) -> Bool {
        return lhs.id == rhs.id
    }

    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(presentation)
        hasher.combine(timestamp)
        hasher.combine(message)
        hasher.combine(isAppended)
    }
}
