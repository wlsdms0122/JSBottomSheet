//
//  OnFrameChangeViewModifier.swift
//
//
//  Created by jsilver on 6/26/24.
//

import SwiftUI

struct OnFrameChangeViewModifier: ViewModifier {
    // MARK: - Property
    private let coordinateSpace: CoordinateSpace
    private let action: (CGRect) -> Void
    
    // MARK: - Initializer
    init(
        in coordinateSpace: CoordinateSpace = .global,
        action: @escaping (CGRect) -> Void
    ) {
        self.coordinateSpace = coordinateSpace
        self.action = action
    }
    
    // MARK: - Lifecycle
    func body(content: Content) -> some View {
        content.overlay(GeometryReader { reader in
            let frame = reader.frame(in: coordinateSpace)
            Color.clear
                .onAppear {
                    action(frame)
                }
                .onChange(of: frame) { frame in
                    action(frame)
                }
        })
    }
}

extension View {
    func onFrameChange(
        in coordinateSpace: CoordinateSpace = .global,
        action: @escaping (CGRect) -> Void
    ) -> some View {
        modifier(OnFrameChangeViewModifier(in: coordinateSpace, action: action))
    }
    
    func onFrameChange<Value>(
        _ binding: Binding<Value>,
        in coordinateSpace: CoordinateSpace = .global,
        path: KeyPath<CGRect, Value> = \.self
    ) -> some View {
        modifier(OnFrameChangeViewModifier(in: coordinateSpace) { frame in
            binding.wrappedValue = frame[keyPath: path]
        })
    }
}
