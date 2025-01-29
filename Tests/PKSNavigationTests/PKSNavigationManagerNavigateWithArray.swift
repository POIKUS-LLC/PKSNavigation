//
//  PKSNavigationManagerNavigateWithArray.swift
//  PKSNavigation
//
//  Created by Ömer Hamid Kamışlı on 1/29/25.
//

import XCTest
@testable import PKSNavigation

@MainActor
final class PKSNavigationManagerNavigateWithArray: XCTestCase {
    var navigationManager: PKSNavigationManager!
    var mockPages: [MockPage]!
    
    override func setUp() {
        navigationManager = PKSNavigationManager(identifier: "TestManager")
        mockPages = [
            MockPage(),
            MockPage(),
            MockPage()
        ]
    }
    
    override func tearDown() {
        mockPages = nil
        navigationManager = nil
    }
    
    // MARK: - Navigate with Pages Array Tests
    
    func testNavigateWithEmptyPagesArray() {
        navigationManager.navigate(with: [], presentation: .stack)
        XCTAssertTrue(navigationManager.rootPath.isEmpty)
    }
    
    func testNavigateWithSinglePage() {
        navigationManager.navigate(with: [mockPages[0]], presentation: .stack)
        XCTAssertEqual(navigationManager.rootPath.count, 1)
    }
    
    func testNavigateWithMultiplePages() {
        navigationManager.navigate(with: mockPages, presentation: .stack)
        XCTAssertEqual(navigationManager.rootPath.count, 3)
    }
    
    func testNavigateWithPagesAsRoot() {
        // First navigate normally
        navigationManager.navigate(to: MockPage())
        XCTAssertEqual(navigationManager.rootPath.count, 1)
        
        // Then navigate with isRoot = true
        navigationManager.navigate(with: mockPages, presentation: .stack, isRoot: true)
        XCTAssertEqual(navigationManager.rootPath.count, 4)
    }
    
    func testNavigateWithPagesUsingSheet() {
        navigationManager.registerSheetStack()
        navigationManager.navigate(with: mockPages, presentation: .sheet)
        
        XCTAssertNotNil(navigationManager.rootSheet)
        XCTAssertEqual(navigationManager.sheetPath.count, 2)
    }
    
    func testNavigateWithPagesUsingCover() {
        navigationManager.registerCoverStack()
        navigationManager.navigate(with: mockPages, presentation: .cover)
        
        XCTAssertNotNil(navigationManager.rootCover)
        XCTAssertEqual(navigationManager.coverPath.count, 2)
    }
    
    // MARK: - Navigate with Steps Tests
    
    func testNavigateWithEmptySteps() {
        navigationManager.navigate(with: [])
        XCTAssertTrue(navigationManager.rootPath.isEmpty)
    }
    
    func testNavigateWithSingleStep() {
        let step = PKSNavigationStep(page: mockPages[0], presentation: .stack)
        navigationManager.navigate(with: [step])
        XCTAssertEqual(navigationManager.rootPath.count, 1)
    }
    
    func testNavigateWithMultipleStepsSamePresentationType() {
        let steps = mockPages.map { PKSNavigationStep(page: $0, presentation: .stack) }
        navigationManager.navigate(with: steps)
        XCTAssertEqual(navigationManager.rootPath.count, 3)
    }
    
    func testNavigateWithMixedPresentationTypes() {
        navigationManager.registerSheetStack()
        navigationManager.registerCoverStack()
        
        let steps = [
            PKSNavigationStep(page: mockPages[0], presentation: .stack),
            PKSNavigationStep(page: mockPages[1], presentation: .sheet),
            PKSNavigationStep(page: mockPages[2], presentation: .cover)
        ]
        
        navigationManager.navigate(with: steps)
        
        XCTAssertEqual(navigationManager.rootPath.count, 1)
        XCTAssertNotNil(navigationManager.rootSheet)
        XCTAssertEqual(navigationManager.sheetPath.count, 1)
    }
    
    func testNavigateWithStepsAfterExistingNavigation() {
        // First navigate normally
        navigationManager.navigate(to: MockPage())
        XCTAssertEqual(navigationManager.rootPath.count, 1)
        
        // Then navigate with steps
        let steps = mockPages.map { PKSNavigationStep(page: $0, presentation: .stack) }
        navigationManager.navigate(with: steps)
        
        XCTAssertEqual(navigationManager.rootPath.count, 4)
    }
    
    func testNavigateWithStepsUsingSheet() {
        navigationManager.registerSheetStack()
        
        let steps = mockPages.map { PKSNavigationStep(page: $0, presentation: .sheet) }
        navigationManager.navigate(with: steps)
        
        XCTAssertNotNil(navigationManager.rootSheet)
        XCTAssertEqual(navigationManager.sheetPath.count, 2)
    }
    
    func testNavigateWithStepsUsingCover() {
        navigationManager.registerCoverStack()
        
        let steps = mockPages.map { PKSNavigationStep(page: $0, presentation: .cover) }
        navigationManager.navigate(with: steps)
        
        XCTAssertNotNil(navigationManager.rootCover)
        XCTAssertEqual(navigationManager.coverPath.count, 2)
    }
    
    func testNavigateWithStepsAlternatingPresentations() {
        navigationManager.registerSheetStack()
        navigationManager.registerCoverStack()
        
        let steps = [
            PKSNavigationStep(page: mockPages[0], presentation: .stack),
            PKSNavigationStep(page: mockPages[1], presentation: .sheet),
            PKSNavigationStep(page: mockPages[2], presentation: .stack),
            PKSNavigationStep(page: MockPage(), presentation: .cover)
        ]
        
        navigationManager.navigate(with: steps)
        
        XCTAssertEqual(navigationManager.rootPath.count, 1)
        XCTAssertNotNil(navigationManager.rootSheet)
        XCTAssertEqual(navigationManager.sheetPath.count, 2)
    }
    
    func testNavigateWithStepsNavigationState() {
        navigationManager.registerSheetStack()
        
        let steps = [
            PKSNavigationStep(page: mockPages[0], presentation: .stack),
            PKSNavigationStep(page: mockPages[1], presentation: .sheet)
        ]
        
        navigationManager.navigate(with: steps)
        
        let status = navigationManager.getNavigationStatus()
        XCTAssertEqual(status.presentationType, .sheet)
        XCTAssertEqual(status.state, .initial)
    }
}
