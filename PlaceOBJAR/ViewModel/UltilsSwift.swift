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
