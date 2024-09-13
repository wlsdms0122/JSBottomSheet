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
    
    private var currentOffset: CGPoint = .zero
    private var maxDetent: CGFloat = .zero
    private var contentScrollBehavior: JSBottomSheetContentScrollBehavior = .none
    
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
            currentOffset: currentOffset,
            maxDetent: maxDetent
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
            currentOffset: currentOffset,
            maxDetent: maxDetent
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
        currentOffset: CGPoint,
        maxDetent: CGFloat,
        contentScrollBehavior: JSBottomSheetContentScrollBehavior,
        onChanged: @escaping (CGPoint) -> Void,
        onEnded: @escaping (CGPoint) -> Void
    ) {
        scrollView.addGestureRecognizer(panGesture)
       
        self.scrollView = scrollView
        
        self.currentOffset = currentOffset
        self.maxDetent = maxDetent
        self.contentScrollBehavior = contentScrollBehavior
        
        self.onChanged = onChanged
        self.onEnded = onEnded
    }
    
    // MARK: - Private
    private func shouldScroll(
        scrollView: UIScrollView,
        gesture: UIPanGestureRecognizer,
        currentOffset: CGPoint,
        maxDetent: CGFloat
    ) -> Bool {
        let translation = gesture.translation(in: gesture.view)
        
        guard checkScrollBehavior(contentScrollBehavior, translation: translation) else { return true }
        
        let directionAdjust = translation.y > 0 ? -10.0 : 10.0
        
        let predictiveOffset = currentOffset.y
            + scrollView.contentOffset.y
            + scrollView.adjustedContentInset.top
            + directionAdjust
        
        return predictiveOffset > maxDetent
    }
    
    private func checkScrollBehavior(_ behavior: JSBottomSheetContentScrollBehavior, translation: CGPoint) -> Bool {
        switch behavior {
        case .both:
            true
            
        case .up:
            translation.y <= 0
            
        case .down:
            translation.y > 0
            
        case .none:
            false
        }
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
    // / Bottom sheet should scroll to change detent. The default value of this property is `true`.
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
}

public struct JSBottomSheet<
    DetentState: Hashable,
    Item,
    Backdrop: View,
    Sheet: View,
    Content: View
>: View {
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
            
            let baseOffset = CGPoint(
                x: 0,
                y: maxDetent / 2
                    + sheetSize.height / 2
                    + safeAreaInsets.bottom
            )
            let currentOffset = CGPoint(
                x: 0,
                y: currentDetent - translation.y
            )
            
            let sheetOffset = CGPoint(
                x: 0,
                y: isPresented
                    ? baseOffset.y
                        - max(min(currentOffset.y, maxDetent), minDetent)
                        - safeAreaInsets.bottom
                    : baseOffset.y
            )
            
            let backdropOpacity = isPresented ? 1.0 : 0.0
            
            ZStack {
                backdrop
                    .ignoresSafeArea()
                    .opacity(backdropOpacity)
                    .animation(.easeInOut(duration: 0.2), value: backdropOpacity)
                    .onTapGesture {
                        guard options.canBackdropDismiss else { return }
                        item = nil
                    }
                
                SheetContent(
                    canScroll: options.canScroll,
                    detents: detents,
                    currentOffset: currentOffset,
                    maxDetent: maxDetent,
                    contentScrollBehavior: options.contentScrollBehavior
                ) {
                    sheet.frame(height: screenSize.height)
                } content: { item in
                    content(item)
                }
                    .frame(height: maxDetent)
                    .offset(y: sheetOffset.y)
                    .animation(options.presentAnimation, value: isPresented)
            }
                .frame(width: sheetSize.width, height: sheetSize.height)
                .onChange(of: sheetOffset) { offset in
                    options.onBottomSheetGeometryChange(.init(
                        contentOffset: offset,
                        sheetSize: sheetSize,
                        detents: detents
                    ))
                }
        }
            .onChange(of: item != nil) { _ in
                guard let item else { return }
                self.itemCache = item
            }
            .onChange(of: isPresenting) { isPresenting in
                self.isPresented = isPresenting
                
                if let timeout, isPresenting {
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
        canScroll: Bool,
        detents: [DetentState: CGFloat],
        currentOffset: CGPoint,
        maxDetent: CGFloat,
        contentScrollBehavior: JSBottomSheetContentScrollBehavior,
        @ViewBuilder surface: @escaping () -> SheetSurface,
        @ViewBuilder content: @escaping (Item) -> SheetContent
    ) -> some View {
        if canScroll {
            GestureView(of: UIPanGestureRecognizer.self) { gesture in
                self.translation = gesture.translation(in: gesture.view)
            } onChanged: { gesture in
                withAnimation(options.positionChangeAnimation) {
                    self.translation = gesture.translation(in: gesture.view)
                }
            } onEnded: { _ in
                withAnimation(options.detentTransitionAnimation) {
                    self.translation = .zero
                    self.detentState = nearestDetent(
                        state: detentState,
                        detents: detents,
                        offset: currentOffset
                    )
                }
            } content: {
                LookUp(UIScrollView.self) {
                    ScrollViewGestureHandler()
                } lookedUp: { scrollView, coordinator in
                    coordinator.attach(
                        scrollView: scrollView,
                        currentOffset: currentOffset,
                        maxDetent: maxDetent,
                        contentScrollBehavior: contentScrollBehavior
                    ) { translation in
                        withAnimation(options.positionChangeAnimation) {
                            self.translation = translation
                        }
                    } onEnded: { translation in
                        withAnimation(options.detentTransitionAnimation) {
                            self.translation = translation
                            self.detentState = nearestDetent(
                                state: detentState,
                                detents: detents,
                                offset: currentOffset
                            )
                        }
                    }
                } content: {
                    GeometryReader { _ in
                        ContentView(content: content)
                            .background(alignment: .top) {
                                surface().ignoresSafeArea()
                            }
                    }
                }
                    .ignoresSafeArea()
            }
                .ignoresSafeArea()
        } else {
            GeometryReader { _ in
                ContentView(content: content)
            }
                .background(alignment: .top) {
                    surface().ignoresSafeArea()
                }
        }
    }
    
    @ViewBuilder
    private func ContentView<SheetContent: View>(@ViewBuilder content: @escaping (Item) -> SheetContent) -> some View {
        if let item = itemCache {
            content(item).padding(options.contentInsets)
                .onFrameChange($contentSize, path: \.size)
                .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Property
    /// Presenting item
    @Binding
    private var item: Item?
    /// Presenting item cache
    @State
    private var itemCache: Item?
    
    /// Presenting state
    private var isPresenting: Bool { item != nil && itemCache != nil && contentSize != .zero }
    @State
    private var isPresented: Bool
    
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
    private let detents: [DetentState: JSBottomSheetDetent]
    
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
        self._isPresented = .init(initialValue: item.wrappedValue != nil)
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
        offset: CGPoint
    ) -> DetentState {
        detents.min { lhs, rhs in abs(lhs.value - offset.y) < abs(rhs.value - offset.y) }?
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
#Preview {
    _Preview()
}
#endif
