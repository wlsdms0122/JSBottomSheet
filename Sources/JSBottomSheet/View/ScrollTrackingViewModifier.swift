//
//  ScrollTrackingViewModifier.swift
//
//
//  Created by JSilver on 9/29/24.
//

import SwiftUI

struct AssociatedKeys {
    static var trackingScrollViewKey: Void = Void()
}

struct TrackingScrollViewModifier: ViewModifier {
    // MARK: - Property
    
    // MARK: - Initializer
    public init() { }
    
    // MARK: - Lifecycle
    public func body(content: Content) -> some View {
        LookUp(UIScrollView.self) { scrollView, _ in
            objc_setAssociatedObject(scrollView, &AssociatedKeys.trackingScrollViewKey, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        } content: {
            content
        }
            .ignoresSafeArea()
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

public extension View {
    func trackingScroll() -> some View {
        modifier(TrackingScrollViewModifier())
    }
}
