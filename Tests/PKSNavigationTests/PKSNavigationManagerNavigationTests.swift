import OSLog
import SwiftUI
import XCTest

@testable import PKSNavigation

@MainActor
class PKSNavigationManagerNavigationTests: XCTestCase {
    func testNavigateToStack() {
        let manager = PKSNavigationManager()
        let page = MockPage(description: "StackPage")
        manager.navigate(to: page, presentation: .stack)
        XCTAssertEqual(manager.activePresentation, .stack)
        XCTAssertEqual(manager.rootPath.count, 1)
    }

    func testNavigateToSheetWithoutRegistration() {
        let manager = PKSNavigationManager()
        let page = MockPage(description: "SheetPage")
        manager.navigate(to: page, presentation: .sheet)
        XCTAssertEqual(manager.activePresentation, .stack)
        XCTAssertEqual(manager.rootPath.count, 1)
    }

    func testNavigateToSheetWithRegistration() {
        let manager = PKSNavigationManager()
        manager.registerSheetStack()
        let page = MockPage(description: "SheetPage")
        manager.navigate(to: page, presentation: .sheet)
        XCTAssertEqual(manager.activePresentation, .sheet)
        XCTAssertEqual(manager.rootSheet?.wrapped.description, "SheetPage")
        XCTAssertTrue(manager.sheetPath.isEmpty)
    }

    func testNavigateToCoverWithoutRegistration() {
        let manager = PKSNavigationManager()
        let page = MockPage(description: "CoverPage")
        manager.navigate(to: page, presentation: .cover)
        XCTAssertEqual(manager.activePresentation, .stack)
        XCTAssertEqual(manager.rootPath.count, 1)
    }

    func testNavigateToCoverWithRegistration() {
        let manager = PKSNavigationManager()
        manager.registerCoverStack()
        let page = MockPage(description: "CoverPage")
        manager.navigate(to: page, presentation: .cover)
        XCTAssertEqual(manager.activePresentation, .cover)
        XCTAssertEqual(manager.rootCover?.wrapped.description, "CoverPage")
        XCTAssertTrue(manager.coverPath.isEmpty)
    }

    func testNavigateBackWithHistory() {
        let manager = PKSNavigationManager()
        let page1 = MockPage(description: "Page1")
        let page2 = MockPage(description: "Page2")
        manager.navigate(to: page1)
        manager.navigate(to: page2)
        XCTAssertEqual(manager.rootPath.count, 2)
        manager.navigateBack()
        XCTAssertEqual(manager.rootPath.count, 1)
    }

    func testNavigateBackWithoutHistory() {
        let manager = PKSNavigationManager()
        manager.navigateBack()
        XCTAssertTrue(manager.rootPath.isEmpty)
    }

    func testRegisterSheetStack() {
        let manager = PKSNavigationManager()
        let page = MockPage(description: "SheetPage")
        manager.navigate(to: page, presentation: .sheet)
        XCTAssertEqual(manager.activePresentation, .stack)
        manager.registerSheetStack()
        manager.navigate(to: page, presentation: .sheet)
        XCTAssertEqual(manager.activePresentation, .sheet)
    }

    func testRegisterCoverStack() {
        let manager = PKSNavigationManager()
        let page = MockPage(description: "CoverPage")
        manager.navigate(to: page, presentation: .cover)
        XCTAssertEqual(manager.activePresentation, .stack)
        manager.registerCoverStack()
        manager.navigate(to: page, presentation: .cover)
        XCTAssertEqual(manager.activePresentation, .cover)
    }

    func testReplace() {
        let manager = PKSNavigationManager()
        let page = MockPage(description: "Page")
        manager.navigate(to: page)
        XCTAssertEqual(manager.rootPath.count, 1)
        manager.replace(with: page)
        XCTAssertEqual(manager.rootPath.count, 1)
    }

    func testReplaceWithSheet() {
        let manager = PKSNavigationManager()
        manager.registerSheetStack()
        manager.registerCoverStack()
        let page = MockPage(description: "Page")
        let page2 = MockPage(description: "Page2")
        manager.navigate(to: page, presentation: .sheet)
        XCTAssertEqual(manager.sheetPath.count, 0)
        XCTAssertEqual(manager.rootSheet?.wrapped.description, "Page")
        manager.replace(with: page2)
        XCTAssertEqual(manager.sheetPath.count, 0)
        XCTAssertEqual(manager.rootSheet?.wrapped.description, "Page2")
    }

    func testReplaceWithCover() {
        let manager = PKSNavigationManager()
        manager.registerCoverStack()
        manager.registerSheetStack()
        let page = MockPage(description: "Page")
        let page2 = MockPage(description: "Page2")
        manager.navigate(to: page, presentation: .cover)
        XCTAssertEqual(manager.coverPath.count, 0)
        XCTAssertEqual(manager.rootCover?.wrapped.description, "Page")
        manager.replace(with: page2)
        XCTAssertEqual(manager.coverPath.count, 0)
        XCTAssertEqual(manager.rootCover?.wrapped.description, "Page2")
    }

    func testReplaceEmptyHistory() {
        let manager = PKSNavigationManager()
        manager.registerSheetStack()
        manager.registerCoverStack()
        let page = MockPage(description: "Page")
        XCTAssertTrue(manager.rootPath.isEmpty)
        XCTAssertTrue(manager.sheetPath.isEmpty)
        XCTAssertTrue(manager.coverPath.isEmpty)
        XCTAssertTrue(manager.rootSheet == nil)
        XCTAssertTrue(manager.rootCover == nil)
        manager.replace(with: page)
        XCTAssertEqual(manager.rootPath.count, 1)
    }

    func testReplaceWithParentSheet() {
        let child = PKSNavigationManager()
        let parent = PKSNavigationManager()
        parent.registerSheetStack()
        XCTAssertTrue(child.setParent(parent))
        let page = MockPage(description: "Page")
        child.navigate(to: page, presentation: .sheet)
        XCTAssertNil(child.rootSheet)
        XCTAssertEqual(parent.rootSheet?.wrapped.description, "Page")
    }

    func testReplaceWithParentCover() {
        let child = PKSNavigationManager()
        let parent = PKSNavigationManager()
        parent.registerCoverStack()
        XCTAssertTrue(child.setParent(parent))
        let page = MockPage(description: "Page")
        child.navigate(to: page, presentation: .cover)
        XCTAssertNil(child.rootCover)
        XCTAssertEqual(parent.rootCover?.wrapped.description, "Page")
    }

    func testReplaceParentRoot() {
        let child = PKSNavigationManager()
        let parent = PKSNavigationManager()
        XCTAssertTrue(child.setParent(parent))
        let page = MockPage(description: "Page")
        child.navigate(to: page)
        XCTAssertEqual(child.rootPath.count, 0)
        XCTAssertEqual(parent.rootPath.count, 1)
    }
}
