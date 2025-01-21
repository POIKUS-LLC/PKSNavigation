//
//  PKSNavigationContainer.swift
//  PKSNavigation
//
//  Created by Omer Hamid Kamisli on 2024-09-18 for POIKUS LLC.
//  Copyright © 2024 POIKUS LLC. All rights reserved.
//

import SwiftUI

/// A container view that manages navigation using `PKSNavigationManager`.
///
/// The `PKSNavigationContainer` is a SwiftUI view that sets up a `NavigationStack` and integrates
/// it with the `PKSNavigationManager`. It provides a root view and handles navigation destinations
/// by observing changes in the navigation manager's state.
///
/// - Note: This view should be used as the root view in your SwiftUI application to enable
/// navigation using the PKSNavigation framework.
///
/// - Author: Omer Hamid Kamisli
@available(iOS 16.0, *)
public struct PKSNavigationContainer<Root: View>: View {
    
    // MARK: - Properties
    
    /// The navigation manager that handles navigation actions and state.
    @ObservedObject var navigationManager: PKSNavigationManager
    
    /// The root view of the navigation stack.
    var root: Root
    
    // MARK: - Initialization
    
    /// Initializes a new `PKSNavigationContainer` with a given navigation manager and root view.
    ///
    /// - Parameters:
    ///   - navigationManager: An instance of `PKSNavigationManager` responsible for managing navigation.
    ///   - root: A closure that returns the root view of the navigation stack.
    public init(
        navigationManager: PKSNavigationManager,
        root: @escaping () -> Root
    ) {
        self._navigationManager = ObservedObject(initialValue: navigationManager)
        self.root = root()
    }
    
    // MARK: - Body
    
    /// The content and behavior of the view.
    ///
    /// Sets up the `NavigationStack` and handles navigation destinations by observing the `rootPath`
    /// of the navigation manager. It also injects the navigation manager into the environment for
    /// child views to access.
    public var body: some View {
        NavigationStack(path: $navigationManager.rootPath) {
            root
                .environmentObject(navigationManager)
                .navigationDestination(for: PKSView.self) { page in
                    page.view
                        .environmentObject(navigationManager)
                }
        }
        .modalNavigationStackManager(navigationManager: navigationManager)
    }
}
