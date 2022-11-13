//
//  CustomButton.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 13/11/22.
//

import SwiftUI
import SceneKit

struct CustomButton: View {
    var object3D : OBJCModel
    @EnvironmentObject var model: ViewModel
    var body: some View {
        Button {
           
            model.selectObject = object3D
        } label: {
            SceneView(scene: SCNScene(named: object3D.modelName),options: [.autoenablesDefaultLighting,.allowsCameraControl])
                .frame(width: 130,height: 130)
        }
        .cornerRadius(30)
        .padding(.top)
        .padding(.horizontal)

    }
}

struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
