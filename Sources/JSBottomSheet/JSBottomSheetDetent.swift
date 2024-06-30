//
//  JSBottomSheetDetent.swift
//
//
//  Created by jsilver on 6/30/24.
//

import Foundation

public enum JSBottomSheetDetent {
    case fixed(CGFloat)
    case fraction(CGFloat)
    case intrinsic
    
    func height(contentSize: CGSize, sheetSize: CGSize) -> CGFloat {
        switch self {
        case let .fixed(height):
            return height
            
        case let .fraction(ratio):
            return sheetSize.height * ratio
            
        case .intrinsic:
            return contentSize.height
        }
    }
}
