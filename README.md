# PKSNavigation

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![Issues](https://img.shields.io/github/issues/POIKUS-LLC/PKSNavigation)](https://github.com/POIKUS-LLC/PKSNavigation/issues)
[![Contributors](https://img.shields.io/github/contributors/POIKUS-LLC/PKSNavigation)](https://github.com/POIKUS-LLC/PKSNavigation/graphs/contributors)
[![Version](https://img.shields.io/github/v/release/POIKUS-LLC/PKSNavigation)](https://github.com/POIKUS-LLC/PKSNavigation/releases)

[![codecov](https://codecov.io/gh/ohk/PKSNavigation/graph/badge.svg?token=VBCJMHMLG4)](https://codecov.io/gh/POIKUS-LLC/PKSNavigation) [![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=ohk_PKSNavigation&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=ohk_PKSNavigation) [![Bugs](https://sonarcloud.io/api/project_badges/measure?project=ohk_PKSNavigation&metric=bugs)](https://sonarcloud.io/summary/new_code?id=ohk_PKSNavigation) [![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=ohk_PKSNavigation&metric=reliability_rating)](https://sonarcloud.io/summary/new_code?id=ohk_PKSNavigation) [![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=ohk_PKSNavigation&metric=security_rating)](https://sonarcloud.io/summary/new_code?id=ohk_PKSNavigation) [![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=ohk_PKSNavigation&metric=vulnerabilities)](https://sonarcloud.io/summary/new_code?id=ohk_PKSNavigation)

<a href="https://www.producthunt.com/posts/pksnavigation?embed=true&utm_source=badge-featured&utm_medium=badge&utm_souce=badge-pksnavigation" target="_blank"><img src="https://api.producthunt.com/widgets/embed-image/v1/featured.svg?post_id=522367&theme=light" alt="PKSNavigation - SwiftUI&#0044;&#0032;Swift&#0044;&#0032;Navigation&#0044;&#0032;PKSNavigation | Product Hunt" style="width: 250px; height: 54px;" width="250" height="54" /></a>


**PKSNavigation** is a simple yet powerful navigation framework designed for SwiftUI applications. It helps you manage complex navigation flows with ease, supporting stack-based navigation, sheet presentations, and full-screen covers. Whether you're building a small app or a large-scale project, PKSNavigation streamlines your navigation logic, making your code cleaner and more maintainable.

## 🚨 Important Notice

- Important: PKSNavigation requires **iOS 16** or later.
- Warning: This framework is optimized for **iPhone** devices. It hasn't been tested or developed for iPad. If you encounter any issues while developing for iPad, please [open an issue](https://github.com/POIKUS-LLC/PKSNavigation/issues) on our GitHub repository.

## 🌟 Features

- 🛠️ **Unified API**: Manage all navigation types using a single, consistent API.
- 🔀 **Nested Navigation**: Support for parent and child navigation managers for complex flows.
- 📜 **Navigation History**: Keep track of navigation events for easy back navigation.
- 📝 **Comprehensive Logging** for debugging
- 🧩 **Modular Architecture** for easy integration and customization

## Demo App

A demo app is available in the [PKSNavigationDemo](https://github.com/POIKUS-LLC/PKSNavigationDemo) repository. Please check it out for more examples and usage scenarios.

> AppleStoreDemo is a mock Apple Store application designed to demonstrate the integration and capabilities of the PKSNavigation framework

## Installation

### Swift Package Manager

You can install PKSNavigation using the [Swift Package Manager](https://swift.org/package-manager/):

1. In Xcode, open your project and navigate to File → Swift Packages → Add Package Dependency...
2. Paste the repository URL: https://github.com/POIKUS-LLC/PKSNavigation.git
3. Click Next and select the version you want to use

## Usage

Here's a simple example demonstrating how to use PKSNavigation for stack-based navigation:

```swift
import SwiftUI
import PKSNavigation

struct ContentView: View {
    @StateObject private var navigationManager = PKSNavigationManager()

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

## 🧠 How it works

PKSNavigation simplifies navigation in SwiftUI by providing three main navigation types:

1. **Stack-Based Navigation**
2. **Sheet Presentation**
3. **Full-Screen Cover Presentation**

All these navigation types are managed through a single, unified API, making your navigation logic consistent and easy to handle. PKSNavigation enhances the fundamental navigation mechanisms by allowing seamless integration and interaction between different navigation styles. This is achieved through intelligent management of navigation states and presentation methods, ensuring that transitions between navigation types are smooth and intuitive.

### Enhanced Navigation Mechanisms

PKSNavigation builds upon the basic navigation types by offering enhanced capabilities:

- **Unified API**: Manage stack, sheet, and cover navigations using a single set of methods.
- **Harmonious Integration**: Different navigation types work seamlessly together, allowing complex navigation flows without intricate management.
- **Flexible Presentation Management**: Easily switch between navigation types or nest them within each other to suit your app's needs.

### Navigation Types

#### 1. Stack-Based Navigation

- **How It Works**: Views are added to or removed from a navigation stack.
- **Use Case**: Ideal for hierarchical navigation where you push and pop views.
- **Example**: Navigating from a list to a detail view.

**Enhancements with PKSNavigation**:

- **Default Mechanism**: Stack-based navigation is the default navigation method.
- **Unified Control**: Easily add or remove views from the root stack using the unified API.
- **Nested Navigation**: Perform stack-based navigation within sheets or full-screen covers effortlessly.

#### 2. Sheet Presentation

- **How It Works**: Views are presented as sheets that slide up from the bottom, covering part of the screen.
- **Use Case**: Suitable for modal interactions like forms or settings.
- **Example**: Presenting a settings screen over the current view.

**Enhancements with PKSNavigation**:

- **Integrated Stack Navigation**: Sheets come with their own navigation stack by default, allowing you to push and pop views within the sheet.
- **Flexible Presentation**: You can add new sheets or switch to full-screen covers from within a sheet, maintaining separate navigation contexts.
- **Multiple Sheets Support**: Register multiple sheet stacks to present multiple sheets simultaneously using `registerSheetStack()`.

#### 3. Full-Screen Cover Presentation

- **How It Works**: Views are presented as full-screen covers, replacing the current view entirely.
- **Use Case**: Best for scenarios where you need to take over the entire screen.
- **Example**: Displaying a login screen that covers the whole app interface.

**Enhancements with PKSNavigation**:

- **Integrated Stack Navigation**: Full-screen covers use stack-based navigation by default, enabling navigation within the cover.
- **Nested Navigation**: From within a cover, you can present additional sheets or covers, each maintaining their own navigation stacks.
- **Multiple Covers Support**: Register multiple cover stacks to manage multiple full-screen covers concurrently using `registerCoverStack()`.

### Logic Behind Switching Between Presentation Methods

PKSNavigationManager intelligently manages the switching between different presentation methods to ensure smooth and consistent navigation flows within your app. Here's how the logic works:

1. **Single Unified API**: All navigation actions are performed through the `navigate(to:presentation:isRoot:)` method, regardless of the current presentation method. This simplifies the navigation logic by providing a consistent interface.

2. **Active Presentation Tracking**: The navigation manager keeps track of the currently active presentation method (`.stack`, `.sheet`, `.cover`). This determines which navigation stack (`rootPath`, `sheetPath`, or `coverPath`) should handle the navigation action.

3. **Context-Aware Navigation**:

   - **Stack Navigation**: If the active presentation is `.stack`, the navigation action affects the root stack.
   - **Sheet Navigation**: If the active presentation is `.sheet`, the navigation action affects the sheet's navigation stack (`sheetPath`). If a sheet stack is not registered, the action is delegated to the parent manager.
   - **Cover Navigation**: If the active presentation is `.cover`, the navigation action affects the cover's navigation stack (`coverPath`). If a cover stack is not registered, the action is delegated to the parent manager.

4. **Nested Presentation Handling**:

   - **Within Sheets and Covers**: When navigating within a sheet or cover, the manager ensures that the navigation actions affect the appropriate nested navigation stack. This allows for complex navigation flows without conflict between different presentation contexts.

5. **Registration of Additional Stacks**: By registering sheet and cover stacks using `registerSheetStack()` and `registerCoverStack()`, you inform the navigation manager to handle multiple sheets or covers, each with their own navigation stacks. This enables presenting multiple sheets or covers simultaneously without navigation conflicts.

6. **Delegation to Parent Managers**: For hierarchical or nested navigation flows, navigation actions can be delegated to a parent navigation manager. This allows for organized navigation management in large-scale applications with complex navigation requirements.

7. **Automatic Presentation Method Switching**: The navigation manager automatically switches the active presentation method based on the current navigation state and the type of navigation action being performed. This ensures that navigation transitions are handled smoothly without requiring manual intervention from the developer.

**Example Scenario**:

- **Initial Navigation**: The app starts with stack-based navigation (`.stack`), allowing users to navigate from Home to Detail views.
- **Presenting a Sheet**: From the Detail view, a settings sheet is presented (`.sheet`). The sheet itself has its own stack-based navigation, allowing users to navigate within the sheet.
- **Presenting a Cover from Sheet**: While in the settings sheet, a login full-screen cover is presented (`.cover`). The cover also maintains its own stack-based navigation.
- **Switching Contexts**: Navigating back from the cover returns to the sheet's stack, and navigating back from the sheet returns to the root stack.

This intelligent management ensures that each presentation context maintains its own navigation flow, and switching between them is handled seamlessly by PKSNavigation.

---

By enhancing the fundamental navigation mechanisms and managing the switching logic internally, PKSNavigation provides a robust and flexible solution for handling complex navigation flows in SwiftUI applications. This allows developers to focus on building their app's features without worrying about the intricacies of navigation management.

### Unified API

PKSNavigation provides a single API to handle all navigation types:

```swift
navigationManager.navigate(to: page, presentation: .stack)
```

- **Parameters**:
  - `to`: The destination page conforming to `PKSPage`.
  - `presentation`: The presentation method (`.stack`, `.sheet`, `.cover`).
  - `isRoot`: (Optional) Whether the destination should be the root of the navigation stack.

### PKSPresentationMethods

Defines the type of navigation presentation:

- **`.stack`**: Pushes a new view onto the navigation stack.
- **`.sheet`**: Presents a view as a sheet.
- **`.cover`**: Presents a view as a full-screen cover.

## 🧑‍💻 Contributing

We welcome contributions! If you encounter any issues or have suggestions for improvements, please [open an issue](https://github.com/POIKUS-LLC/PKSNavigation/issues) on our GitHub repository.

## 🤝 Code of Conduct

We have adopted the [Contributor Covenant](CODE_OF_CONDUCT.md) as our code of conduct.

## 📄 License

PKSNavigation is released under the [MIT License](https://opensource.org/licenses/MIT).

## 👨‍💼 Authors

**Omer Hamid Kamisli**  
Created on July 6, 2024
