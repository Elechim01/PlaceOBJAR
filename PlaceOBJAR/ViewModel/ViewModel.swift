//
//  ViewModel.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 13/11/22.
//

import Foundation
import ARKit
import SwiftUI

class ViewModel: ObservableObject {
    
    @Published var object : [OBJCModel] =  oggetti
    
    @Published var selectObject : OBJCModel?
    
    
    static var anchor : ARAnchor?
    
    
  
    
}
var oggetti =  [OBJCModel(name: "LemonMeringuePie", modelName: "LemonMeringuePie.usdz"),
                OBJCModel(name: "AirForce", modelName: "AirForce.usdz"),
                OBJCModel(name: "chair_swan", modelName: "chair_swan.usdz"),
                OBJCModel(name: "cup_saucer_set", modelName: "cup_saucer_set.usdz"),
                OBJCModel(name: "flower_tulip", modelName: "flower_tulip.usdz"),
                OBJCModel(name: "toy_robot_vintage", modelName: "toy_robot_vintage.usdz"),
                OBJCModel(name: "toy_drummer", modelName: "toy_drummer.usdz"),
                ]
