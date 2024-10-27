# JSBottomSheet
`JSBottomSheet` is easy and intuitive bottom sheet component for [SwiftUI](https://developer.apple.com/kr/xcode/swiftui/).

- [JSBottomSheet](#jsbottomsheet)
- [Screenshot](#screenshot)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Swift Package Manager](#swift-package-manager)
- [Getting Started](#getting-started)
  - [Basic Usage](#basic-usage)
  - [Sheet Content](#sheet-content)
  - [Scroll Content](#scroll-content)
  - [Detent](#detent)
  - [Additional Options](#additional-options)
- [Contribution](#contribution)
- [License](#license)

# Screenshot
<image src="https://github.com/user-attachments/assets/db5f6b30-2152-4672-bd9a-544ff744e133" width=300 />

# Requirements
> Although the minimum requirement is iOS 15.0, with a few modifications to some APIs, it can also work on iOS 14.0.
- iOS 15.0+

# Installation
## Swift Package Manager
```swift
dependencies: [
    .package(url: "https://github.com/wlsdms0122/JSBottomSheet.git", from: "1.0.0")
]
```

# Getting Started
## Basic Usage
To use JSBottomSheet, you can place the bottom sheet within a ZStack. Here's a simple.

```swift
struct ContentView: View {
    var body: some View {
        ZStack {
            Button("Toggle Sheet") {
                isPresented.toogle()
            }

            JSBottomSheet($isPresented) {
                Text("Hello World")
                    .padding()
            }
        }
    }

    @State
    private var isPresented: Bool = false
}
```

In this example, a button is used to toggle the presentation of the bottom sheet. When the button is pressed, the bottom sheet displays "Hello World".

The full initializer parameters for JSBottomSheet are as follows:

```swift
JSBottomSheet(
    _ isPresented: Binding<Bool>,
    detentState: Binding<DetentState>,
    detents: [DetentState: JSBottomSheetDetent],
    timeout: TimeInterval?,
    @ViewBuilder backdrop: () -> Backdrop,
    @ViewBuilder sheet: () -> Sheet,
    @ViewBuilder content: @escaping () -> Content
)
```

## Sheet Content
Just like the sheet content, the sheet and backdrop views are also customizable. By default, `JSBottomSheet` provides `JSBottomSheetDefaultSheet` for the sheet and `Color.black.opacity(0.3)` for the backdrop.

```swift
struct ContentView: View {
    var body: some View {
        ZStack {
            Button("Toggle Sheet") {
                isPresented.toogle()
            }

            JSBottomSheet($isPresented) {
                // If you want to enable the back content without the sheet covering the entire screen, you can set clear view.
                Color.clear
            } sheet: {
                // To modify the design of the sheet area, such as adding a grabber view, you can utilize JSBottomSheetDefaultSheet.
                JSBottomSheetDefaultSheet {
                    Capsule().frame(width: 36, height: 5)
                }
            } content: {
                Text("Hello World")
                    .padding()
            }
        }
    }

    @State
    private var isPresented: Bool = false
}
```

## Scroll Content
`JSBottomSheet` also supports scrollable content. To enable this feature, you can add `.trackingScroll()` modifier to the content.

```swift
JSBottomSheet($isPresented) {
    ScrollView {
        LazyVStack {
            ForEach(0..<100, id: \.self) { id in
                Text("\(id)")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .border(.black)
            }
        }
    }
    .trackingScroll()
}
```

## Detent
`JSBottomSheet` supports various detent options to control the size of the bottom sheet. A detent defines the height of the bottom sheet in different states. Here are the available options.

```swift
public enum JSBottomSheetDetent {
    /// A detent with a fixed height.
    case fixed(CGFloat)
    /// A detent based on a fraction of the maximum sheet size.
    case fraction(CGFloat)
    /// A detent that fits the content size of the bottom sheet.
    case intrinsic
}
```

For example, `.fixed(300)` option sets the bottom sheet to specific height in points. `.fraction(0.5)` option sets the bottom sheet height as a fraction of the maximum possible height. and `.intrinsic` option adjusts the bottom sheet height to fit the content's size if possible.

Applying detents example here.

```swift
struct ContentView: View {
    var body: some View {
        ZStack {
            Button("Toggle Sheet") {
                isPresented.toogle()
            }

            JSBottomSheet(
                $isPresented,
                detentState: $detentState,
                detents: [
                    "tip": .fixed(180),
                    "small": .intrinsic,
                    "large": .fraction(0.8)
                ]
            ) {
                Text("Hello World")
                    .padding()
            }
        }
    }

    @State
    private var isPresented: Bool = false
    @State
    private var detentState: String = "tip"
}
```

The `detentState` and `detents` keys must be `Hashable`. You can set any hashable property as the key.

## Additional Options
You can configure additional options for the bottom sheet using [`Stylish`](https://github.com/wlsdms0122/Stylish).

```swift
@Stylish
public struct JSBottomSheetOption {
    /// Bottom sheet should dismiss when backdrop tap. The default value of this property is `true`.
    public var canBackdropDismiss: Bool = true
    /// Bottom sheet should scroll to change detent. The default value of this property is `true`.
    public var canScroll: Bool = true
    /// Bottom sheet adjusts its size based on the content's scroll direction. The default value of this property is `both`.
    public var contentScrollBehavior: JSBottomSheetContentScrollBehavior = .both
    /// Bottom sheet content insets. The intrinsic detent calculate size include insets.
    public var contentInsets: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    /// Bottom sheet geometry changed handler.
    public var onBottomSheetGeometryChange: (JSBottomSheetGeometry) -> Void = { _ in }    
    /// Animation used when presenting or dismissing the bottom sheet.
    public var presentAnimation: Animation = .easeInOut(duration: 0.2)
    /// Animation used when the sheet's position changes within its current detent.
    public var positionChangeAnimation: Animation = .easeInOut(duration: 0.2)
    /// Animation used when transitioning between detents.
    public var detentTransitionAnimation: Animation = .easeInOut(duration: 0.2)
    /// Animation used when the content size changes.
    public var contentChangedAnimation: Animation = .easeInOut(duration: 0.2)
}
```

For more detailed information, check out the sample preview.

# Contribution

Any ideas, issues, opinions are welcome.

# License

JSBottomSheet is available under the MIT license. See the LICENSE file for more info.
