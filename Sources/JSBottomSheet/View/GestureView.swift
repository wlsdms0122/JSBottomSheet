//
//  GestureView.swift
//
//
//  Created by jsilver on 6/26/24.
//

import Foundation
import SwiftUI

class GestureViewController<Content: View>: UIHostingController<Content>, UIGestureRecognizerDelegate {
    // MARK: - Property
    private var handler: ((UIGestureRecognizer) -> Void)?
    
    // MARK: - Initializer
    init(gesture: UIGestureRecognizer, rootView: Content) {
        super.init(rootView: rootView)
        
        gesture.addTarget(self, action: #selector(handle(_:)))
        
        view.addGestureRecognizer(gesture)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
    // MARK: - Public
    func update(content: Content, handler: @escaping (UIGestureRecognizer) -> Void) {
        rootView = content
        self.handler = handler
    }
    
    // MARK: - Private
    @objc
    private func handle(_ gesture: UIGestureRecognizer) {
        handler?(gesture)
    }
}

struct GestureView<
    GestureType: UIGestureRecognizer,
    Content: View
>: UIViewControllerRepresentable {
    // MARK: - Property
    private let handler: (GestureType) -> Void
    private let content: Content
    
    // MARK: - Initializer
    init(
        of gesture: GestureType.Type,
        handler: @escaping (GestureType) -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.handler = handler
        self.content = content()
    }
    
    init(
        of gesture: GestureType.Type,
        onBegan: @escaping (GestureType) -> Void = { _ in },
        onChanged: @escaping (GestureType) -> Void = { _ in },
        onEnded: @escaping (GestureType) -> Void = { _ in },
        @ViewBuilder content: () -> Content
    ) {
        self.handler = { gesture in
            switch gesture.state {
            case .began:
                onBegan(gesture)
                
            case .changed:
                onChanged(gesture)
                
            default:
                onEnded(gesture)
            }
        }
        self.content = content()
    }
    
    // MARK: - Lifecycle
    func makeUIViewController(context: Context) -> GestureViewController<Content> {
        GestureViewController(
            gesture: GestureType(),
            rootView: content
        )
    }
    
    func updateUIViewController(_ uiViewController: GestureViewController<Content>, context: Context) {
        uiViewController.update(content: content) { gesture in
            guard let gesture = gesture as? GestureType else { return }
            handler(gesture)
        }
    }
}
