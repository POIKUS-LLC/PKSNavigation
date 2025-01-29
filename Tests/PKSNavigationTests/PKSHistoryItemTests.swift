import SwiftUI
import XCTest

@testable import PKSNavigation

@MainActor
final class PKSHistoryItemTests: XCTestCase {
    func testHistoryItemInitialization() {
        let mockPage = MockPage.test
        let historyItem = PKSHistoryItem(
            id: UUID(),
            page: mockPage,
            presentation: .stack
        )

        XCTAssertNotNil(historyItem.id)
        XCTAssertNotNil(historyItem.page)
        XCTAssertEqual(historyItem.presentation, .stack)
    }

    func testHistoryItemEquality() {
        let page = MockPage.test
        let id = UUID()
        let item1 = PKSHistoryItem(
            id: id,
            page: page,
            presentation: .stack
        )

        let item2 = PKSHistoryItem(
            id: id,
            page: page,
            presentation: .stack
        )

        let differentPage = MockPage.different
        let item3 = PKSHistoryItem(
            id: UUID(),
            page: differentPage,
            presentation: .stack
        )

        XCTAssertEqual(item1, item1)
        XCTAssertEqual(item1, item2)
        XCTAssertNotEqual(item1, item3)
    }

    func testHistoryItemHashable() {
        let page = MockPage.test
        let id = UUID()
        let item = PKSHistoryItem(
            id: id,
            page: page,
            presentation: .stack
        )

        var hasher = Hasher()
        item.hash(into: &hasher)
        let hash = hasher.finalize()

        XCTAssertNotNil(hash)
    }
}
