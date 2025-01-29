//
//  MockPage.swift
//  PKSNavigation
//
//  Created by Ömer Hamid Kamışlı on 1/27/25.
//


import SwiftUI
@testable import PKSNavigation

struct MockPage: PKSPage {
    var description: String = "Test"
    var content: String = "Test"
    
    var body: some View {
        Text(content)
    }
    
    static let test = MockPage(description: "Test Page", content: "Test Content")
    static let different = MockPage(description: "Different Page", content: "Different Content")
}
