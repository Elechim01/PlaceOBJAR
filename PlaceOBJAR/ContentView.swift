//
//  ContentView.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 13/11/22.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    @State var viewModel: ViewModel = ViewModel()
    
    @State private var showSheet: Bool = false
    @State private var slider: Float = 0.005
    @Environment(\.isPreview) var isPreview

    var body: some View {
        ZStack() {
            if !isPreview {
                arView
                   .ignoresSafeArea()
            }
        
            controlPanel
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
               
            HStack {
                VerticalRotationSlider()
                    .environment(viewModel)
                
                Giroscope()
                    .environment(viewModel)
                    .padding(.top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding()
        }
        .sheet(isPresented: $showSheet) {
            CustomBottomSheet()
                .environment(viewModel)
        }
    }
    
    var controlPanel: some View {
        HStack(spacing: 15) {
            HStack(spacing: 20) {
                Button {
                    viewModel.homeAncor?.removeChild(viewModel.homeEntity)
                } label: {
                    Image(systemName: "trash")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                
                Button {
                    showSheet.toggle()
                } label: {
                    Image(systemName: "plus.app")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
            }
            
            if !viewModel.homeEntity.name.isEmpty  {
                Text("Entity Selected: \(viewModel.homeEntity.name)")
            }
        }
    
    }
    
    var arView: some View {
        RealityView { content in
            content.camera = .spatialTracking
            await  viewModel.setupAR(content)
        } update: { content in
            viewModel.updateAR(content)
        } placeholder: {
            VStack {
                Spacer()
                Text("Metti il telefono davanti ad un piano")
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .gesture(viewModel.arGestures())
        .gesture(viewModel.selectEntityGesture())
    }
}

struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


extension EnvironmentValues {
    var isPreview: Bool {
        get { self[IsPreviewKey.self] }
        set { self[IsPreviewKey.self] = newValue }
    }
}

private struct IsPreviewKey: EnvironmentKey {
    static let defaultValue = false
}
