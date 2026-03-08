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
        
        if let robot = try? await ModelEntity(named: object[1].modelName) {
            robot.name = object[1].name
            robot.generateCollisionShapes(recursive: true)
            robot.components.set(InputTargetComponent(allowedInputTypes: .all))
            
            homeEntity = robot
            anchor.addChild(robot)
        }
        
        content.add(anchor)
        homeAncor = anchor
    }
    
    func updateAR(_ content: RealityViewCameraContent) {
        if let robot = content.entities.first(where: { $0.name == object[1].name }) {
            robot.position.y -= 0.1
        }
    }
}
