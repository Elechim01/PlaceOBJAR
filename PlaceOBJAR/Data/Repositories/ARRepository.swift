//
//  ARRepositoryProtocol.swift
//  ARRepository
//
//  Created by Michele Manniello on 15/04/26.
//

import Foundation
import UIKit
import ElechimCore

class ARRepository: ARRepositoryProtocol {
    
    private let sizeARThumbinail = CGSize(width: 512, height: 512)
    
    func fetchLocalModels() -> [ARObjectModel] {
        let bundleUrls = fetchBundleURls()
        let documentsUrls = (try? fetchDocumentsURLs()) ?? [] // Gestiamo l'errore qui per non rompere l'aggregazione
        
        let allUrls = bundleUrls + documentsUrls
        return allUrls.map { ARObjectModel(urlModel: $0) }
    }
    
    // 2. Metodi PRIVATI: Nascondiamo il "come" (Encapsulation)
    // Non servono nel protocollo se servono solo internamente alla classe
    private func fetchBundleURls() -> [URL] {
        return Bundle.main.urls(forResourcesWithExtension: "usdz", subdirectory: nil) ?? []
    }
    
    private func fetchDocumentsURLs() throws -> [URL] {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }
        
        let modelsDirectory = documentDirectory.appendingPathComponent("Models")
        
        // Controllo se la cartella esiste, altrimenti contentsOfDirectory crasha/lancia errore
        if !fileManager.fileExists(atPath: modelsDirectory.path) {
            return []
        }
        
        let directoryContents = try fileManager.contentsOfDirectory(at: modelsDirectory, includingPropertiesForKeys: nil)
        return directoryContents.filter { $0.pathExtension.lowercased() == "usdz" }
    }
    
    func generateThumbnails(for urls: [URL]) async throws -> [URL: UIImage] {
        return try await ArUtils.shared.generateAllThumbnails(urls: urls, size: sizeARThumbinail)
    }
}
