//
//  JSBottomSheetDefaultMask.swift
//  JSBottomSheet
//
//  Created by Ricoh Jeong on 11/29/24.
//

import SwiftUI

public struct JSBottomSheetDefaultMask: View {
    // MARK: - View
    public var body: some View {
        CornerRectangle(cornerRadius: cornerRadius, corners: [.topLeft, .topRight])
            .ignoresSafeArea()
    }

    // MARK: - Property
    private let cornerRadius: CGFloat

    // MARK: - Inititlaizer
    public init(cornerRadius: CGFloat = 10) {
        self.cornerRadius = cornerRadius
    }

    // MARK: - Public

    // MARK: - Private
}
