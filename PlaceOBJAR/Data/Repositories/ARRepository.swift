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
    
    let sizeARThumbinail = CGSize(width: 512, height: 512)
    
    func fetchLocalModels() -> [ARObjectModel] {
        let urls = Bundle.main.urls(forResourcesWithExtension: "usdz", subdirectory: nil) ?? []
        return urls.map { ARObjectModel(urlModel: $0) }
    }
    
    func generateThumbnails(for urls: [URL]) async throws -> [URL : UIImage] {
        return try await ArUtils.shared.generateAllThumbnails(urls: urls, size: sizeARThumbinail)
    }
}
