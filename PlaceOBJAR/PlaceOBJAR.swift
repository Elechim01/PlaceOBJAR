//
//  PlaceOBJAR.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 13/11/22.
//

import UIKit
import SwiftUI

@main
struct PlaceObJAR: App {
    private let dependecyInjection = DependecyInjection()
    @State var viewModel: ViewModel
    
    init() {
        let vm = dependecyInjection.makeViewModel()
        self._viewModel = State(wrappedValue: vm)
    }
    
    var body: some Scene {
        WindowGroup {
            HomePageView()
                .environment(viewModel)
        }
    }
}
