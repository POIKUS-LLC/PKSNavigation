import SwiftUI
import PKSNavigation

struct HomePage: View {
    @EnvironmentObject var navigationManager: PKSNavigationManager
    var mockData: [Article] = .mockData
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 20) {
                Section {
                    ForEach(mockData) { article in
                        ArticleRow(article: article)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                navigationManager.navigate(
                                    to: HomeTabNavigationablePages.detail(
                                        article: .mock,
                                        recommendations: .mockData
                                    )
                                )
                            }
                    }
                } header: {
                    Text("Articles")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 10)
                }
            }
            .padding(.horizontal)
        }
        .toolbar(.hidden)
    }
}
