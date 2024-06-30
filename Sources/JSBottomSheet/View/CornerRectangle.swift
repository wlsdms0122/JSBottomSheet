//
//  CornerRectangle.swift
//
//
//  Created by jsilver on 2/24/24.
//

import SwiftUI

public struct CornerRectangle: Shape {
    // MARK: - Property
    private let radius: CGFloat
    private let corners: UIRectCorner
    
    // MARK: - Initializer
    public init(cornerRadius radius: CGFloat, corners: UIRectCorner) {
        self.radius = radius
        self.corners = corners
    }
    
    // MARK: - Lifecycle
    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(
                width: radius,
                height: radius
            )
        )
        
        return Path(path.cgPath)
    }
    
    // MARK: - Public
    
    // MARK: - Private
}
