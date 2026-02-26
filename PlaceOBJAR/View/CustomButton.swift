//
//  CustomButton.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 13/11/22.
//

import SwiftUI
import SceneKit

struct CustomButton: View {
    
    @Environment(ViewModel.self) var viewModel
    
    var object3D : OBJCModel
    @Environment(\.dismiss) private var dismss
   
    @State var scene: SCNScene?
    // Add cache like image caching 
    var body: some View {
        VStack {
            if let scene  {
                Button {
                    viewModel.addEntity(object3D: object3D)
                    dismss()
                } label: {
                    
                    SceneView(scene: scene  ,options: [.autoenablesDefaultLighting,.allowsCameraControl])
                        .frame(width: 130,height: 130)
                    
                }
                .cornerRadius(30)
                .padding(.top)
                .padding(.horizontal)
            } else {
                ProgressView()
            }
            
        }
        .onAppear {
            scene = ObjectCache.shared.getObject(id: object3D.id)
        }
        
    }
    
    
    
    
    

}

struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
