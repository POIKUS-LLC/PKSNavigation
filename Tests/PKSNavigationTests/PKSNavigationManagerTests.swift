import OSLog
import SwiftUI
import XCTest

@testable import PKSNavigation

@MainActor
class PKSNavigationManagerTests: XCTestCase {

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
        // Since isSheetStackRegistered is false and parent is nil, it should handle as stack navigation
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
        // Since isCoverStackRegistered is false and parent is nil, it should handle as stack navigation
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
        // Should log a critical message, but we can't assert logs in unit tests
        // Ensure that no crash occurs and state remains consistent
        XCTAssertTrue(manager.rootPath.isEmpty)
    }

    func testRegisterSheetStack() {
        let manager = PKSNavigationManager()
        let page = MockPage(description: "SheetPage")
        manager.navigate(to: page, presentation: .sheet)
        // Before registration, it should handle as stack navigation
        XCTAssertEqual(manager.activePresentation, .stack)
        manager.registerSheetStack()
        manager.navigate(to: page, presentation: .sheet)
        // After registration, it should handle as sheet navigation
        XCTAssertEqual(manager.activePresentation, .sheet)
    }

    func testRegisterCoverStack() {
        let manager = PKSNavigationManager()
        let page = MockPage(description: "CoverPage")
        manager.navigate(to: page, presentation: .cover)
        // Before registration, it should handle as stack navigation
        XCTAssertEqual(manager.activePresentation, .stack)
        manager.registerCoverStack()
        manager.navigate(to: page, presentation: .cover)
        // After registration, it should handle as cover navigation
        XCTAssertEqual(manager.activePresentation, .cover)
    }

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
        // Since history is private, we can't assert its count, but state should be reset
    }

    func testNavigateWithParent() {
        let parentManager = PKSNavigationManager(identifier: "Parent")
        let childManager = PKSNavigationManager(identifier: "Child")
        childManager.setParent(parentManager)
        parentManager.registerSheetStack()
        let page = MockPage(description: "ParentPage")
        childManager.navigate(to: page, presentation: .sheet)
        XCTAssertEqual(parentManager.activePresentation, .sheet)
        XCTAssertEqual(parentManager.rootSheet?.wrapped.description, "ParentPage")
        XCTAssertEqual(childManager.activePresentation, .stack)  // Child remains in stack presentation
    }
    
    
    func testNavigateWithParentWhenParentEqualToNil() {
        let parentManager = PKSNavigationManager(identifier: "Parent")
        let childManager = PKSNavigationManager(identifier: "Child")
        childManager.setParent(parentManager)
        parentManager.registerSheetStack()
        childManager.setParent(nil)
        let page = MockPage(description: "ParentPage")
        childManager.navigate(to: page, presentation: .sheet)
        XCTAssertEqual(parentManager.activePresentation, .stack)
        XCTAssertEqual(parentManager.rootSheet, nil)
        XCTAssertEqual(childManager.activePresentation, .stack)
        XCTAssertEqual(childManager.rootPath.count, 1)
    }
    
    

    func testNavigateBackWithParentHistory() {
        let parentManager = PKSNavigationManager(identifier: "Parent")
        let childManager = PKSNavigationManager(identifier: "Child")
        childManager.setParent(parentManager)
        parentManager.registerSheetStack()
        let page = MockPage(description: "ParentPage")
        childManager.navigate(to: page, presentation: .sheet)
        // Now, childManager's history should have an item with isParent = true
        childManager.navigateBack()
        XCTAssertNil(parentManager.rootSheet)
        XCTAssertEqual(parentManager.activePresentation, .stack)
    }

    func testResetRootSheet() {
        let manager = PKSNavigationManager()
        manager.registerSheetStack()
        let page1 = MockPage(description: "SheetPage1")
        let page2 = MockPage(description: "SheetPage2")
        manager.navigate(to: page1, presentation: .sheet)
        manager.navigate(to: page2, presentation: .sheet)
        XCTAssertEqual(manager.sheetPath.count, 1)
        manager.navigate(to: page1, presentation: .sheet, isRoot: true)
        XCTAssertEqual(manager.sheetPath.count, 0)
        XCTAssertEqual(manager.rootSheet?.wrapped.description, "SheetPage1")
    }

    func testResetRootCover() {
        let manager = PKSNavigationManager()
        manager.registerCoverStack()
        let page1 = MockPage(description: "CoverPage1")
        let page2 = MockPage(description: "CoverPage2")
        manager.navigate(to: page1, presentation: .cover)
        manager.navigate(to: page2, presentation: .cover)
        XCTAssertEqual(manager.coverPath.count, 1)
        manager.navigate(to: page1, presentation: .cover, isRoot: true)
        XCTAssertEqual(manager.coverPath.count, 0)
        XCTAssertEqual(manager.rootCover?.wrapped.description, "CoverPage1")
    }

    func testUpdateActivePresentationAfterNavigateBack() {
        let manager = PKSNavigationManager()
        manager.registerSheetStack()
        let page1 = MockPage(description: "Page1")
        manager.navigate(to: page1, presentation: .sheet)
        XCTAssertEqual(manager.activePresentation, .sheet)
        manager.navigateBack()
        XCTAssertEqual(manager.activePresentation, .stack)
    }

    func testHandleStackNavigationWithParent() {
        let parentManager = PKSNavigationManager(identifier: "Parent")
        let manager = PKSNavigationManager(identifier: "Child")
        manager.setParent(parentManager)
        let page = MockPage(description: "Page")
        manager.navigate(to: page, presentation: .stack)
        // Since parent exists, it should delegate navigation to parent
        XCTAssertEqual(parentManager.rootPath.count, 1)
        XCTAssertEqual(parentManager.activePresentation, .stack)
        XCTAssertEqual(manager.rootPath.count, 0)
    }

    func testNavigateBackWhenHistoryItemIsParent() {
        let parentManager = PKSNavigationManager(identifier: "Parent")
        let childManager = PKSNavigationManager(identifier: "Child")
        childManager.setParent(parentManager)
        parentManager.registerCoverStack()
        let page = MockPage(description: "ParentPage")
        childManager.navigate(to: page, presentation: .cover)
        // Now, child's history has isParent = true
        childManager.navigateBack()
        XCTAssertNil(parentManager.rootCover)
        XCTAssertEqual(parentManager.activePresentation, .stack)
    }

    func testNavigateBackClearsRootSheetWhenSheetPathIsEmpty() {
        let manager = PKSNavigationManager()
        manager.registerSheetStack()
        let page = MockPage(description: "SheetPage")
        manager.navigate(to: page, presentation: .sheet)
        XCTAssertNotNil(manager.rootSheet)
        manager.navigateBack()
        XCTAssertNil(manager.rootSheet)
        XCTAssertEqual(manager.activePresentation, .stack)
    }

    func testNavigateBackClearsRootCoverWhenCoverPathIsEmpty() {
        let manager = PKSNavigationManager()
        manager.registerCoverStack()
        let page = MockPage(description: "CoverPage")
        manager.navigate(to: page, presentation: .cover)
        XCTAssertNotNil(manager.rootCover)
        manager.navigateBack()
        XCTAssertNil(manager.rootCover)
        XCTAssertEqual(manager.activePresentation, .stack)
    }
    
    func testNavigateStackWhenActivePresentationSheet() {
        let manager = PKSNavigationManager()
        manager.registerSheetStack()
        let page = MockPage(description: "SheetPage")
        manager.navigate(to: page, presentation: .sheet)
        manager.navigate(to: page)
        XCTAssertEqual(manager.rootPath.count, 0)
        XCTAssertEqual(manager.sheetPath.count, 1)
        XCTAssertEqual(manager.coverPath.count, 0)
    }
    
    func testNavigateStackWhenActivePresentationCover() {
        let manager = PKSNavigationManager()
        manager.registerCoverStack()
        let page = MockPage(description: "CoverPage")
        manager.navigate(to: page, presentation: .cover)
        manager.navigate(to: page)
        XCTAssertEqual(manager.rootPath.count, 0)
        XCTAssertEqual(manager.sheetPath.count, 0)
        XCTAssertEqual(manager.coverPath.count, 1)
    }
    
    func testKillTheFlowWithParentNavigation() {
        let parentManager = PKSNavigationManager(identifier: "Parent")
        let childManager = PKSNavigationManager(identifier: "Child")
        childManager.setParent(parentManager)
        parentManager.registerCoverStack()
        let page = MockPage(description: "ParentPage")
        childManager.navigate(to: page, presentation: .cover)
        childManager.killTheFlow()
        XCTAssertEqual(parentManager.rootPath.count, 0)
        XCTAssertEqual(parentManager.sheetPath.count, 0)
        XCTAssertEqual(parentManager.coverPath.count, 0)
        XCTAssertEqual(childManager.rootPath.count, 0)
        XCTAssertEqual(childManager.sheetPath.count, 0)
        XCTAssertEqual(childManager.coverPath.count, 0)
    }

    
    func testNavigateToSheetWithMultiplePaths() {
        let manager = PKSNavigationManager()
        manager.registerSheetStack()
        
        let page1 = MockPage(description: "Page1")
        let page2 = MockPage(description: "Page2")
        let page3 = MockPage(description: "Page3")
        
        manager.navigate(to: page1, presentation: .sheet)
        manager.navigate(to: page2, presentation: .sheet)
        manager.navigate(to: page3, presentation: .sheet)
        
        XCTAssertEqual(manager.sheetPath.count, 2)
        XCTAssertNotNil(manager.rootSheet)
        XCTAssertEqual(manager.activePresentation, .sheet)
    }
    
    func testNavigateToCoverWithMultiplePaths() {
        let manager = PKSNavigationManager()
        manager.registerCoverStack()
        
        let page1 = MockPage(description: "Page1")
        let page2 = MockPage(description: "Page2")
        let page3 = MockPage(description: "Page3")
        
        manager.navigate(to: page1, presentation: .cover)
        manager.navigate(to: page2, presentation: .cover)
        manager.navigate(to: page3, presentation: .cover)
        
        XCTAssertEqual(manager.coverPath.count, 2)
        XCTAssertNotNil(manager.rootCover)
        XCTAssertEqual(manager.activePresentation, .cover)
    }
    
    func testNavigateBackMultipleTimesWithMixedPresentations() {
        let manager = PKSNavigationManager()
        manager.registerSheetStack()
        manager.registerCoverStack()
        
        let stackPage = MockPage(description: "StackPage")
        let sheetPage = MockPage(description: "SheetPage")
        let coverPage = MockPage(description: "CoverPage")
        
        manager.navigate(to: stackPage, presentation: .stack)
        manager.navigate(to: sheetPage, presentation: .sheet)
        manager.navigate(to: coverPage, presentation: .cover)
        
        XCTAssertEqual(manager.activePresentation, .sheet)
        
        manager.navigateBack() // Should remove cover
        XCTAssertEqual(manager.activePresentation, .sheet)
        
        manager.navigateBack() // Should remove sheet
        XCTAssertEqual(manager.activePresentation, .stack)
        
        manager.navigateBack() // Should remove stack
        XCTAssertEqual(manager.activePresentation, .stack)
        XCTAssertTrue(manager.rootPath.isEmpty)
    }
    
    func testConcurrentNavigationOperations() async {
        let manager = PKSNavigationManager()
        manager.registerSheetStack()
        manager.registerCoverStack()
        
        let page1 = MockPage(description: "Page1")
        let page2 = MockPage(description: "Page2")
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await manager.navigate(to: page1, presentation: .sheet)
            }
            group.addTask {
                await manager.navigate(to: page2, presentation: .cover)
            }
        }
        
        // The last navigation should take precedence
        XCTAssertNotNil(manager.rootSheet)
        XCTAssertNil(manager.rootCover)
    }
    
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
    
    func testNavigateBackWithEmptyHistory() {
        let manager = PKSNavigationManager()
        manager.registerSheetStack()
        manager.registerCoverStack()
        
        // Navigate back with empty history
        manager.navigateBack()
        XCTAssertEqual(manager.activePresentation, .stack)
        XCTAssertTrue(manager.rootPath.isEmpty)
        XCTAssertTrue(manager.sheetPath.isEmpty)
        XCTAssertTrue(manager.coverPath.isEmpty)
        
        // Navigate to a page and back multiple times
        let page = MockPage(description: "Page")
        manager.navigate(to: page)
        manager.navigateBack()
        manager.navigateBack() // Extra navigate back should not crash
        
        XCTAssertEqual(manager.activePresentation, .stack)
        XCTAssertTrue(manager.rootPath.isEmpty)
    }
    
    func testNavigationBetweenDifferentPresentationMethods() {
        let manager = PKSNavigationManager()
        manager.registerSheetStack()
        manager.registerCoverStack()
        
        let page1 = MockPage(description: "Page1")
        let page2 = MockPage(description: "Page2")
        
        // Start with sheet presentation
        manager.navigate(to: page1, presentation: .cover)
        XCTAssertEqual(manager.activePresentation, .cover)
        
        // Switch to cover presentation
        manager.navigate(to: page2, presentation: .sheet)
        XCTAssertEqual(manager.activePresentation, .cover)
        
        // Navigate back to sheet
        manager.navigateBack()
        XCTAssertEqual(manager.activePresentation, .cover)
        
        // Switch to stack presentation
        manager.navigateBack()
        XCTAssertEqual(manager.activePresentation, .stack)
    }

    func testUpdateHistoryWithEmptyRemovedHistories() {
        let manager = PKSNavigationManager()
        let page = MockPage(description: "Page")
        
        manager.navigate(to: page)
        XCTAssertEqual(manager.rootPath.count, 1)
        
        // This will trigger updateHistory with empty removedHistories
        manager.navigate(to: page)
        XCTAssertEqual(manager.rootPath.count, 2)
        XCTAssertEqual(manager.activePresentation, .stack)
    }
    
    func testUpdateHistoryWithEmptyHistory() {
        let manager = PKSNavigationManager()
        
        // This will trigger updateHistory with empty history
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
        
        // Navigate in parent
        parentManager.navigate(to: page1)
        // Navigate in child
        childManager.navigate(to: page2)
        
        XCTAssertEqual(parentManager.rootPath.count, 2)
        
        // This will trigger updateHistory in both parent and child
        parentManager.navigateBack()
        
        XCTAssertEqual(parentManager.rootPath.count, 1)
        XCTAssertEqual(parentManager.activePresentation, .stack)
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
        
        // Navigate in parent and children
        parentManager.navigate(to: page1)
        child1Manager.navigate(to: page2)
        child2Manager.navigate(to: page3)
        
        XCTAssertEqual(parentManager.rootPath.count, 3)
        
        // This will trigger updateHistory in parent and both children
        parentManager.navigateBack()
        
        XCTAssertEqual(parentManager.rootPath.count, 2)
        XCTAssertEqual(parentManager.activePresentation, .stack)
    }
    
    func testUpdateHistoryWithMixedPresentationMethods() {
        let manager = PKSNavigationManager()
        manager.registerSheetStack()
        manager.registerCoverStack()
        
        let stackPage = MockPage(description: "StackPage")
        let sheetPage = MockPage(description: "SheetPage")
        let coverPage = MockPage(description: "CoverPage")
        
        // Create a mixed navigation stack
        manager.navigate(to: stackPage)
        manager.navigate(to: sheetPage, presentation: .sheet)
        manager.navigate(to: coverPage, presentation: .cover)
        
        XCTAssertEqual(manager.activePresentation, .sheet)
        XCTAssertNil(manager.rootCover)
        
        // Navigate back will trigger updateHistory
        manager.navigateBack()
        
        XCTAssertNil(manager.rootCover)
        XCTAssertEqual(manager.activePresentation, .sheet)
        XCTAssertNotNil(manager.rootSheet)
    }
    
    func testUpdateHistoryWithRemovedParentManager() {
        let parentManager = PKSNavigationManager(identifier: "Parent")
        let childManager = PKSNavigationManager(identifier: "Child")
        childManager.setParent(parentManager)
        
        let page = MockPage(description: "Page")
        childManager.navigate(to: page)
        
        XCTAssertEqual(parentManager.rootPath.count, 1)
        
        // Remove parent reference
        childManager.setParent(nil)
        
        // This should not affect the parent's history
        childManager.navigateBack()
        
        XCTAssertEqual(parentManager.rootPath.count, 1)
        XCTAssertEqual(parentManager.activePresentation, .stack)
    }
}

struct MockPage: PKSPage {
    var description: String = ""
    
    var body: some View {
        Text("")
    }
}
