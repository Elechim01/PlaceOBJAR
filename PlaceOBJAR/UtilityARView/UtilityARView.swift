//
//  UtilityARView.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 07/03/26.
//

import Foundation
import SwiftUI
import RealityKit

extension ViewModel {
    
    func setupAR(_ content: RealityViewCameraContent) async {
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: [0.2,0.2]))
        if let robot = try? await ModelEntity(named: objects[1].modelName) {
            robot.name = objects[1].name
            robot.generateCollisionShapes(recursive: true)
            robot.components.set(InputTargetComponent(allowedInputTypes: .all))
            
            homeEntity = robot
            anchor.addChild(robot)
        }
        
        content.add(anchor)
        homeAnchor = anchor
    }
    
    func updateAR(_ content: RealityViewCameraContent) {
        print("Update AR!!")
        guard let object3D = objectToAdd,
              let anchor = homeAnchor else { return }
        self.objectToAdd = nil
        Task {
            if let robot = try? await ModelEntity(named: object3D.modelName) {
                robot.name = object3D.name
                robot.generateCollisionShapes(recursive: true)
                robot.components.set(InputTargetComponent(allowedInputTypes: .all))
                homeEntity = robot
                anchor.addChild(robot)
            }
        }
    }
}
