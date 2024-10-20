//
//  ScrollTrackingViewModifier.swift
//
//
//  Created by JSilver on 9/29/24.
//

import SwiftUI

struct AssociatedKeys {
    static var trackingScrollViewKey = "_tracking_scrollview"
}

struct TrackingScrollViewModifier: ViewModifier {
    // MARK: - Property
    
    // MARK: - Initializer
    public init() { }
    
    // MARK: - Lifecycle
    public func body(content: Content) -> some View {
        LookUp(UIScrollView.self) { scrollView, _ in
            withUnsafePointer(to: AssociatedKeys.trackingScrollViewKey) { key in
                objc_setAssociatedObject(scrollView, key, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        } content: {
            content
        }
    }
    
    // MARK: - Public
    
    // MARK: - Private
}

public extension View {
    func trackingScroll() -> some View {
        modifier(TrackingScrollViewModifier())
    }
}
