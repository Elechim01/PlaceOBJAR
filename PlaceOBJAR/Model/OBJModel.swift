//
//  OBJModel.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 13/11/22.
//

import Foundation
import CachedAsyncImage
import UIKit

struct OBJCModel:Identifiable, Equatable, Hashable {
    var id =  UUID().uuidString
    var name: String
    var modelName:String
    var ulrModel: URL
    
    
    
    init(urlModel: URL) {
        self.ulrModel = urlModel
        self.modelName = urlModel.lastPathComponent
        
        name =  OBJCModel.getModelname(modelNamePath: modelName)
    }
    
    static func getModelname(modelNamePath: String)-> String {
        return  String(modelNamePath.split(separator: ".").first!)
    }
    
    func getImageModel() -> UIImage? {
        print(self.ulrModel)
        return  ImageCache.shared.getImage(for: self.ulrModel.absoluteString)
    }
    
    static func == (lhs: OBJCModel, rhs: OBJCModel) -> Bool {
        lhs.id == rhs.id && lhs.ulrModel == rhs.ulrModel
    }
    
}
