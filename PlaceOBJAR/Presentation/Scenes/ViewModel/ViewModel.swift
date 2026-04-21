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
    private let saveExternalModelUseCase: SaveExternalModelUseCase
    private let deleteModelUseCase: DeleteModelUseCase
    
    init(
        loadLibraryUseCase: LoadLibraryUseCase,
        generateCacheUseCase: GenerateCacheUseCase,
        saveExternalModelUseCase: SaveExternalModelUseCase,
        deleteModelUseCase: DeleteModelUseCase
    ) {
        self.loadLibraryUseCase = loadLibraryUseCase
        self.generateCacheUseCase = generateCacheUseCase
        self.saveExternalModelUseCase = saveExternalModelUseCase
        self.deleteModelUseCase = deleteModelUseCase
        
        initialSetup()
    }
    
    private func initialSetup() {
        
        self.objects  = loadLibraryUseCase.execute()
        Task {
            do {
                let urls = objects.map { $0.ulrModel }
                let thumbnails = try await  generateCacheUseCase.execute(urls: urls)
                thumbnails.forEach { (key,value) in
                    CustomLog.debug(category: .VM, "Genero thumbnail \(key)")
                    ImageCache.shared.addImage(value, for: key.absoluteString)
                }
                self.isImagesReady = true
                CustomLog.debug(category: .VM, "✅ Cache completata e UI notificata")
                
            } catch {
                CustomLog.error(category: .VM, "\(error.localizedDescription)")
                Utils.showError(alertMessage: &errorMessage, showAlert: &showError, from: error)
                
            }
        }
    }
    
    func reloadView() {
        self.isImagesReady = false
        self.objects = []
        initialSetup()
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
        
        CustomLog.debug(category: .VM, "Rotaton Z:\(zRotation), V: \(vRotation), H: \(hRotation)")
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
    
    func loadModel(arObject object: ARObjectModel)  throws -> ModelEntity {
        if let cachedModel = modelCache[object.name] {
            return cachedModel.clone(recursive: true)
        }
        let newModel = try  ModelEntity.loadModel(contentsOf: object.ulrModel)
        self.modelCache[object.name] = newModel
        return newModel.clone(recursive: true)
        
    }
    
    func handleFilePickerImportResult(_ result: Result<URL,Error>) {
        switch result {
        case .success(let url):
            loadExternalModel(from: url)
        case .failure(let error):
            CustomLog.error(category: .VM, "Errore picker: \(error.localizedDescription)")
            Utils.showError(alertMessage: &errorMessage,
                            showAlert: &showError,
                            from: error)
        }
    }
    
    private func loadExternalModel(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            self.errorMessage = "Accesso negato al file"
            self.showError = true
            return
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        do {
            let localUrl =   try saveExternalModelUseCase.execute(from: url)
            let arObjectModel = ARObjectModel(urlModel: localUrl)
            
            Task {
                let thumbnail = try await generateCacheUseCase.execute(urls: [localUrl])
                if let image = thumbnail[localUrl] {
                    ImageCache.shared.addImage(image, for: localUrl.absoluteString)
                }
                self.objects.append(arObjectModel)
            }
            
        } catch  {
            CustomLog.error(category: .VM, "\(error.localizedDescription)")
            Utils.showError(alertMessage: &errorMessage, showAlert: &showError, from: error)
        }
    }
    
    func deleteModel(from object: ARObjectModel) {
        do {
            try deleteModelUseCase.execute(at: object.ulrModel)
            ImageCache.shared.deleteImage(for: object.ulrModel.absoluteString)
            self.objects.removeAll { $0.id == object.id }
            
        } catch  {
            CustomLog.error(category: .VM, "\(error.localizedDescription)")
            Utils.showError(alertMessage: &errorMessage, showAlert: &showError, from: error)
        }
    }
    
}
