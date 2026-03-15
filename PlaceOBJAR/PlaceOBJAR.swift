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
    @State var viewModel: ViewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            HomePageView()
                .environment(viewModel)
        }
    }
}
