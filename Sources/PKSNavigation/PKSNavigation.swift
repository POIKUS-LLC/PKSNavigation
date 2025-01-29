//
//  PKSNavigationManager.swift
//  PKSNavigation
//
//  Created by Omer Hamid Kamisli on 2024-07-06 for POIKUS LLC.
//  Copyright © 2024 POIKUS LLC. All rights reserved.
//

import OSLog
import SwiftUI

// MARK: - PKSNavigationManager

/// Manages the navigation flow within the PKSNavigation framework.
///
/// The `PKSNavigationManager` class is responsible for handling navigation actions such as pushing and popping views,
/// managing different presentation methods (stack, sheet, cover), and maintaining navigation history.
/// It allows for nested navigation by supporting a parent navigation manager and ensures that navigation
/// state changes are observed by conforming to `ObservableObject`.
///
/// - Note: This class is `open` and can be subclassed to extend its functionality.
/// - Author: Omer Hamid Kamisli
///
@available(iOS 16.0, *)
@MainActor
open class PKSNavigationManager: ObservableObject {
    
    // MARK: - Nested Types

    /// The severity level of log messages.
    public enum LogLevel: Int, Comparable {
        case verbose = 0
        case info = 1
        case error = 2
        case critical = 3
        
        var osLogType: OSLogType {
            switch self {
            case .verbose:
                return .debug
            case .info:
                return .info
            case .error:
                return .error
            case .critical:
                return .fault
            }
        }
        
        public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
    
    // MARK: - Published Properties

    /// The currently active presentation method.
    ///
    /// Indicates the presentation method currently in use, such as `.stack`, `.sheet`, or `.cover`.
    @Published private(set) var activePresentation: PKSPresentationMethod = .stack
    
    /// The navigation path for stack-based navigation.
    ///
    /// Used to manage the navigation stack when using the `.stack` presentation method.
    /// - Warning: Public due to the `NavigationStack` requirement. **Do not** mutate directly.
    @Published public var rootPath: NavigationPath = .init() {
        didSet { handleNavigationChanges(old: oldValue.count, new: rootPath.count) }
    }
    
    /// The navigation path for sheet presentations.
    ///
    /// Manages the navigation stack when presenting views as sheets.
    /// - Warning: Public due to the `NavigationStack` requirement. **Do not** mutate directly.
    @Published public var sheetPath: NavigationPath = .init() {
        didSet { handleSheetNavigationChanges(old: oldValue.count, new: sheetPath.count) }
    }
    
    /// The navigation path for cover presentations.
    ///
    /// Manages the navigation stack when presenting views as full-screen covers.
    /// - Warning: Public due to the `NavigationStack` requirement. **Do not** mutate directly.
    @Published public var coverPath: NavigationPath = .init() {
        didSet { handleCoverNavigationChanges(old: oldValue.count, new: coverPath.count) }
    }
    
    /// The root view for sheet presentations.
    @Published public var rootSheet: PKSView? = nil {
        didSet {
            if oldValue != nil {
                handleSheetAndCoverResetNavigationChanges(isSheet: true)
            }
        }
    }
    
    /// The root view for cover presentations.
    @Published public var rootCover: PKSView? = nil {
        didSet {
            if oldValue != nil {
                handleSheetAndCoverResetNavigationChanges(isSheet: false)
            }
        }
    }

    /// The navigation status of the current navigation manager.
    @Published public var navigationStatus: PKSNavigationStatus = PKSNavigationStatus(
        presentationType: .stack, state: .initial)

    /// Retrieves the navigation status of the current navigation manager.
    ///
    /// - Returns: The navigation status.
    func getNavigationStatus() -> PKSNavigationStatus {
        let presentation = activePresentation
        var state: PKSNavigationState = .initial

        if let lastHistoryItem = history.peek(), !lastHistoryItem.isParent {
            switch presentation {
            case .stack:
                state = rootPath.isEmpty ? .initial : .navigated
            case .sheet:
                state = sheetPath.isEmpty ? .initial : .navigated
            case .cover:
                state = coverPath.isEmpty ? .initial : .navigated
            }
        } else {
            if let parentStatus = parent?.getNavigationStatus() {
                return parentStatus
            }
        }

        return PKSNavigationStatus(presentationType: presentation, state: state)
    }

    // MARK: - Internal & Private Properties

    /// The unique identifier of this navigation manager.
    internal var id: UUID = UUID()
    
    /// Weak references to child navigation managers.
    internal var children: [UUID: PKSWeakObject<PKSNavigationManager>] = [:]

    /// Reference to the parent navigation manager.
    private(set) var parent: PKSNavigationManager?
    
    /// Logger for debug and runtime messages.
    private var logger: Logger
    
    /// The navigation history stack.
    ///
    /// Stores a history of navigation events to manage backward navigation and state restoration.
    private var history: PKSStack<PKSHistoryItem> = .init()
    
    /// Indicates whether the sheet stack has been registered.
    private var isSheetStackRegistered: Bool = false
    
    /// Indicates whether the cover stack has been registered.
    private var isCoverStackRegistered: Bool = false
    
    /// A custom identifier for this manager, if any.
    private var identifier: String
    
    // MARK: - Configuration

    /// The current log level for this manager.
    public var logLevel: LogLevel = .verbose
    
    // MARK: - Initialization & Deinitialization

    /// Initializes a new instance of `PKSNavigationManager`.
    ///
    /// - Parameter identifier: A unique identifier, defaulting to the class name.
    public init(identifier: String = String(describing: PKSNavigationManager.self)) {
        self.identifier = identifier
        self.logger = Logger(subsystem: "PKSNavigation", category: "Manager - \(identifier)")
        log("PKSNavigationManager initialized with identifier: \(identifier).", level: .info)
    }
    
    deinit {
        debugPrint("PKSNavigation deinit.")
    }
    
    // MARK: - Public: Registration Methods

    /// Registers the sheet stack for navigation.
    ///
    /// Call this method to enable sheet-based navigation within the manager.
    public func registerSheetStack() {
        isSheetStackRegistered = true
        log("Sheet stack has been registered.", level: .info)
    }

    /// Registers the cover stack for navigation.
    ///
    /// Call this method to enable cover-based navigation within the manager.
    public func registerCoverStack() {
        isCoverStackRegistered = true
        log("Cover stack has been registered.", level: .info)
    }
    
    // MARK: - Public: Parent/Child Management

    /// Sets the parent navigation manager. Pass `nil` to remove the parent.
    ///
    /// - Parameter parent: The parent `PKSNavigationManager`.
    /// - Returns: A Boolean value indicating whether the assignment was successful.
    @MainActor @discardableResult
    public func setParent(_ parent: PKSNavigationManager?) -> Bool {
        if let parent, let selfParent = self.parent, parent.id == selfParent.id {
            log("Parent is already set to this instance. Returning false.", level: .verbose)
            return false
        }
        
        if let parent {
            if self.parent != nil {
                self.parent?.removeChild(self.id)
            }
            self.parent = parent
            self.parent?.registerChild(self)
            log("Parent set: \(parent.identifier).", level: .info)
        } else {
            self.parent?.removeChild(self.id)
            self.parent = nil
            log("Parent removed.", level: .info)
        }
        
        return true
    }
    
    // MARK: - Public: Navigation Methods

    /// Navigates to a specified `PKSPage` with a given presentation.
    ///
    /// - Parameters:
    ///   - page: The page to navigate to.
    ///   - presentation: `.stack`, `.sheet`, or `.cover`. Defaults to `.stack`.
    ///   - isRoot: Whether to reset the presentation stack to make this page the root. Defaults to `false`.
    public func navigate(
        to page: any PKSPage,
        presentation: PKSPresentationMethod = .stack,
        isRoot: Bool = false
    ) {
        navigate(to: page, presentation: presentation, isRoot: isRoot, isNavigatingWithParent: false)
    }

    /// Replaces the current page with a new page.
    ///
    /// - Parameter page: The new page to navigate to.
    /// - Note: This method can be cause unexpected behavior in iOS 16, if you call it in sheet or cover context.
    public func replace(
        with page: any PKSPage
    ) {
        let presentation = history.peek()?.presentation ?? .stack
        navigateBack()

        if #available(iOS 17, *) {
            navigate(to: page, presentation: presentation)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
                guard let self = self else { return }
                self.navigate(to: page, presentation: presentation)
            }
        }
    }

    /// Navigates through a list of pages with a given presentation.
    ///
    /// - Parameters:
    ///   - pages: An array of pages to navigate through.
    ///   - presentation: The presentation method to use. Defaults to `.stack`.
    ///   - isRoot: Whether to reset the presentation stack to make this page the root. Defaults to `false`.
    public func navigate(
        with pages: [any PKSPage],
        presentation: PKSPresentationMethod = .stack,
        isRoot: Bool = false
    ) {
        var currentPages = [] + pages
        guard !currentPages.isEmpty else { return }
        let first = currentPages.removeFirst()

        navigate(to: first, presentation: presentation, isRoot: isRoot)

        for page in currentPages {
            navigate(to: page, presentation: presentation)
        }
    }

    /// Navigates through a list of pages with a given presentation.
    ///
    /// - Parameter steps: An array of navigation steps.
    public func navigate(with steps: [PKSNavigationStep]) {
        for step in steps {
            navigate(to: step.page, presentation: step.presentation)
        }
    }

    /// Navigates back to the previous page/state in the navigation history.
    public func navigateBack() {
        guard let lastHistoryItem = history.peek() else {
            log("No history available to navigate back.", level: .critical)
            return
        }
        
        if lastHistoryItem.isParent {
            log("Last history item is delegated to parent. Passing navigateBack to parent.", level: .verbose)
            parent?.navigateBack()
            return
        }
        
        log("Navigating back from \(lastHistoryItem.presentation.rawValue).", level: .verbose)
        switch lastHistoryItem.presentation {
        case .stack:
            rootPath.removeLastIfAvailable()
            log("Root path popped. New depth: \(rootPath.count).", level: .info)
        case .sheet:
            if sheetPath.isEmpty {
                rootSheet = nil
                log("Root sheet removed.", level: .info)
            } else {
                sheetPath.removeLastIfAvailable()
                log("Sheet path popped. New depth: \(sheetPath.count).", level: .info)
            }
        case .cover:
            if coverPath.isEmpty {
                rootCover = nil
                log("Root cover removed.", level: .info)
            } else {
                coverPath.removeLastIfAvailable()
                log("Cover path popped. New depth: \(coverPath.count).", level: .info)
            }
        }
        
        updateActivePresentation()
        log("Navigation back complete.", level: .info)
    }

    /// Terminates the current navigation flow and clears all history.
    public func killTheFlow() {
        log("Killing the current navigation flow. Clearing history.", level: .error)
        let copiedHistory = history.clone()
        
        while let historyItem = copiedHistory.pop() {
            log("Clearing history item: \(String(describing: historyItem.page?.description)).", level: .verbose)
            if historyItem.isParent {
                parent?.navigateBack()
            } else {
                navigateBack()
            }
        }
        
        log("All history items cleared.", level: .verbose)
    }
    
    // MARK: - Private: Parent/Child Helpers

    /// Registers a child navigation manager.
    private func registerChild(_ child: PKSNavigationManager) {
        children[child.id] = PKSWeakObject(object: child)
        log("Child registered: \(child.id).", level: .info)
    }

    /// Removes a child navigation manager.
    private func removeChild(_ id: UUID) {
        if children[id] != nil {
            children.removeValue(forKey: id)
            log("Child removed: \(id).", level: .info)
        }
    }
    
    // MARK: - Private: Navigation Core

    /// Core navigation logic, including delegation to parent if needed.
    fileprivate func navigate(
        to page: any PKSPage,
        presentation: PKSPresentationMethod = .stack,
        isRoot: Bool = false,
        isNavigatingWithParent: Bool = false,
        historyID: UUID = UUID()
    ) {
        if !isNavigatingWithParent {
            log("Navigating to \(page.description) via \(presentation.rawValue). isRoot: \(isRoot).", level: .verbose)
        }
        
        switch presentation {
        case .stack:
            switch activePresentation {
            case .stack:
                handleStackNavigation(page: page, historyID: historyID)
            case .sheet:
                log("Active presentation is sheet. Routing stack navigation in sheet context.", level: .verbose)
                handleSheetNavigation(page: page, isRoot: isRoot, historyID: historyID)
            case .cover:
                log("Active presentation is cover. Routing stack navigation in cover context.", level: .verbose)
                handleCoverNavigation(page: page, isRoot: isRoot, historyID: historyID)
            }
        case .sheet:
            if activePresentation == .cover {
                handleCoverNavigation(page: page, isRoot: isRoot, historyID: historyID)
            } else {
                if isSheetStackRegistered {
                    handleSheetNavigation(page: page, isRoot: isRoot, historyID: historyID)
                } else {
                    log("Sheet stack not registered. Delegating to parent.", level: .verbose)
                    navigateWithParent(to: page, presentation: presentation, isRoot: isRoot, historyID: historyID)
                }
            }
        case .cover:
            if activePresentation == .sheet {
                handleSheetNavigation(page: page, isRoot: isRoot, historyID: historyID)
            } else {
                if isCoverStackRegistered {
                    handleCoverNavigation(page: page, isRoot: isRoot, historyID: historyID)
                } else {
                    log("Cover stack not registered. Delegating to parent.", level: .verbose)
                    navigateWithParent(to: page, presentation: presentation, isRoot: isRoot, historyID: historyID)
                }
            }
        }
    }
    
    /// Handles the situation where navigation is passed to the parent manager.
    private func navigateWithParent(
        to page: any PKSPage,
        presentation: PKSPresentationMethod,
        isRoot: Bool,
        historyID: UUID
    ) {
        log("Navigating with parent for \(page.description).", level: .verbose)
        history.push(
            PKSHistoryItem(
                id: historyID,
                page: page,
                presentation: presentation,
                timestamp: Date(),
                message: "Navigated with parent",
                isAppended: true,
                isParent: true
            )
        )
        
        parent?.navigate(to: page, presentation: presentation, isRoot: isRoot, historyID: historyID)
        ?? handleStackNavigation(page: page, historyID: historyID)
        
        log("navigateWithParent completed.", level: .info)
    }
    
    // MARK: - Private: Stack Navigation

    /// Handles stack-based (NavigationStack) navigation.
    private func handleStackNavigation(page: any PKSPage, historyID: UUID) {
        log("Handling stack navigation for \(page.description).", level: .verbose)
        
        if parent == nil {
            logNavigationEvent(page: page, presentation: .stack, historyID: historyID)
            activePresentation = .stack
            rootPath.append(PKSView(wrapped: page))
            log("Navigated to \(page.description) on stack. Depth: \(rootPath.count).", level: .info)
        } else {
            log("Parent exists. Delegating stack navigation to parent.", level: .verbose)
            navigateWithParent(to: page, presentation: .stack, isRoot: false, historyID: historyID)
        }
    }
    
    // MARK: - Private: Sheet Navigation

    /// Handles sheet-based (modal) navigation.
    private func handleSheetNavigation(page: any PKSPage, isRoot: Bool, historyID: UUID) {
        log("Handling sheet navigation for \(page.description). isRoot: \(isRoot).", level: .verbose)
        logNavigationEvent(page: page, presentation: .sheet, historyID: historyID)
        
        activePresentation = .sheet
        if isRoot || rootSheet == nil {
            log("Resetting root sheet with \(page.description).", level: .verbose)
            resetRootSheet(with: page)
        } else {
            log("Appending \(page.description) to sheetPath.", level: .verbose)
            sheetPath.append(PKSView(wrapped: page))
        }
        
        log("Sheet navigation to \(page.description) complete. Depth: \(sheetPath.count).", level: .info)
    }

    /// Resets the root sheet with a new page.
    private func resetRootSheet(with page: any PKSPage) {
        log("Resetting root sheet to \(page.description).", level: .verbose)
        
        if #available(iOS 17, *) {
            if !sheetPath.isEmpty { sheetPath.clear() }
            rootSheet = PKSView(wrapped: page)
            log("Root sheet reset (iOS 17+).", level: .verbose)
        } else {
            rootSheet = nil
            if !sheetPath.isEmpty { sheetPath.clear() }
            log("Cleared rootSheet and sheetPath. Scheduling new assignment (iOS < 17).", level: .verbose)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                guard let self = self else {
                    self?.log("Self is nil when resetting root sheet.", level: .error)
                    return
                }
                self.rootSheet = PKSView(wrapped: page)
                self.log("Root sheet assigned asynchronously (iOS < 17).", level: .verbose)
            }
        }
    }
    
    // MARK: - Private: Cover Navigation

    /// Handles cover-based (full-screen) navigation.
    private func handleCoverNavigation(page: any PKSPage, isRoot: Bool, historyID: UUID) {
        log("Handling cover navigation for \(page.description). isRoot: \(isRoot).", level: .verbose)
        logNavigationEvent(page: page, presentation: .cover, historyID: historyID)
        
        activePresentation = .cover
        if isRoot || rootCover == nil {
            log("Resetting root cover with \(page.description).", level: .verbose)
            resetRootCover(with: page)
        } else {
            log("Appending \(page.description) to coverPath.", level: .verbose)
            coverPath.append(PKSView(wrapped: page))
        }
        
        log("Cover navigation to \(page.description) complete. Depth: \(coverPath.count).", level: .info)
    }
    
    /// Resets the root cover with a new page.
    private func resetRootCover(with page: any PKSPage) {
        log("Resetting root cover to \(page.description).", level: .verbose)
        
        if #available(iOS 17, *) {
            coverPath.clear()
            rootCover = PKSView(wrapped: page)
            log("Root cover reset (iOS 17+).", level: .verbose)
        } else {
            rootCover = nil
            coverPath.clear()
            log("Cleared rootCover and coverPath. Scheduling new assignment (iOS < 17).", level: .verbose)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    self?.log("Self is nil when resetting root cover.", level: .error)
                    return
                }
                self.rootCover = PKSView(wrapped: page)
                self.log("Root cover assigned asynchronously (iOS < 17).", level: .verbose)
            }
        }
    }
    
    // MARK: - Private: History Management

    /// Records a navigation event in the history stack.
    private func logNavigationEvent(page: any PKSPage, presentation: PKSPresentationMethod, historyID: UUID) {
        log("Logging navigation event for \(page.description). Presentation: \(presentation.rawValue).", level: .verbose)
        history.push(
            PKSHistoryItem(
                id: historyID,
                page: page,
                presentation: presentation,
                timestamp: Date(),
                message: "Navigation event logged",
                isAppended: true,
                isParent: false
            )
        )
        log("Navigation event logged. History size: \(history.count).", level: .verbose)
    }
    
    /// Updates the navigation history after certain items have been removed.
    private func updateHistory(removedHistories: [UUID]) {
        guard !removedHistories.isEmpty else { return }
        
        for historyID in removedHistories {
            if history.peek()?.id == historyID {
                history.pop()
            }
        }
        
        for child in children.values {
            log("Updating history for child with id: \(child.object?.id ?? UUID()).", level: .verbose)
            child.object?.updateHistory(removedHistories: removedHistories)
        }
        
        updateActivePresentation()
        navigationStatus = getNavigationStatus()
    }
    
    // MARK: - Private: Handling Navigation Changes

    /// Responds to stack navigation path changes.
    private func handleNavigationChanges(old: Int, new: Int) {
        var difference = new - old
        log("Stack navigation changed by \(difference).", level: .verbose)
        
        var removedHistoryItems: [UUID] = []
        while difference < 0 {
            if let id = history.pop()?.id {
                removedHistoryItems.append(id)
            }
            difference += 1
        }
        
        if !removedHistoryItems.isEmpty {
            updateHistory(removedHistories: removedHistoryItems)
        }
    }
    
    /// Responds to a sheet/cover root reset event (root removed).
    private func handleSheetAndCoverResetNavigationChanges(isSheet: Bool) {
        let typeLabel = isSheet ? "SHEET" : "COVER"
        log("Handling \(typeLabel) root reset.", level: .verbose)
        
        var removedHistoryItems: [UUID] = []
        if isSheet {
            while let item = history.peek(), item.presentation == .sheet {
                if let poppedItem = history.pop() {
                    removedHistoryItems.append(poppedItem.id)
                }
            }
            sheetPath.clear()
        } else {
            while let item = history.peek(), item.presentation == .cover {
                if let poppedItem = history.pop() {
                    removedHistoryItems.append(poppedItem.id)
                }
            }
            coverPath.clear()
        }
        
        log("Removed \(removedHistoryItems.count) items from \(typeLabel) history.", level: .verbose)
        updateHistory(removedHistories: removedHistoryItems)
    }
    
    /// Responds to sheet path changes.
    private func handleSheetNavigationChanges(old: Int, new: Int) {
        var difference = new - old
        log("Sheet navigation changed by \(difference).", level: .verbose)
        
        var removedHistoryItems: [UUID] = []
        while difference < 0 {
            if let item = history.peek(), item.presentation == .sheet, let id = history.pop()?.id {
                removedHistoryItems.append(id)
                difference += 1
            } else {
                log("Sheet navigation history mismatch.", level: .critical)
                difference = 0
            }
        }
        
        if !removedHistoryItems.isEmpty {
            updateHistory(removedHistories: removedHistoryItems)
        }
    }
    
    /// Responds to cover path changes.
    private func handleCoverNavigationChanges(old: Int, new: Int) {
        var difference = new - old
        log("Cover navigation changed by \(difference).", level: .verbose)
        
        var removedHistoryItems: [UUID] = []
        while difference < 0 {
            if let item = history.peek(), item.presentation == .cover, let id = history.pop()?.id {
                removedHistoryItems.append(id)
                difference += 1
            } else {
                log("Cover navigation history mismatch.", level: .critical)
                difference = 0
            }
        }
        
        if !removedHistoryItems.isEmpty {
            updateHistory(removedHistories: removedHistoryItems)
        }
    }
    
    /// Updates the `activePresentation` based on the most recent history.
    private func updateActivePresentation() {
        if let lastHistoryItem = history.peek() {
            if activePresentation != lastHistoryItem.presentation {
                log("Switching active presentation to \(lastHistoryItem.presentation.rawValue).", level: .verbose)
                activePresentation = lastHistoryItem.presentation
            }
        } else {
            // Default back to .stack if no history remains.
            log("No history remains. Defaulting activePresentation to .stack.", level: .verbose)
            if activePresentation != .stack {
                activePresentation = .stack
            }
        }
    }
    
    // MARK: - Private: Logging

    /// Logs messages based on the assigned `LogLevel`.
    private func log(
        _ message: String,
        level: LogLevel = .verbose,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard level >= logLevel else { return }
        logger.log(level: level.osLogType, "\(message, privacy: .public)")
    }
}
