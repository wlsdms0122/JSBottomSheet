//
//  JSBottomSheetGeometry.swift
//
//
//  Created by jsilver on 7/3/24.
//

import Foundation

public struct JSBottomSheetGeometry {
    // MARK: - Property
    public let contentOffset: CGPoint
    
    private let sheetSize: CGSize
    private let detents: [AnyHashable: CGFloat]
    
    // MARK: - Initializer
    init(contentOffset: CGPoint, sheetSize: CGSize, detents: [some Hashable: CGFloat]) {
        self.contentOffset = contentOffset
        self.sheetSize = sheetSize
        self.detents = detents
    }
    
    // MARK: - Public
    public func location(for state: some Hashable) -> CGPoint {
        guard let detent = detents[state] else { return .zero }
        return .init(
            x: contentOffset.x,
            y: detent - (sheetSize.height - contentOffset.y)
        )
    }
    
    // MARK: - Private
}
