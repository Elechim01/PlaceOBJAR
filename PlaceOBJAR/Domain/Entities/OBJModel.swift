//
//  OBJModel.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 13/11/22.
//

import Foundation
import CachedAsyncImage
import UIKit

struct ARObjectModel:Identifiable, Equatable, Hashable {
    
    var id =  UUID().uuidString
    var name: String
    var modelName:String
    var ulrModel: URL
    
    init(urlModel: URL) {
        self.ulrModel = urlModel
        self.modelName = urlModel.lastPathComponent
        self.name = urlModel.deletingPathExtension().lastPathComponent
    }
    static func == (lhs: ARObjectModel, rhs: ARObjectModel) -> Bool {
        lhs.id == rhs.id && lhs.ulrModel == rhs.ulrModel
    }
}
