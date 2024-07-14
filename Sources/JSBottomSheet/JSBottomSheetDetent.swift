//
//  JSBottomSheetDetent.swift
//
//
//  Created by jsilver on 6/30/24.
//

import Foundation

public enum JSBottomSheetDetent {
    /// A detent with a fixed height.
    case fixed(CGFloat)
    /// A detent based on a fraction of the maximum sheet size.
    case fraction(CGFloat)
    /// A detent that fits the content size of the bottom sheet.
    case intrinsic
    
    func height(contentSize: CGSize, sheetSize: CGSize) -> CGFloat {
        switch self {
        case let .fixed(height):
            height
            
        case let .fraction(ratio):
            sheetSize.height * ratio
            
        case .intrinsic:
            contentSize.height
        }
    }
}
