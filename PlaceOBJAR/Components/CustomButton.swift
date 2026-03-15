//
//  CustomButton.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 13/11/22.
//

import SwiftUI

struct CustomButton: View {
    
    var onTap: () ->()
    var object3D : OBJCModel
    
    init(object3D: OBJCModel, onTap: @escaping () -> Void,) {
        self.onTap = onTap
        self.object3D = object3D
    }
    
    @Environment(\.dismiss) private var dismss
    @Environment(\.isPreview) private var isPreview
    
    
    var body: some View {
        VStack {
            Button {
                onTap()
                dismss()
            } label: {
                VStack {
                    if let image = object3D.getImageModel(){
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Text("NO Image")
                    }
                    
                    Text(object3D.name)
                        .padding(.horizontal)
                }
            }
            .cornerRadius(30)
            .padding(.top)
            .padding(.horizontal)
        }
        
    }
}

struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
