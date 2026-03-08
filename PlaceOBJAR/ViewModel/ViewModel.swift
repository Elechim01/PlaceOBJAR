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
    var initialRotation: simd_quatf?
    var initialScale: SIMD3<Float>?
        
    static var anchor: ARAnchor?
    
    static var anchorEntity: AnchorEntity?
    // Teniamo traccia di entrambi gli angoli
    var horizontalAngle: Double = 0 { didSet { updateRotation() } }
    var verticalAngle: Double = 0  { didSet { updateRotation() } }
    var rollAngle: Double = 0 { didSet { updateRotation() } }
    
    
    func addEntity(object3D: OBJCModel) {
    // TODO: .reality non posso essere aggiungi a modelEntity, Per i file .reality, devi caricare l'intera Entity o la Scene.
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
    
    private func updateRotation() {
        
        let toRad = Float.pi / 180.0
        
        // 1. Convertiamo entrambi in radianti
        let hGradi = Float(horizontalAngle)
        let vRadians = Float(verticalAngle) * toRad
        let zRadiants = Float(rollAngle) * toRad
        
        // 2. Creiamo i due quaternioni separati
        // Rotazione orizzontale (attorno all'asse Y)
        let hRotation = simd_quatf(angle: hGradi, axis: [0, 1, 0])
        
        // Rotazione verticale (attorno all'asse X)
        let vRotation = simd_quatf(angle: vRadians, axis: [1, 0, 0])
        
//        Rotazione Roll (asse Z)
        let zRotation = simd_quatf(angle: zRadiants, axis: [0,0,1])
        
        print(zRotation)
        print(vRotation)
        print(hRotation)
        // 3. LA MAGIA: Moltiplichiamo i quaternioni
        // L'ordine conta! Solitamente si fa H * V per ruotare "sul posto"
        let finalRotation = hRotation * vRotation * zRotation
        
        // 4. Applichiamo la rotazione combinata
        homeEntity.transform.rotation = finalRotation
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
