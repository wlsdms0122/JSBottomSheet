//
//  LookUp.swift
//
//
//  Created by jsilver on 6/26/24.
//

import Foundation
import SwiftUI

class LookUpViewController<
    LookUpView: UIView,
    Content: View
>: UIHostingController<Content> {
    // MARK: - View
    
    // MARK: - Property
    private var handler: ((LookUpView) -> Void)?
    
    // MARK: - Initializer
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let lookupView = lookUp(view) else { return }
        handler?(lookupView)
    }
    
    // MARK: - Public
    func update(_ content: Content, lookedUp handler: @escaping (LookUpView) -> Void) {
        rootView = content
        self.handler = handler
    }
    
    // MARK: - Private
    private func lookUp(_ view: UIView?) -> LookUpView? {
        guard let view else { return nil }
        
        let lookupView = view.subviews
            .compactMap { view in view as? LookUpView }
            .first
        
        guard let lookupView else {
            return view.subviews
                .compactMap { view in lookUp(view) }
                .first
        }
        
        return lookupView
    }
}

struct LookUp<
    LookUpView: UIView,
    Coordinator,
    Content: View
>: UIViewControllerRepresentable {
    // MARK: - Property
    private let coordinator: () -> Coordinator
    private let lookUpView: LookUpView.Type
    private let handler: (LookUpView, Coordinator) -> Void
    private let content: Content
    
    // MARK: - Initializer
    init(
        _ lookUpView: LookUpView.Type,
        coordinator: @escaping () -> Coordinator = { },
        lookedUp handler: @escaping (LookUpView, Coordinator) -> Void = { _, _ in },
        @ViewBuilder content: () -> Content
    ) {
        self.lookUpView = lookUpView
        self.coordinator = coordinator
        self.handler = handler
        self.content = content()
    }
    
    init(
        _ lookUpView: LookUpView.Type,
        lookedUp handler: @escaping (LookUpView) -> Void = { _ in },
        @ViewBuilder content: () -> Content
    ) where Coordinator == Void {
        self.lookUpView = lookUpView
        self.coordinator = { }
        self.handler = { view, _ in handler(view) }
        self.content = content()
    }
    
    // MARK: - Lifecycle
    func makeUIViewController(context: Context) -> LookUpViewController<LookUpView, Content> {
        let viewController = LookUpViewController<LookUpView, Content>(
            rootView: content
        )
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: LookUpViewController<LookUpView, Content>, context: Context) {
        uiViewController.update(content) { view in
            handler(view, context.coordinator)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        coordinator()
    }
    
    // MARK: - Public
    
    // MARK: - Private
}
