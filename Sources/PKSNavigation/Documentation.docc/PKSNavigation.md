# ``PKSNavigation``

**PKSNavigation** is a simple yet powerful navigation framework designed for SwiftUI applications. It helps you manage complex navigation flows with ease, supporting stack-based navigation, sheet presentations, and full-screen covers. Whether you're building a small app or a large-scale project, PKSNavigation streamlines your navigation logic, making your code cleaner and more maintainable.

## 🚨 Important Notice

- Important: PKSNavigation requires **iOS 16** or later.
- Warning: This framework is optimized for **iPhone** devices. It hasn't been tested or developed for iPad. If you encounter any issues while developing for iPad, please [open an issue](https://github.com/POIKUS-LLC/PKSNavigation/issues) on our GitHub repository.

## Featured

@Links(visualStyle: detailedGrid) { 
    - <doc:MeetPKSNavigation>
    - <doc:HowItIsWorks>
}

## How to Use

### 1. Import PKSNavigation

First, import PKSNavigation into your SwiftUI view:

```swift
import SwiftUI
import PKSNavigation
```

### 2. Initialize PKSNavigationManager

Create an instance of `PKSNavigationManager` to manage your navigation:

```swift
@StateObject var navigationManager = PKSNavigationManager()
```

### 3. Set Up Navigation

Use the `PKSNavigationManager` to handle navigation actions like navigating to a new view or going back.

### 4. Example Usage

Here's a simple example demonstrating how to use PKSNavigation for stack-based navigation:

```swift
import SwiftUI
import PKSNavigation

struct ContentView: View {
    @StateObject var navigationManager = PKSNavigationManager()

    var body: some View {
        PKSNavigationContainer(navigationManager: navigationManager) {
            HomeView()
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var navigationManager: PKSNavigationManager

    var body: some View {
        VStack {
            Text("Home View")
                .font(.largeTitle)
            Button("Go to Detail in Stack") {
                navigationManager.navigate(to: RootPages.detail)
            }

            Button("Go to Detail on Sheet") {
                navigationManager.navigate(to: RootPages.detail, presentation: .sheet)
            }

            Button("Go to Detail in Stack") {
                navigationManager.navigate(to: RootPages.detail, presentation: .cover)
            }
        }
    }
}

struct DetailView: View {
    @Environment(\.pksDismiss) var dismiss

    var body: some View {
        VStack {
            Text("Detail View")
                .font(.largeTitle)
            Button("Go Back") {
                dismiss()
            }
        }
    }
}

// Define your pages conforming to PKSPage
enum RootPages: PKSPage {
    case detail

    var description: String {
        switch self {
        case detail:
            return "Detail Page"
        }
    }

    @ViewBuilder
    var body: some View {
        switch self {
        case detail:
            DetailView()
        }
    }
}
```

## Deep Dive

@Links(visualStyle: detailedGrid) { 
    - <doc:DeepDiveToPKSPage>
}
