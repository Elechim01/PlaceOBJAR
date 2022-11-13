//
//  ARViewContainer.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 13/11/22.
//

import SwiftUI
import RealityKit
import ARKit


struct ARViewContainer: UIViewRepresentable {
    
    @EnvironmentObject var viewModel: ViewModel
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
    
        arView.enableTapGesture()

        return arView
        
    }
   
    
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
        uiView.scene.anchors.removeAll()
        print("Rimuovo tutto")

        guard let object = viewModel.selectObject else { return}
        guard let anchor = ViewModel.anchor else { return  }
        uiView.placeObject(named: object.getModelname, for:anchor)
        
    }
    
    
}

extension ARView{
    
    
    func enableTapGesture(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc
    func handleTap(recognizer:UITapGestureRecognizer) {
        let location = recognizer.location(in: self)
        let results = self.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        if let firstResult = results.first{
            let anchor = ARAnchor(name: "Piano", transform: firstResult.worldTransform)
            ViewModel.anchor = anchor
            print(anchor)
            self.session.add(anchor: anchor)
            print("caricato")
            NotificationCenter.default.post(name: Notification.Name.taskAddedNotification, object: "")
        }
    }
    
    func placeObject(named entityName: String,for anchor: ARAnchor){
        
        
        let newEntity = try! ModelEntity.loadModel(named: entityName)
        newEntity.generateCollisionShapes(recursive: true)
        self.installGestures([.rotation,.translation,.scale],for: newEntity)
         let anchorEntity =  AnchorEntity(anchor: anchor)
            anchorEntity.addChild(newEntity)
            self.scene.addAnchor(anchorEntity)
        
        
    }
}
