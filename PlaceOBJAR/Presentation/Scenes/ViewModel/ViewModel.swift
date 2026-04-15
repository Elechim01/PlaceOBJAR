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
import ElechimCore

@MainActor
@Observable
class ViewModel {
    
    var objects: [ARObjectModel] = []
    var selectObject: ARObjectModel?
    var homeEntity: Entity = .init()
    var objectToAdd: ARObjectModel? = nil
    var homeAnchor: AnchorEntity?
    var initialRotation: simd_quatf?
    var initialScale: SIMD3<Float>?
    var errorMessage: String = ""
    var showError: Bool = false
    var isTrackingPlane: Bool = false
    var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    private var controllers: [AnimationPlaybackController] = []
    
    var controllersIsPlay: Bool {
        controllers.isEmpty
    }
    
    let idSelectionBox = "selection_box"
    
    // static var anchor: ARAnchor?
    var isImagesReady = false
    // Teniamo traccia di entrambi gli angoli
    var horizontalAngle: Double = 0 { didSet { updateRotation() } }
    var verticalAngle: Double = 0  { didSet { updateRotation() } }
    var rollAngle: Double = 0 { didSet { updateRotation() } }
    private var modelCache: [String: ModelEntity] = [:]
    
    // Dependencies (Injected)
    private let loadLibraryUseCase: LoadLibraryUseCase
    private let generateCacheUseCase: GenerateCacheUseCase
    
    init(
        loadLibraryUseCase: LoadLibraryUseCase,
        generateCacheUseCase: GenerateCacheUseCase
    ) {
        self.loadLibraryUseCase = loadLibraryUseCase
        self.generateCacheUseCase = generateCacheUseCase
        
        initialSetup()
    }
    
    func initialSetup() {
        
        self.objects  = loadLibraryUseCase.execute()
        Task {
            do {
                let urls = objects.map { $0.ulrModel }
                let thumbnails = try await  generateCacheUseCase.execute(urls: urls)
                thumbnails.forEach { (key,value) in
                    print("Genero thumbnail \(key)")
                    ImageCache.shared.addImage(value, for: key.absoluteString)
                }
                self.isImagesReady = true
                print("✅ Cache completata e UI notificata")
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
                    scene.subscribe(to: AnimationEvents.PlaybackCompleted.self) {[weak self]  event in
                        guard let self = self else { return }
                        Task { @MainActor  [weak self] in
                            guard let self = self else { return }
                            withAnimation { [weak self] in
                                guard  let self = self  else { return }
                                self.controllers.removeAll()
                            }
                        }
                    }.store(in: &cancellables)
                }
                controllers.append(controller)
            }
            
        } else {
            controllers.forEach { $0.stop()}
            controllers.removeAll()
            cancellables.removeAll()
        }
    }
    
    func deleteEntity() {
        homeAnchor?.removeChild(homeEntity)
        let remainingEntities =  homeAnchor?.children.filter { $0.name != idSelectionBox
        }
        if let nextEntity = remainingEntities?.first as? ModelEntity {
            homeEntity = nextEntity
            // Opzionale: aggiungi il feedback visivo alla nuova entità selezionata
            addSelectionFeedback(to: nextEntity)
        }
    }
    
    func loadModel(named name: String) async throws -> ModelEntity {
        if let cachedModel = modelCache[name] {
            return cachedModel.clone(recursive: true)
        }
        let newModel = try await ModelEntity(named: name)
        self.modelCache[name] = newModel
        return newModel.clone(recursive: true)
        
    }
    
}
