//
//  LookUp.swift
//
//
//  Created by jsilver on 6/26/24.
//

import Foundation
import SwiftUI

class LookUpViewController<
    Content: View
>: UIHostingController<Content> {
    // MARK: - View
    
    // MARK: - Property
    private var predicate: ((UIView) -> Bool)?
    private var handler: ((UIView) -> Void)?
    
    // MARK: - Initializer
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let view else { return }
        lookUp(view).forEach { view in handler?(view) }
    }
    
    // MARK: - Public
    func update(_ content: Content, predicate: @escaping (UIView) -> Bool, lookedUp handler: @escaping (UIView) -> Void) {
        rootView = content
        
        self.predicate = predicate
        self.handler = handler
    }
    
    // MARK: - Private
    private func lookUp(_ view: UIView) -> [UIView] {
        [view] + view.subviews.flatMap { view in lookUp(view) }
            .filter { view in predicate?(view) ?? false }
    }
}

struct LookUp<
    Coordinator,
    Content: View
>: UIViewControllerRepresentable {
    // MARK: - Property
    private let coordinator: () -> Coordinator
    
    private let predicate: (UIView) -> Bool
    private let handler: (UIView, Coordinator) -> Void
    private let content: Content
    
    // MARK: - Initializer
    init(
        coordinator: @escaping () -> Coordinator = { },
        predicate: @escaping (UIView) -> Bool,
        lookedUp handler: @escaping (UIView, Coordinator) -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.coordinator = coordinator
        self.predicate = predicate
        self.handler = handler
        self.content = content()
    }
    
    init<LookUpView: UIView>(
        _ lookUpView: LookUpView.Type,
        coordinator: @escaping () -> Coordinator = { },
        lookedUp handler: @escaping (LookUpView, Coordinator) -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            coordinator: coordinator,
            predicate: { view in view is LookUpView },
            lookedUp: { view, coordinator in
                guard let view = view as? LookUpView else { return }
                handler(view, coordinator)
            },
            content: content
        )
    }
    
    // MARK: - Lifecycle
    func makeUIViewController(context: Context) -> LookUpViewController<Content> {
        let viewController = LookUpViewController<Content>(
            rootView: content
        )
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: LookUpViewController<Content>, context: Context) {
        uiViewController.update(content) { view in
            predicate(view)
        } lookedUp: { view in
            handler(view, context.coordinator)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        coordinator()
    }
    
    // MARK: - Public
    
    // MARK: - Private
}
