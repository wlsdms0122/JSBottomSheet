//
//  ScrollTrackingViewModifier.swift
//
//
//  Created by JSilver on 9/29/24.
//

import SwiftUI

public struct ScrollTrackingViewModifier: ViewModifier {
    
    public init() {
        
    }
    
    public func body(content: Content) -> some View {
        LookUp(UIScrollView.self) { scrollView, _ in
            objc_setAssociatedObject(scrollView, &AssociatedKeys.trackingKey, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        } content: {
            content
        }
    }
}
