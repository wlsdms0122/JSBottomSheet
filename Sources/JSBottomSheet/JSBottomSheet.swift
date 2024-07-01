//
//  JSBottomSheet.swift
//
//
//  Created by jsilver on 6/26/24.
//

import UIKit
import SwiftUI
import Combine
import Stylish

class ScrollViewGestureHandler: NSObject, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    // MARK: - Property
    private weak var scrollView: UIScrollView?
    
    private var currentOffset: CGFloat = .zero
    private var maxOffset: CGFloat = .zero
    
    private let panGesture: UIPanGestureRecognizer
    
    private var onChanged: ((CGPoint) -> Void)?
    private var onEnded: ((CGPoint) -> Void)?
    
    private var initialOffset: CGPoint = .zero
    
    // MARK: - Initializer
    override init() {
        self.panGesture = UIPanGestureRecognizer()
        super.init()
        
        panGesture.addTarget(self, action: #selector(handle(_:)))
        panGesture.delegate = self
    }
    
    // MARK: - Lifecycle
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        guard let gesture = gestureRecognizer as? UIPanGestureRecognizer, gesture == panGesture else { return false }
        
        guard let scrollView else { return false }
        
        return shouldScroll(
            scrollView: scrollView,
            gesture: gesture,
            current: currentOffset,
            max: maxOffset
        )
    }
    
    func gestureRecognizerShouldBegin(
        _ gestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        guard let gesture = gestureRecognizer as? UIPanGestureRecognizer, gesture == panGesture else { return true }
        
        guard let scrollView else { return true }
        
        return scrollView.contentOffset.y <= 0 && !shouldScroll(
            scrollView: scrollView,
            gesture: gesture,
            current: currentOffset,
            max: maxOffset
        )
    }
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        guard let gesture = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        
        guard gesture == panGesture && otherGestureRecognizer == scrollView?.panGestureRecognizer else { return false }
        
        return true
    }
    
    // MARK: - Public
    func attach(
        scrollView: UIScrollView,
        sheetOffset: CGFloat,
        maxOffset: CGFloat,
        onChanged: @escaping (CGPoint) -> Void,
        onEnded: @escaping (CGPoint) -> Void
    ) {
        scrollView.addGestureRecognizer(panGesture)
       
        self.scrollView = scrollView
        
        self.currentOffset = sheetOffset
        self.maxOffset = maxOffset
        
        self.onChanged = onChanged
        self.onEnded = onEnded
    }
    
    // MARK: - Private
    private func shouldScroll(
        scrollView: UIScrollView,
        gesture: UIPanGestureRecognizer,
        current currentOffset: CGFloat,
        max maxOffset: CGFloat
    ) -> Bool {
        let translation = gesture.translation(in: gesture.view)
        let directionAdjust = translation.y > 0 ? -10.0 : 10.0
        
        return currentOffset + scrollView.contentOffset.y + directionAdjust > maxOffset
    }
    
    @objc
    private func handle(_ gesture: UIPanGestureRecognizer) {
        guard let scrollView else { return }
        let translation = gesture.translation(in: scrollView)
        
        switch gesture.state {
        case .began:
            initialOffset = scrollView.contentOffset
            
        case .changed:
            onChanged?(.init(
                x: translation.x + scrollView.contentOffset.x - initialOffset.x,
                y: translation.y + scrollView.contentOffset.y - initialOffset.y
            ))
            
        default:
            onEnded?(.zero)
        }
    }
}

@Stylish
public struct JSBottomSheetOptions {
    /// Bottom sheet should dismiss when backdrop tap. The default value of this property is `true`.
    public var canBackdropDismiss: Bool = true
    /// Bottom sheet content insets. The intrinsic detent calculate size include insets.
    public var contentInsets: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
}

public struct JSBottomSheet<
    DetentState: Hashable,
    Item,
    Backdrop: View,
    Sheet: View,
    Content: View
>: View {
    private struct PresentingContent: Equatable {
        // MARK: - Property
        let isPresenting: Bool
        let contentSize: CGSize
        
        // MARK: - Intializer
        init(_ isPresenting: Bool, contentSize: CGSize) {
            self.isPresenting = isPresenting
            self.contentSize = contentSize
        }
        
        // MARK: - Public
        
        // MARK: - Private
    }
    
    // MARK: - View
    public var body: some View {
        GeometryReader { reader in
            let safeAreaInsets = reader.safeAreaInsets
            let sheetSize = reader.size
            let screenSize = CGSize(
                width: reader.size.width
                    + safeAreaInsets.leading
                    + safeAreaInsets.trailing,
                height: reader.size.height
                    + safeAreaInsets.top
                    + safeAreaInsets.bottom
            )
            
            let detents = detents.mapValues { detent in
                detent.height(
                    contentSize: contentSize,
                    sheetSize: sheetSize
                )
            }
            
            let maxDetent = detents.map(\.value).max() ?? sheetSize.height
            let minDetent = detents.map(\.value).min() ?? 0
            let currentDetent = detents[detentState] ?? 0
            
            let baseOffset = maxDetent / 2
                + sheetSize.height / 2
                + safeAreaInsets.bottom
            let currentOffset = currentDetent - translation.y
            
            let sheetOffset = isPresenting
                ? baseOffset
                    - max(min(currentOffset, maxDetent), minDetent)
                    - safeAreaInsets.bottom
                : baseOffset
            
            let backdropOpacity = isPresenting ? 1.0 : 0.0
            
            ZStack {
                backdrop
                    .ignoresSafeArea()
                    .opacity(backdropOpacity)
                    .onTapGesture {
                        guard options.canBackdropDismiss else { return }
                        item = nil
                    }
                
                SheetContent(
                    detents: detents,
                    currentOffset: currentOffset,
                    maxOffset: maxDetent
                ) {
                    sheet.frame(height: screenSize.height)
                } content: { item in
                    content(item)
                }
                    .frame(height: maxDetent)
                    .offset(y: sheetOffset)
                    .animation(.easeInOut(duration: 0.2), value: sheetOffset)
            }
                .frame(
                    width: reader.size.width,
                    height: reader.size.height
                )
        }
            .onChange(
                of: PresentingContent(
                    item != nil,
                    contentSize: contentSize
                )
            ) { presenting in
                if let item {
                    self.itemCache = item
                }
                
                guard presenting.contentSize != .zero else { return }
                
                withAnimation(.easeOut(duration: 0.3)) {
                    self.isPresenting = presenting.isPresenting
                }
                
                if let timeout, presenting.isPresenting {
                    timeoutTask = Task {
                        try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                        item = nil
                    }
                } else {
                    timeoutTask?.cancel()
                }
            }
    }
    
    @ViewBuilder
    private func SheetContent<
        SheetContent: View,
        SheetSurface: View
    >(
        detents: [DetentState: CGFloat],
        currentOffset: CGFloat,
        maxOffset: CGFloat,
        @ViewBuilder surface: @escaping () -> SheetSurface,
        @ViewBuilder content: (Item) -> SheetContent
    ) -> some View {
        GestureView(of: UIPanGestureRecognizer.self) { gesture in
            self.translation = gesture.translation(in: gesture.view)
        } onChanged: { gesture in
            self.translation = gesture.translation(in: gesture.view)
        } onEnded: { _ in
            self.translation = .zero
            self.detentState = nearestDetent(
                state: detentState,
                detents: detents,
                offset: currentOffset
            )
        } content: {
            LookUp(UIScrollView.self) {
                ScrollViewGestureHandler()
            } lookedUp: { scrollView, coordinator in
                coordinator.attach(
                    scrollView: scrollView,
                    sheetOffset: currentOffset,
                    maxOffset: maxOffset
                ) { translation in
                    self.translation = translation
                } onEnded: { translation in
                    self.translation = translation
                    self.detentState = nearestDetent(
                        state: detentState,
                        detents: detents,
                        offset: currentOffset
                    )
                }
            } content: {
                if let item = itemCache {
                    content(item).padding(options.contentInsets)
                        .onFrameChange($contentSize, path: \.size)
                        .frame(maxHeight: .infinity, alignment: .top)
                }
            }
                .ignoresSafeArea()
        }
            .background(alignment: .top) {
                surface()
            }
            .ignoresSafeArea()
    }
    
    // MARK: - Property
    /// Presenting item
    @Binding
    private var item: Item?
    /// Presenting item cache
    @State
    private var itemCache: Item?
    
    /// Animation state
    @State
    private var isPresenting: Bool
    
    /// Timeout
    private let timeout: TimeInterval?
    @State
    private var timeoutTask: Task<Void, any Error>?
    
    /// Sheet content size
    @State
    private var contentSize: CGSize = .zero
    @State
    private var translation: CGPoint = .zero
    
    /// Current detent state
    @Binding
    private var detentState: DetentState
    /// All detents
    private var detents: [DetentState: JSBottomSheetDetent]
    
    private let backdrop: Backdrop
    private let sheet: Sheet
    private let content: (Item) -> Content
    
    @Styles(JSBottomSheetOptions.self)
    private var options: JSBottomSheetOptions
    
    // MARK: - Initializer
    public init(
        item: Binding<Item?>,
        detentState: Binding<DetentState> = .constant(1),
        detents: [DetentState: JSBottomSheetDetent] = [1: .intrinsic],
        timeout: TimeInterval? = nil,
        @ViewBuilder backdrop: () -> Backdrop = { Color.black.opacity(0.3) },
        @ViewBuilder sheet: () -> Sheet = { JSBottomSheetDefaultSheet() },
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self._item = item
        self._itemCache = .init(initialValue: item.wrappedValue)
        self._isPresenting = .init(wrappedValue: item.wrappedValue != nil)
        self._detentState = detentState
        self.detents = detents
        self.timeout = timeout
        self.backdrop = backdrop()
        self.sheet = sheet()
        self.content = content
    }
    
    public init(
        _ isPresented: Binding<Bool>,
        detentState: Binding<DetentState> = .constant(1),
        detents: [DetentState: JSBottomSheetDetent] = [1: .intrinsic],
        timeout: TimeInterval? = nil,
        @ViewBuilder backdrop: () -> Backdrop = { Color.black.opacity(0.3) },
        @ViewBuilder sheet: () -> Sheet = { JSBottomSheetDefaultSheet() },
        @ViewBuilder content: @escaping () -> Content
    ) where Item == Void {
        self.init(
            item: .init {
                isPresented.wrappedValue ? Void() : nil
            } set: { item in
                isPresented.wrappedValue = item != nil
            },
            detentState: detentState,
            detents: detents,
            timeout: timeout,
            backdrop: backdrop,
            sheet: sheet,
            content: content
        )
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func nearestDetent(
        state: DetentState,
        detents: [DetentState: CGFloat],
        offset: CGFloat
    ) -> DetentState {
        detents.min { lhs, rhs in abs(lhs.value - offset) < abs(rhs.value - offset) }?
            .key ?? state
    }
}

public extension View {
    func bottomSheet<
        Backdrop: View,
        Sheet: View,
        Content: View
    >(
        _ isPresented: Binding<Bool>,
        detentState: Binding<Int> = .constant(1),
        detents: [Int: JSBottomSheetDetent] = [1: .intrinsic],
        timeout: TimeInterval? = nil,
        @ViewBuilder backdrop: () -> Backdrop = { Color.black.opacity(0.3) },
        @ViewBuilder sheet: () -> Sheet = { JSBottomSheetDefaultSheet() },
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        ZStack {
            self
            JSBottomSheet(
                isPresented,
                detentState: detentState,
                detents: detents,
                timeout: timeout,
                backdrop: backdrop,
                sheet: sheet,
                content: content
            )
        }
    }
}

#if DEBUG
private struct Preview: View {
    var body: some View {
        ZStack {
            List {
                Section("Bottom Sheet") {
                    Button(isPresented ? "Hide" : "Show") {
                        isPresented.toggle()
                    }
                    
                    HStack {
                        Text("Status")
                        Picker(selection: $detentState) {
                            Text("Tip")
                                .tag("tip")
                            Text("Small")
                                .tag("small")
                            Text("Large")
                                .tag("large")
                        } label: {
                            EmptyView()
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            
            JSBottomSheet(
                $isPresented,
                detentState: $detentState,
                detents: [
                    "tip": .fixed(200),
                    "small": .fixed(400),
                    "large": .fixed(600)
                ]
            ) {
                Color.clear
            } sheet: {
                JSBottomSheetDefaultSheet {
                    RoundedRectangle(cornerRadius: 2.5)
                        .foregroundColor(Color(uiColor: .systemGray3))
                        .frame(width: 36, height: 5)
                        .offset(y: 5)
                }
            } content: {
                ScrollView {
                    VStack {
                        ForEach(0..<100, id: \.self) { id in
                            Text("\(id)")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .border(.black)
                        }
                    }
                        .frame(maxWidth: .infinity)
                }
            }
                .configure(
                    JSBottomSheetOptions.self,
                    style: \.contentInsets.top,
                    to: 15
                )
        }
            .background{
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @State
    private var isPresented: Bool = false
    @State
    private var detentState: String = "tip"
}

#Preview {
    Preview()
}
#endif
