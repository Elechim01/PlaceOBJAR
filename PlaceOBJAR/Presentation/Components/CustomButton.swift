//
//  CustomButton.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 13/11/22.
//

import SwiftUI
import CachedAsyncImage

struct CustomButton: View {
    
    var onTap: () ->()
    var object3D : ARObjectModel
    
    init(object3D: ARObjectModel, onTap: @escaping () -> Void,) {
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
                    if let image = thumbnail(for: object3D){
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
    
   private func thumbnail(for object: ARObjectModel) -> UIImage? {
        ImageCache.shared.getImage(for: object.ulrModel.absoluteString)
    }
}

struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
