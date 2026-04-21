//
//  UtilityARView.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 07/03/26.
//

import Foundation
import SwiftUI
import RealityKit
import ElechimCore

extension ViewModel {
    
    func setupAR(_ content: RealityViewCameraContent) async {
        CustomLog.debug(category: .VM, "Setup AR!!")
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: [0.2,0.2]))
        do {
            let entity = try  self.loadModel(arObject: objects[1])
            let name = objects[1].name
            entity.name = name
            
            entity.generateCollisionShapes(recursive: true)
            entity.components.set(InputTargetComponent(allowedInputTypes: .all))
            // --FIX ASSE Y ---
            normalizeY(entity: entity)
            addSelectionFeedback(to: entity)
            homeEntity = entity
            anchor.addChild(entity)
            
            
        } catch  {
            CustomLog.error(category: .VM, "\(error.localizedDescription)")
            Utils.showError(alertMessage: &self.errorMessage, showAlert: &self.showError, from: error)
        }
        
        content.add(anchor)
        homeAnchor = anchor
        if let scene =  homeEntity.scene, let anchor = homeAnchor {
            scene.subscribe(to: SceneEvents.AnchoredStateChanged.self,on: anchor) { [weak self] event in
                guard let self = self else { return }
                if event.isAnchored {
                    Task{ @MainActor in
                        withAnimation {
                            self.isTrackingPlane = true
                        }
                    }
                }
            }
            .store(in: &cancellables)
        } else {
            self.isTrackingPlane = true
        }
    }
    
    func updateAR(_ content: RealityViewCameraContent) {
        CustomLog.debug(category: .VM, "Update AR!!")
        guard let object3D = objectToAdd,
              let anchor = homeAnchor else { return }
        self.objectToAdd = nil
       
            do {
                let entity = try  self.loadModel(arObject: object3D)
                entity.name = object3D.name
                
                entity.generateCollisionShapes(recursive: true)
                entity.components.set(InputTargetComponent(allowedInputTypes: .all))
                // --FIX ASSE Y ---
                normalizeY(entity: entity)
                addSelectionFeedback(to: entity)
                homeEntity = entity
                anchor.addChild(entity)
            } catch  {
                CustomLog.error(category: .VM, "\(error.localizedDescription)")
                Utils.showError(alertMessage: &self.errorMessage, showAlert: &self.showError, from: error)
            }
    }
    
    private func normalizeY(entity: ModelEntity) {
        // Calcoliamo i confini rispetto all'entità stessa (spazio locale)
        let realitveBoundingBox = entity.visualBounds(relativeTo: nil)
        
        // Se min.y è -0.5, significa che l'oggetto va sotto il pivot di 0.5m
        // Portandolo a 0, la base toccherà terra perfettamente.
        
        let yOffset = realitveBoundingBox.min.y
        
        entity.position.y -= yOffset
        
        CustomLog.debug(category: .VM, "Normalizzazione Y applicata: \(yOffset) metri")
    }
    
    
    func addSelectionFeedback(to entity: ModelEntity) {
        
        
        homeEntity.findEntity(named: self.idSelectionBox)?.removeFromParent()
        // 1. prendiamo le dimensioni del modello
        let bounds = entity.visualBounds(relativeTo: entity)
        
        // 2. creiamo una mesh sferica delle stesse dimensioni
        
        let sphereRadius = max(bounds.extents.x, bounds.extents.y, bounds.extents.z) * 0.06
        let sphere = MeshResource.generateSphere(radius: sphereRadius)
        
        //3. creiamo un materiale semplice
        let material = UnlitMaterial(color: .systemBlue.withAlphaComponent(0.3))
        
        //4. crediamo l'entita
        let selectionContainer = ModelEntity(mesh: sphere, materials: [material])
        selectionContainer.name = self.idSelectionBox
        selectionContainer.components.set(BillboardComponent())
        
        // aggiunta testo

        let textMesh = MeshResource.generateText(
            "Elemento selezionato",
            extrusionDepth: 0.001, // 1 millimetro di spessore (molto più realistico)
            font: .systemFont(ofSize: 0.03, weight: .bold), // 3 centimetri di altezza
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        let textMaterial = UnlitMaterial(color: .white)
        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        let parentScale = entity.scale.x
        if parentScale > 0 {
            textEntity.scale = [1.0 / parentScale, 1.0 / parentScale, 1.0 / parentScale]
        }
        let textCenter = textMesh.bounds.center.x
        textEntity.position = [-textCenter * (1.0 / parentScale), sphereRadius + 0.02, 0]
        selectionContainer.addChild(textEntity)
        
        
        // --- POSIZIONAMENTO FINALE ---
        let gap = bounds.extents.y * 0.2
        selectionContainer.position = [0, bounds.max.y + gap + 0.02, 0]
        
        entity.addChild(selectionContainer)
    }
    
}
