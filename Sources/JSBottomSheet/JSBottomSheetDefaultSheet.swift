//
//  JSBottomSheetDefaultSheet.swift
//
//
//  Created by jsilver on 6/30/24.
//

import SwiftUI

public struct JSBottomSheetDefaultSheet<Grabber: View>: View {
    // MARK: - View
    public var body: some View {
        backgroundColor.overlay{
            grabber.frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
        }
            .clipShape(
                CornerRectangle(
                    cornerRadius: cornerRadius,
                    corners: [.topLeft, .topRight]
                )
            )
    }
    
    // MARK: - Property
    private let backgroundColor: Color
    private let cornerRadius: CGFloat
    private let grabber: Grabber
    
    // MARK: - Initializer
    public init(
        backgroundColor: Color = .white,
        cornerRadius: CGFloat = 10,
        @ViewBuilder grabber: () -> Grabber = { EmptyView() }
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.grabber = grabber()
    }
    
    // MARK: - Public
    
    // MARK: - Private
}
