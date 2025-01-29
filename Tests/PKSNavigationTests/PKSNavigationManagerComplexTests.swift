import OSLog
import SwiftUI
import XCTest

@testable import PKSNavigation

@MainActor
class PKSNavigationManagerComplexTests: XCTestCase {
    func testNavigateWithParentHierarchy() {
        let grandParentManager = PKSNavigationManager(identifier: "GrandParent")
        let parentManager = PKSNavigationManager(identifier: "Parent")
        let childManager = PKSNavigationManager(identifier: "Child")

        parentManager.setParent(grandParentManager)
        childManager.setParent(parentManager)

        grandParentManager.registerSheetStack()

        let page = MockPage(description: "Page")
        childManager.navigate(to: page, presentation: .sheet)

        XCTAssertEqual(grandParentManager.activePresentation, .sheet)
        XCTAssertNotNil(grandParentManager.rootSheet)
        XCTAssertEqual(parentManager.activePresentation, .stack)
        XCTAssertEqual(childManager.activePresentation, .stack)
    }

    func testKillTheFlowWithComplexNavigationStack() {
        let manager = PKSNavigationManager()
        manager.registerSheetStack()
        manager.registerCoverStack()

        let stackPage = MockPage(description: "StackPage")
        let sheetPage = MockPage(description: "SheetPage")
        let coverPage = MockPage(description: "CoverPage")

        manager.navigate(to: stackPage)
        manager.navigate(to: sheetPage, presentation: .sheet)
        manager.navigate(to: coverPage, presentation: .cover)

        XCTAssertEqual(manager.activePresentation, .sheet)
        XCTAssertNotNil(manager.rootSheet)
        XCTAssertNil(manager.rootCover)
        XCTAssertEqual(manager.rootPath.count, 1)

        manager.killTheFlow()

        XCTAssertEqual(manager.activePresentation, .stack)
        XCTAssertNil(manager.rootSheet)
        XCTAssertNil(manager.rootCover)
        XCTAssertTrue(manager.rootPath.isEmpty)
    }

    func testNavigationBetweenDifferentPresentationMethods() {
        let manager = PKSNavigationManager()
        manager.registerSheetStack()
        manager.registerCoverStack()

        let page1 = MockPage(description: "Page1")
        let page2 = MockPage(description: "Page2")

        manager.navigate(to: page1, presentation: .cover)
        XCTAssertEqual(manager.activePresentation, .cover)

        manager.navigate(to: page2, presentation: .sheet)
        XCTAssertEqual(manager.activePresentation, .cover)

        manager.navigateBack()
        XCTAssertEqual(manager.activePresentation, .cover)

        manager.navigateBack()
        XCTAssertEqual(manager.activePresentation, .stack)
    }

    func testNavigateToSheetWithMultiplePaths() {
        let manager = PKSNavigationManager()
        manager.registerSheetStack()
        manager.registerCoverStack()

        let stackPage = MockPage(description: "StackPage")
        let sheetPage = MockPage(description: "SheetPage")
        let coverPage = MockPage(description: "CoverPage")

        manager.navigate(to: stackPage)
        XCTAssertEqual(manager.activePresentation, .stack)

        manager.navigate(to: sheetPage, presentation: .sheet)
        XCTAssertEqual(manager.activePresentation, .sheet)

        manager.navigate(to: coverPage, presentation: .cover)
        XCTAssertEqual(manager.activePresentation, .sheet)

        manager.navigateBack()
        XCTAssertEqual(manager.activePresentation, .sheet)

        manager.navigateBack()
        XCTAssertEqual(manager.activePresentation, .stack)

        manager.navigateBack()
        XCTAssertEqual(manager.activePresentation, .stack)
        XCTAssertTrue(manager.rootPath.isEmpty)
    }

    func testUpdateHistoryWithMultipleChildren() {
        let parentManager = PKSNavigationManager(identifier: "Parent")
        let child1Manager = PKSNavigationManager(identifier: "Child1")
        let child2Manager = PKSNavigationManager(identifier: "Child2")

        child1Manager.setParent(parentManager)
        child2Manager.setParent(parentManager)

        let page1 = MockPage(description: "Page1")
        let page2 = MockPage(description: "Page2")
        let page3 = MockPage(description: "Page3")

        parentManager.navigate(to: page1)
        child1Manager.navigate(to: page2)
        child2Manager.navigate(to: page3)

        XCTAssertEqual(parentManager.rootPath.count, 3)

        parentManager.navigateBack()

        XCTAssertEqual(parentManager.rootPath.count, 2)
        XCTAssertEqual(parentManager.activePresentation, .stack)
    }
}
