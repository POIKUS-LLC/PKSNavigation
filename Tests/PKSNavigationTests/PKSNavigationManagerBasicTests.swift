import OSLog
import SwiftUI
import XCTest

@testable import PKSNavigation

@MainActor
class PKSNavigationManagerBasicTests: XCTestCase {
    func testInitialization() {
        let manager = PKSNavigationManager()
        XCTAssertEqual(manager.activePresentation, .stack)
        XCTAssertTrue(manager.rootPath.isEmpty)
        XCTAssertTrue(manager.sheetPath.isEmpty)
        XCTAssertTrue(manager.coverPath.isEmpty)
        XCTAssertNil(manager.rootSheet)
        XCTAssertNil(manager.rootCover)
        XCTAssertNil(manager.parent)
    }

    func testSetParent() {
        let parentManager = PKSNavigationManager(identifier: "Parent")
        let manager = PKSNavigationManager(identifier: "Child")
        manager.setParent(parentManager)
        XCTAssertNotNil(manager.parent)
    }

    func testSetParentTwice() {
        let parentManager = PKSNavigationManager(identifier: "Parent")
        let manager = PKSNavigationManager(identifier: "Child")
        manager.setParent(parentManager)
        XCTAssertFalse(manager.setParent(parentManager))
        XCTAssertNotNil(manager.parent)
    }

    func testUpdateParent() {
        let parentManager = PKSNavigationManager(identifier: "Parent")
        let secondParentManager = PKSNavigationManager(identifier: "SecondParent")
        let manager = PKSNavigationManager(identifier: "Child")
        manager.setParent(parentManager)

        XCTAssertNotNil(manager.parent)
        XCTAssertEqual(manager.parent?.id, parentManager.id)

        manager.setParent(secondParentManager)

        XCTAssertNotNil(manager.parent)
        XCTAssertEqual(manager.parent?.id, secondParentManager.id)
    }
}
