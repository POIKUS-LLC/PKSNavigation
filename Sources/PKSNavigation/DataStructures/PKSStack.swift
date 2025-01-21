//
//  PKSStack.swift
//
//
//  Created by Ömer Hamid Kamışlı on 7/5/24.
//  Copyright © 2024 POIKUS LLC. All rights reserved.
//

import Foundation

/// A thread-safe generic stack data structure.
///
/// The `PKSStack` class provides a stack (Last-In-First-Out) implementation that is thread-safe.
/// It uses a concurrent dispatch queue with barrier flags to synchronize access to the underlying array of items.
///
/// - Note: This class is `final` and cannot be subclassed.
///
/// - Author: Omer Hamid Kamisli
final class PKSStack<T> {

    // MARK: - Properties

    /// The internal storage for stack items.
    ///
    /// An array that holds the items in the stack. Access to this array is synchronized using `DispatchQueue`.
    fileprivate var items: [T] = []

    /// The dispatch queue used for thread-safe access.
    ///
    /// A concurrent queue that uses barrier flags to ensure thread safety during write operations.
    private let accessQueue = DispatchQueue(
        label: "com.pksstack.accessQueue", attributes: .concurrent)

    /// The number of items in the stack.
    ///
    /// Accesses the `items` array in a thread-safe manner to return the current count.
    var count: Int {
        var result = 0
        accessQueue.sync {
            result = items.count
        }
        return result
    }

    /// A Boolean value indicating whether the stack is empty.
    ///
    /// Returns `true` if the stack contains no items, `false` otherwise.
    var isEmpty: Bool {
        var result = false
        accessQueue.sync {
            result = items.isEmpty
        }
        return result
    }

    // MARK: - Methods

    /// Adds an item to the top of the stack.
    ///
    /// This method appends the item to the `items` array in a thread-safe manner using a barrier block.
    ///
    /// - Parameter item: The item to be added to the stack.
    func push(_ item: T) {
        accessQueue.async(flags: .barrier) {
            self.items.append(item)
        }
    }

    /// Removes and returns the item at the top of the stack.
    ///
    /// This method pops the last item from the `items` array in a thread-safe manner using a barrier block.
    ///
    /// - Returns: The item at the top of the stack, or `nil` if the stack is empty.
    @discardableResult
    func pop() -> T? {
        var result: T?
        accessQueue.sync(flags: .barrier) {
            result = self.items.popLast()
        }
        return result
    }

    /// Returns the item at the top of the stack without removing it.
    ///
    /// This method accesses the last item in the `items` array in a thread-safe manner.
    ///
    /// - Returns: The item at the top of the stack, or `nil` if the stack is empty.
    func peek() -> T? {
        var result: T?
        accessQueue.sync {
            result = self.items.last
        }
        return result
    }

    /// Removes all items from the stack.
    ///
    /// This method clears the `items` array in a thread-safe manner using a barrier block.
    func clear() {
        accessQueue.async(flags: .barrier) {
            self.items.removeAll()
        }
    }
}

extension PKSStack {
    func clone() -> PKSStack {
        let clonedStack = PKSStack()
        
        for item in self.items {
            clonedStack.push(item)
        }
        
        return clonedStack
    }
}
