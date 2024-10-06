//
//  _Preview.swift
//
//
//  Created by jsilver on 7/14/24.
//

import SwiftUI

#if DEBUG
struct _Preview: View {
    enum ContentStyle {
        case plain
        case scrollable
        
        var title: String {
            switch self {
            case .plain: "Plain Content"
            case .scrollable: "Scrollable Content"
            }
        }
    }
    
    struct DetentOption: Identifiable {
        enum Detent {
            case intrinsic
            case fixed
            case fraction
            
            var title: String {
                switch self {
                case .intrinsic: "Intrinsic"
                case .fixed: "Fixed"
                case .fraction: "Fraction"
                }
            }
        }
        
        // MARK: - Property
        var id: String { key }
        
        var key: String
        var detent: Detent
        var value: Double
        
        var sheetDetent: JSBottomSheetDetent {
            switch detent {
            case .intrinsic: .intrinsic
            case .fixed: .fixed(value)
            case .fraction: .fraction(value)
            }
        }
        
        // MARK: - Initializer
        init(_ key: String, detent: Detent = .intrinsic, value: Double = 0) {
            self.key = key
            self.detent = detent
            self.value = value
        }
        
        // MARK: - Public
        func applying(
            key: String? = nil,
            detent: Detent? = nil,
            value: Double? = nil
        ) -> Self {
            var option = self
            option.key = key ?? option.key
            option.detent = detent ?? option.detent
            option.value = value ?? option.value
            
            return option
        }
        
        // MARK: - Privatae
    }
    
    // MARK: - View
    var body: some View {
        ZStack {
            List {
                Section("Bottom Sheet") {
                    SettingItem(
                        icon: Image(systemName: "rectangle.portrait.on.rectangle.portrait"),
                        title: "Sheet Present"
                    ) {
                        Toggle(isOn: $isPresented) { EmptyView() }
                    }
                    SettingItem(
                        icon: Image(systemName: "square.stack"),
                        title: "Can Scroll"
                    ) {
                        Toggle(isOn: $canScroll) { EmptyView() }
                    }
                    SettingItem(
                        icon: Image(systemName: "list.bullet.below.rectangle"),
                        title: "Scroll Behavior"
                    ) {
                        Picker(selection: $scrollBehavior) {
                            Image(systemName: "arrow.up.arrow.down")
                                .tag(JSBottomSheetContentScrollBehavior.both)
                            Image(systemName: "arrow.up")
                                .tag(JSBottomSheetContentScrollBehavior.up)
                            Image(systemName: "arrow.down")
                                .tag(JSBottomSheetContentScrollBehavior.down)
                            Image(systemName: "xmark")
                                .tag(JSBottomSheetContentScrollBehavior.none)
                        } label: {
                            EmptyView()
                        }
                            .pickerStyle(.segmented)
                    }
                    SettingItem(
                        icon: Image(systemName: "list.bullet.below.rectangle"),
                        title: "Style"
                    ) {
                        Picker(selection: $style) {
                            Text(ContentStyle.plain.title)
                                .tag(ContentStyle.plain)
                            Text(ContentStyle.scrollable.title)
                                .tag(ContentStyle.scrollable)
                        } label: {
                            EmptyView()
                        }
                    }
                }
                
                Section("Status") {
                    SettingItem(
                        icon: Image(systemName: "rays"),
                        title: "Detent"
                    ) {
                        Picker(selection: $detentState) {
                            ForEach(detentOptions) { option in
                                Text(option.key.capitalized).tag(option.key)
                            }
                        } label: {
                            EmptyView()
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    ForEach(Array(detentOptions.enumerated()), id: \.offset) { (offset, option) in
                        SettingItem(
                            title: option.key.capitalized
                        ) {
                            Picker(selection: .init {
                                option.detent
                            } set: { detent in
                                guard offset < detentOptions.count else { return }
                                detentOptions[offset] = option
                                    .applying(detent: detent)
                            }) {
                                Text(DetentOption.Detent.intrinsic.title)
                                    .tag(DetentOption.Detent.intrinsic)
                                Text(DetentOption.Detent.fixed.title)
                                    .tag(DetentOption.Detent.fixed)
                                Text(DetentOption.Detent.fraction.title)
                                    .tag(DetentOption.Detent.fraction)
                            } label: {
                                EmptyView()
                            }
                        }
                        
                        if option.detent == .fixed || option.detent == .fraction {
                            SettingItem(
                                icon: Image(systemName: "arrow.turn.down.right"),
                                title: "Value"
                            ) {
                                TextField(value: .init {
                                    option.value
                                } set: { value in
                                    guard offset < detentOptions.count else { return }
                                    detentOptions[offset] = option
                                        .applying(value: value)
                                }, formatter: numberFormatter) {
                                    EmptyView()
                                }
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                            }
                        }
                    }
                    
                    SettingItem {
                        Button("Add Detent") {
                            switch detentOptions.count {
                            case 1:
                                detentOptions.append(.init("small"))
                                
                            case 2:
                                detentOptions.append(.init("large"))
                                
                            default:
                                break
                            }
                        }
                            .disabled(detentOptions.count == 3)
                    }
                     
                    SettingItem {
                        Button("Delete Detent") {
                            guard detentOptions.count > 1 else { return }
                            
                            let detent = detentOptions.removeLast()
                            
                            guard detentState == detent.key else { return }
                            detentState = detentOptions.last?.key ?? "tip"
                        }
                            .foregroundStyle(detentOptions.count > 1 ? .red : .gray)
                            .disabled(detentOptions.count == 1)
                    }
                }
            }
            
            JSBottomSheet(
                $isPresented,
                detentState: $detentState,
                detents: Dictionary(uniqueKeysWithValues: detentOptions.map { option in (option.key, option.sheetDetent) }),
                sheet: {
                    JSBottomSheetDefaultSheet(
                        background: Color.white.opacity(0.75)
                            .background(.thinMaterial)
                    ) {
                        Capsule().frame(width: 36, height: 5)
                            .foregroundStyle(Color(uiColor: .init(
                                red: 0x3C / 0xFF,
                                green: 0x3C / 0xFF,
                                blue: 0x43 / 0xFF,
                                alpha: 0.3
                            )))
                            .padding(.top, 5)
                    }
                }
            ) {
                switch style {
                case .plain:
                    Text("Hello JSBottomSheet")
                        .padding()
                        .border(.black)
                    
                case .scrollable:
                    ScrollView {
                        LazyVStack {
                            ForEach(0..<100, id: \.self) { id in
                                Text("\(id)")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .border(.black)
                            }
                        }
                    }
                        .trackingScroll()
                }
            }
                .config(
                    JSBottomSheetOption.self,
                    style: \.contentInsets.top,
                    to: 14
                )
                .config(
                    JSBottomSheetOption.self,
                    style: \.contentScrollBehavior,
                    to: scrollBehavior
                )
                .config(
                    JSBottomSheetOption.self,
                    style: \.canScroll,
                    to: canScroll
                )
        }
    }
    
    @ViewBuilder
    private func SettingItem<Content: View>(
        icon: Image? = nil,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        SettingItem {
            HStack {
                if let icon {
                    Text("\(icon) \(title)")
                } else {
                    Text(title)
                }
                Spacer()
                content()
            }
        }
    }
    @ViewBuilder
    private func SettingItem<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
    }
    
    // MARK: - Property
    @State
    private var isPresented: Bool = false
    @State
    private var canScroll: Bool = true
    @State
    private var scrollBehavior: JSBottomSheetContentScrollBehavior = .both
    @State
    private var style: ContentStyle = .plain
    @State
    private var detentState: String = "tip"
    @State
    private var detentOptions: [DetentOption] = [.init("tip")]
    
    @State
    private var numberFormatter: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        return formatter
    }()
}

#Preview {
    _Preview()
}
#endif
