//
//  UltilsSwift.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 15/02/26.
//

import SwiftUI
struct SheetPreviewWrapper<Content: View>: View {
    
    @State private var showSheet = true
    let content: Content
    
    init(showSheet: Bool = true, @ViewBuilder content: () -> Content) {
        self.showSheet = showSheet
        self.content = content()
    }
    var body: some View {
        Color.clear
            .sheet(isPresented: $showSheet) {
               content
            }
    }
}

extension EnvironmentValues {
    var isPreview: Bool {
        get { self[IsPreviewKey.self] }
        set { self[IsPreviewKey.self] = newValue }
    }
}

struct IsPreviewKey: EnvironmentKey {
    static let defaultValue = false
}

extension ProcessInfo {
    static var isRunningInPreview: Bool {
        processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
