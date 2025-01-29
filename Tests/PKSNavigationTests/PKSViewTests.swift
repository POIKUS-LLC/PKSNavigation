import SwiftUI
import XCTest

@testable import PKSNavigation

final class PKSViewTests: XCTestCase {
    @MainActor
    func testViewProperties() {
        let mockPage = MockPage.test
        let pksView = PKSView(wrapped: mockPage)

        XCTAssertNotNil(pksView.id)
        XCTAssertNotNil(pksView.view)
    }

    @MainActor
    func testEquality() {
        let view1 = PKSView(wrapped: MockPage.test)
        let view2 = PKSView(wrapped: MockPage.test)
        let view3 = PKSView(wrapped: MockPage.different)

        XCTAssertEqual(view1.id, view1.id)
        XCTAssertEqual(view1.id, view2.id)  // Different instances should have different IDs
        XCTAssertNotEqual(view1.id, view3.id)
    }

    @MainActor
    func testHashableSameInstance() {
        let view1 = PKSView(wrapped: MockPage.test)
        let view2 = PKSView(wrapped: MockPage.test)

        var hasher1 = Hasher()
        var hasher2 = Hasher()

        view1.hash(into: &hasher1)
        view2.hash(into: &hasher2)

        XCTAssertEqual(hasher1.finalize(), hasher2.finalize())
    }
    
    @MainActor
    func testHashableDifferentInstance() {
        let view1 = PKSView(wrapped: MockPage.test)
        let view2 = PKSView(wrapped: MockPage.different)

        var hasher1 = Hasher()
        var hasher2 = Hasher()

        view1.hash(into: &hasher1)
        view2.hash(into: &hasher2)

        XCTAssertNotEqual(hasher1.finalize(), hasher2.finalize())
    }
}
