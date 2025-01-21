//
//  PKSModalPresentationModifier.swift
//  PKSNavigation
//
//  Created by Ömer Hamid Kamışlı on 9/29/24.
//  Copyright © 2024 POIKUS LLC. All rights reserved.
//

import SwiftUI

/// A view modifier that manages modal presentations (sheets and full-screen covers) using `PKSNavigationManager`.
///
/// The `PKSModalPresentationModifier` integrates with `PKSNavigationManager` to handle the presentation
/// of views as sheets or full-screen covers. It observes changes in the navigation manager's state
/// and updates the UI accordingly. This modifier should be applied to the root view to enable modal
/// navigation throughout the application.
///
/// - Note: This modifier requires the `PKSNavigationManager` to be provided and properly configured.
/// - Author: Ömer Hamid Kamışlı
@available(iOS 16.0, *)
@MainActor public struct PKSModalPresentationModifier: ViewModifier {

    // MARK: - Properties

    /// The navigation manager that handles modal navigation actions and state.
    ///
    /// Observes the `PKSNavigationManager` to respond to changes in modal presentations.
    @ObservedObject var navigationManager: PKSNavigationManager

    // MARK: - Initialization

    /// Initializes a new instance of `PKSModalPresentationModifier` with a given navigation manager.
    ///
    /// - Parameter navigationManager: An instance of `PKSNavigationManager` responsible for managing modal navigation.
    public init(navigationManager: PKSNavigationManager) {
        self.navigationManager = navigationManager
    }

    // MARK: - ViewModifier

    /// Defines the content and behavior of the modifier.
    ///
    /// Sets up sheet and full-screen cover presentations by observing the `rootSheet` and `rootCover` properties
    /// of the `PKSNavigationManager`. It also registers the sheet and cover stacks when the view appears.
    ///
    /// - Parameter content: The original view to which the modifier is applied.
    /// - Returns: A modified view with sheet and full-screen cover presentations managed by the navigation manager.
    public func body(content: Content) -> some View {
        content
            .sheet(
                item: $navigationManager.rootSheet
            ) { page in
                NavigationStack(path: $navigationManager.sheetPath) {
                    page.view
                        .environmentObject(navigationManager)
                        .navigationDestination(for: PKSView.self) { page in
                            page.view
                                .environmentObject(navigationManager)
                        }
                }
                .presentationDragIndicator(.visible)
            }
            .fullScreenCover(
                item: $navigationManager.rootCover
            ) { page in
                NavigationStack(path: $navigationManager.coverPath) {
                    page.view
                        .environmentObject(navigationManager)
                        .navigationDestination(for: PKSView.self) { page in
                            page.view
                                .environmentObject(navigationManager)
                        }
                }
            }
            .onAppear {
                navigationManager.registerSheetStack()
                navigationManager.registerCoverStack()
            }
    }
}

/// An extension to `View` that applies the `PKSModalPresentationModifier`.
///
/// This extension provides a convenient method to apply the modal navigation stack manager to any view.
/// By calling `modalNavigationStackManager(navigationManager:)`, you can easily integrate modal navigation
/// into your SwiftUI views.
///
/// - Parameter navigationManager: An instance of `PKSNavigationManager` responsible for managing modal navigation.
/// - Returns: A view modified with `PKSModalPresentationModifier`.
@available(iOS 16.0, *)
extension View {
    /// Applies the `PKSModalPresentationModifier` to the view.
    ///
    /// - Parameter navigationManager: An instance of `PKSNavigationManager` responsible for managing modal navigation.
    /// - Returns: A view modified with `PKSModalPresentationModifier`.
    @MainActor
    public func modalNavigationStackManager(
        navigationManager: PKSNavigationManager
    ) -> some View {
        self.modifier(PKSModalPresentationModifier(navigationManager: navigationManager))
    }
}
