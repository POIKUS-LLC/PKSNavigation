import OSLog
import SwiftUI
import XCTest

@testable import PKSNavigation

@MainActor
class PKSNavigationManagerHistoryTests: XCTestCase {
    func testKillTheFlow() {
        let manager = PKSNavigationManager()
        let page1 = MockPage(description: "Page1")
        let page2 = MockPage(description: "Page2")
        manager.navigate(to: page1)
        manager.navigate(to: page2)
        XCTAssertEqual(manager.rootPath.count, 2)
        manager.killTheFlow()
        XCTAssertEqual(manager.rootPath.count, 0)
        XCTAssertEqual(manager.activePresentation, .stack)
    }

    func testUpdateHistoryWithEmptyRemovedHistories() {
        let manager = PKSNavigationManager()
        let page = MockPage(description: "Page")

        manager.navigate(to: page)
        XCTAssertEqual(manager.rootPath.count, 1)

        manager.navigate(to: page)
        XCTAssertEqual(manager.rootPath.count, 2)
        XCTAssertEqual(manager.activePresentation, .stack)
    }

    func testUpdateHistoryWithEmptyHistory() {
        let manager = PKSNavigationManager()
        manager.navigateBack()
        XCTAssertEqual(manager.activePresentation, .stack)
        XCTAssertTrue(manager.rootPath.isEmpty)
    }

    func testUpdateHistoryWithChildManagers() {
        let parentManager = PKSNavigationManager(identifier: "Parent")
        let childManager = PKSNavigationManager(identifier: "Child")
        childManager.setParent(parentManager)

        let page1 = MockPage(description: "Page1")
        let page2 = MockPage(description: "Page2")

        parentManager.navigate(to: page1)
        childManager.navigate(to: page2)

        XCTAssertEqual(parentManager.rootPath.count, 2)

        parentManager.navigateBack()

        XCTAssertEqual(parentManager.rootPath.count, 1)
        XCTAssertEqual(parentManager.activePresentation, .stack)
    }

    func testUpdateHistoryWithRemovedParentManager() {
        let parentManager = PKSNavigationManager(identifier: "Parent")
        let childManager = PKSNavigationManager(identifier: "Child")
        childManager.setParent(parentManager)

        let page = MockPage(description: "Page")
        childManager.navigate(to: page)

        XCTAssertEqual(parentManager.rootPath.count, 1)

        childManager.setParent(nil)
        childManager.navigateBack()

        XCTAssertEqual(parentManager.rootPath.count, 1)
        XCTAssertEqual(parentManager.activePresentation, .stack)
    }

    func testNavigateBackMultipleTimes() {
        let manager = PKSNavigationManager()
        let page = MockPage(description: "Page")
        manager.navigate(to: page)
        manager.navigateBack()
        manager.navigateBack()  // Extra navigate back should not crash

        XCTAssertEqual(manager.activePresentation, .stack)
        XCTAssertTrue(manager.rootPath.isEmpty)
    }
}
