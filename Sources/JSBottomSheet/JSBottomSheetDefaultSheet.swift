//
//  JSBottomSheetDefaultSheet.swift
//
//
//  Created by jsilver on 6/30/24.
//

import SwiftUI

public struct JSBottomSheetDefaultSheet<Background: View, Grabber: View>: View {
    // MARK: - View
    public var body: some View {
        background.overlay{
            grabber.frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
        }
    }
    
    // MARK: - Property
    private let background: Background
    private let grabber: Grabber
    
    // MARK: - Initializer
    public init(
        background: Background = Color.white,
        @ViewBuilder grabber: () -> Grabber = { EmptyView() }
    ) {
        self.background = background
        self.grabber = grabber()
    }
    
    // MARK: - Public
    
    // MARK: - Private
}
