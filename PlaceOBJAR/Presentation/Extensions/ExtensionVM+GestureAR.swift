//
//  UtilityGestureAR.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 07/03/26.
//

import Foundation
import SwiftUI
import RealityKit

extension ViewModel {
    // Entity selection
    func selectEntityGesture() -> some Gesture {
        SpatialEventGesture()
            .targetedToAnyEntity()
            .onEnded {[weak self]  value in
                guard let self = self else { return }
                if value.entity is ModelEntity {
                    self.addSelectionFeedback(to:  value.entity as! ModelEntity)
                }
                self.homeEntity = value.entity
                print("Selezionata: \(value.entity.name)")
            }
    }
    
    // Combined gestures: pinch, rotate, drag
    func arGestures() -> some Gesture {
        // 1. Usa MagnifyGesture (specifico per il 3D) invece di MagnificationGesture
        let pinch = MagnifyGesture()
            .targetedToAnyEntity()
            .onChanged(scaleChanged)
            .onEnded {  [weak self]  _ in
                guard let self = self else { return }
                self.initialScale = nil
            }
        
        let drag = DragGesture()
            .targetedToAnyEntity()
            .onChanged(dragChanged)
        
        // 2. Usa exclusively per separare pinch e rotate, mantenendo il drag separato
        return pinch.simultaneously(with: drag)
    }
    
    // MARK: Gesture callbacks
    func scaleChanged(_ value: EntityTargetValue<MagnifyGesture.Value>) {
        // Usiamo l'entità direttamente intercettata dalla gesture
        let entity = value.entity
        
        if initialScale == nil {
            initialScale = entity.transform.scale
        }
        
        // Estraiamo il valore numerico della gesture usando .magnification
        let magnificationFactor = Float(value.magnification)
        
        let newScale = initialScale! * SIMD3<Float>(repeating: magnificationFactor)
        
        entity.transform.scale = simd_clamp(
            newScale,
            SIMD3<Float>(repeating: 0.0035),
            SIMD3<Float>(repeating: 0.1)
        )
    }
    
    func rotateChanged(_ value: EntityTargetValue<RotateGesture.Value>) {
        let entity = homeEntity
        if initialRotation == nil { initialRotation = entity.transform.rotation }
        
        let delta = simd_quatf(angle: Float(value.rotation.radians), axis: [0,1,0])
        entity.transform.rotation = initialRotation! * delta
    }
    
    func dragChanged(_ value: EntityTargetValue<DragGesture.Value>) {
        let entity = value.entity
        guard let parent = entity.parent else { return }
        entity.position =
        value.unproject(value.location, from: .local, to: parent)
        ?? entity.position
    }
}
