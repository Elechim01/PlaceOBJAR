//
//  ViewModel.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 13/11/22.
//

import Foundation
import RealityKit
import SwiftUI
import ARKit

@MainActor
@Observable
class ViewModel {
    
    var object: [OBJCModel] =  oggetti
    
    var selectObject: OBJCModel?
    
    var homeEntity: Entity = .init()
    
    var homeAncor: AnchorEntity?
        
    static var anchor: ARAnchor?
    
    static var anchorEntity: AnchorEntity?
    
    func addEntity(object3D: OBJCModel) {
        guard let homeAncor = self.homeAncor else { return }
        Task {
            if let robot = try? await ModelEntity(named: object3D.modelName) {
                 robot.name = object3D.name
                 robot.generateCollisionShapes(recursive: true)
                 robot.components.set(InputTargetComponent(allowedInputTypes: .all))
                 homeEntity = robot
                 homeAncor.addChild(robot)
             }
        }
        
    }
    
    init() {
        Task(priority: .high) {
            loadModel()
        }
    }
    
    func loadModel() {
        var listOfError: [String:Bool] = [:]
        oggetti.forEach { model in
           let noProblem = ObjectCache.shared.addObjectToCache(model: model)
            if noProblem == false {
                listOfError[model.name] = noProblem
            }
            
        }
        
        listOfError.enumerated().forEach { element in
            print("\(element.element.key) ,\(element.element.value)")
            
        }
    }
    
    
}

var oggetti =  [
    OBJCModel(name: "LemonMeringuePie", modelName: "LemonMeringuePie.usdz"),
    OBJCModel(name: "AirForce", modelName: "AirForce.usdz"),
    OBJCModel(name: "chair_swan", modelName: "chair_swan.usdz"),
    OBJCModel(name: "cup_saucer_set", modelName: "cup_saucer_set.usdz"),
    OBJCModel(name: "flower_tulip", modelName: "flower_tulip.usdz"),
    OBJCModel(name: "toy_robot_vintage", modelName: "toy_robot_vintage.usdz"),
    OBJCModel(name: "toy_drummer", modelName: "toy_drummer.usdz"),
]
