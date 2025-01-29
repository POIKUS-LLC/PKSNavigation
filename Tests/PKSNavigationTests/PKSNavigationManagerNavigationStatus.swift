//
//  PKSNavigationManagerNavigationStatus.swift
//  PKSNavigation
//
//  Created by Ömer Hamid Kamışlı on 1/28/25.
//

import OSLog
import SwiftUI
import XCTest

@testable import PKSNavigation

@MainActor
class PKSNavigationManagerNavigationStatus: XCTestCase {
    var navigationManager: PKSNavigationManager!
    var childNavigationManager: PKSNavigationManager!
    var mockPage: MockPage!
    
    override func setUp() {
        navigationManager = PKSNavigationManager(identifier: "Parent")
        childNavigationManager = PKSNavigationManager(identifier: "Child")
        childNavigationManager.setParent(navigationManager)
        mockPage = MockPage()
    }
    
    override func tearDown() {
        mockPage = nil
        childNavigationManager = nil
        navigationManager = nil
    }
    
    // MARK: - Initial State Tests
    
    func testInitialNavigationStatus() {
        let status = navigationManager.getNavigationStatus()
        XCTAssertEqual(status.presentationType, .stack)
        XCTAssertEqual(status.state, .initial)
    }
    
    // MARK: - Stack Navigation Tests
    
    func testStackNavigationStatus() {
        navigationManager.navigate(to: mockPage)
        
        let status = navigationManager.getNavigationStatus()
        XCTAssertEqual(status.presentationType, .stack)
        XCTAssertEqual(status.state, .navigated)
    }
    
    func testStackNavigationStatusAfterPop() {
        navigationManager.navigate(to: mockPage)
        navigationManager.navigateBack()
        
        let status = navigationManager.getNavigationStatus()
        XCTAssertEqual(status.presentationType, .stack)
        XCTAssertEqual(status.state, .initial)
    }
    
    
    // MARK: - Sheet Navigation Tests
    
    func testSheetNavigationStatus() {
        navigationManager.registerSheetStack()
        navigationManager.navigate(to: mockPage, presentation: .sheet)
        
        let status = navigationManager.getNavigationStatus()
        XCTAssertEqual(status.presentationType, .sheet)
        XCTAssertEqual(status.state, .initial)
    }
    
    func testSheetNavigationStatusAfterDismiss() {
        navigationManager.registerSheetStack()
        navigationManager.navigate(to: mockPage, presentation: .sheet)
        navigationManager.navigateBack()
        
        let status = navigationManager.getNavigationStatus()
        XCTAssertEqual(status.presentationType, .stack)
        XCTAssertEqual(status.state, .initial)
    }
    
    func testSheetRootNavigationStatus() {
        navigationManager.registerSheetStack()
        navigationManager.navigate(to: mockPage, presentation: .sheet, isRoot: true)
        
        let status = navigationManager.getNavigationStatus()
        XCTAssertEqual(status.presentationType, .sheet)
        XCTAssertEqual(status.state, .initial)
    }
    
    func testSheetNavigationStatusWithIsRoot() {
        let navigationManager = PKSNavigationManager(identifier: "Parent")
        navigationManager.registerSheetStack()
        navigationManager.navigate(to: mockPage, presentation: .sheet)
        navigationManager.navigate(to: mockPage, presentation: .sheet, isRoot: true)
        
        // Wait for the navigation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let status = navigationManager.getNavigationStatus()
            
            XCTAssertEqual(status.presentationType, .sheet)
            XCTAssertEqual(status.state, .initial)
        }
    }
    
    
    func testSheetNavigationStatusWithReplace() {
        navigationManager.registerSheetStack()
        navigationManager.navigate(to: mockPage, presentation: .sheet)
        navigationManager.replace(with: mockPage)
        
        let status = navigationManager.getNavigationStatus()
        XCTAssertEqual(status.presentationType, .sheet)
        XCTAssertEqual(status.state, .initial)
    }
    
    func testSheetNavigationStatusMultipleNavigateSheet() {
        navigationManager.registerSheetStack()
        navigationManager.navigate(to: mockPage, presentation: .sheet)
        navigationManager.navigate(to: mockPage, presentation: .sheet)
        
        let status = navigationManager.getNavigationStatus()
        XCTAssertEqual(status.presentationType, .sheet)
        XCTAssertEqual(status.state, .navigated)
    }
    
    func testSheetNavigationStatusMultipleNavigateStack() {
        navigationManager.registerSheetStack()
        navigationManager.navigate(to: mockPage, presentation: .sheet)
        navigationManager.navigate(to: mockPage, presentation: .stack)
        
        let status = navigationManager.getNavigationStatus()
        XCTAssertEqual(status.presentationType, .sheet)
        XCTAssertEqual(status.state, .navigated)
    }
    
    func testSheetNavigationStatusMultipleNavigateCover() {
        navigationManager.registerSheetStack()
        navigationManager.navigate(to: mockPage, presentation: .sheet)
        navigationManager.navigate(to: mockPage, presentation: .cover)
        
        let status = navigationManager.getNavigationStatus()
        XCTAssertEqual(status.presentationType, .sheet)
        XCTAssertEqual(status.state, .navigated)
    }
    
    // MARK: - Cover Navigation Tests
    
    // TODO: Add cover tests
    // MARK: - Multiple Navigation Tests
    
    func testMultipleNavigationStatus() {
        navigationManager.registerSheetStack()
        navigationManager.navigate(to: mockPage)
        navigationManager.navigate(to: mockPage, presentation: .sheet)
        
        var status = navigationManager.getNavigationStatus()
        XCTAssertEqual(status.presentationType, .sheet)
        XCTAssertEqual(status.state, .initial)
        
        navigationManager.navigateBack()
        
        status = navigationManager.getNavigationStatus()
        XCTAssertEqual(status.presentationType, .stack)
        XCTAssertEqual(status.state, .navigated)
        
        navigationManager.navigateBack()
        
        status = navigationManager.getNavigationStatus()
        XCTAssertEqual(status.presentationType, .stack)
        XCTAssertEqual(status.state, .initial)
    }
    
    func testKillTheFlowNavigationStatus() {
        navigationManager.registerSheetStack()
        navigationManager.registerCoverStack()
        
        navigationManager.navigate(to: mockPage)
        
        var status = navigationManager.getNavigationStatus()
        XCTAssertEqual(status.presentationType, .stack)
        XCTAssertEqual(status.state, .navigated)
        
        navigationManager.navigate(to: mockPage, presentation: .sheet)
        
        status = navigationManager.getNavigationStatus()
        XCTAssertEqual(status.presentationType, .sheet)
        XCTAssertEqual(status.state, .initial)
        
        navigationManager.navigate(to: mockPage, presentation: .cover)
        
        status = navigationManager.getNavigationStatus()
        XCTAssertEqual(status.presentationType, .sheet)
        XCTAssertEqual(status.state, .navigated)
        
        navigationManager.killTheFlow()
        
        status = navigationManager.getNavigationStatus()
        XCTAssertEqual(status.presentationType, .stack)
        XCTAssertEqual(status.state, .initial)
    }
    
    func testNavigationStatusAfterReplace() {
        navigationManager.navigate(to: mockPage)
        navigationManager.replace(with: mockPage)
        
        let status = navigationManager.getNavigationStatus()
        XCTAssertEqual(status.presentationType, .stack)
        XCTAssertEqual(status.state, .navigated)
    }
    
    func testMultipleStepNavigationStatus() {
        navigationManager.registerSheetStack()
        navigationManager.registerCoverStack()
        
        let steps: [PKSNavigationStep] = [
            PKSNavigationStep(page: mockPage, presentation: .stack),
            PKSNavigationStep(page: mockPage, presentation: .sheet),
            PKSNavigationStep(page: mockPage, presentation: .cover)
        ]
        
        navigationManager.navigate(with: steps)
        
        let status = navigationManager.getNavigationStatus()
        XCTAssertEqual(status.presentationType, .sheet)
        XCTAssertEqual(status.state, .navigated)
    }
    
    func testNavigationStatusWithHistory() {
        navigationManager.navigate(to: mockPage)
        let firstStatus = navigationManager.getNavigationStatus()
        XCTAssertEqual(firstStatus.presentationType, .stack)
        XCTAssertEqual(firstStatus.state, .navigated)
        
        navigationManager.navigateBack()
        let secondStatus = navigationManager.getNavigationStatus()
        XCTAssertEqual(secondStatus.presentationType, .stack)
        XCTAssertEqual(secondStatus.state, .initial)
        
        // Verify history is properly reflected in status
        navigationManager.navigate(to: mockPage)
        navigationManager.replace(with: MockPage())
        let finalStatus = navigationManager.getNavigationStatus()
        XCTAssertEqual(finalStatus.presentationType, .stack)
        XCTAssertEqual(finalStatus.state, .navigated)
    }
}
