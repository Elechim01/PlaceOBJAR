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
import CachedAsyncImage
import Combine

@MainActor
@Observable
class ViewModel {
    
    var objects: [OBJCModel] =  []
    var selectObject: OBJCModel?
    
    var homeEntity: Entity = .init()
    var objectToAdd: OBJCModel? = nil
    
    var homeAnchor: AnchorEntity?
    
    var initialRotation: simd_quatf?
    var initialScale: SIMD3<Float>?
    private var subscription: AnyCancellable?
    private var controllers: [AnimationPlaybackController] = []
    var controllersIsPlay: Bool {
        controllers.isEmpty
    }
    
    // static var anchor: ARAnchor?
    var isImagesReady = false
    // Teniamo traccia di entrambi gli angoli
    var horizontalAngle: Double = 0 { didSet { updateRotation() } }
    var verticalAngle: Double = 0  { didSet { updateRotation() } }
    var rollAngle: Double = 0 { didSet { updateRotation() } }
    
    init() {
        loadModel()
    }
    
    func loadModel() {
        
        let folderPath = Bundle.main.urls(forResourcesWithExtension: "usdz", subdirectory: nil) ?? []
        let objects3d = folderPath.map { url in
            OBJCModel(urlModel: url)
        }
        
        self.objects = objects3d
        generateImageModel(folderPath: folderPath)
    }
    
    private func generateImageModel(folderPath urls: [URL]) {
        // Cerchiamo il percorso della cartella "Modelli" nel bundle
        print("Genero la cache")
        Task() {
            do {
                let result = try await ArUtils.shared.generateAllThumbnails(urls: urls, size: CGSize(width: 512, height: 512))
                result.forEach { (key,value) in
                    print("Genero thumbnail \(key)")
                    ImageCache.shared.addImage(value, for: key.absoluteString)
                }
                await MainActor.run {
                    self.isImagesReady = true
                    print("✅ Cache completata e UI notificata")
                }
            } catch {
                print(error.localizedDescription)
            }
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
    
    
    func buttonPlayPauseAction() {
        if controllers.isEmpty {
            for animation in homeEntity.availableAnimations {
                let controller = homeEntity.playAnimation(animation.repeat(count: 1))
                if let scene = homeEntity.scene {
                    subscription =  AnyCancellable(scene.subscribe(to: AnimationEvents.PlaybackCompleted.self) {[weak self]  event in
                        guard let self = self else { return }
                        Task { @MainActor  [weak self] in
                            guard let self = self else { return }
                            withAnimation { [weak self] in
                                guard  let self = self  else { return }
                                self.controllers.removeAll()
                            }
                            self.subscription?.cancel()
                        }
                    })
                }
                controllers.append(controller)
            }
            
        } else {
            controllers.forEach { $0.stop()}
            controllers.removeAll()
        }
    }
    
    //TODO:  AGGIUNGERE NIEW SYSTEM CACHE EntityModel
    /// mettere un dizionari di EntityModel, e far ritornare il .clone(recursive: true)
    
}
