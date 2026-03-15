//
//  ArUtils.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 14/03/26.
//

import Foundation
import UIKit
import QuickLookThumbnailing

class ArUtils {
    
    static let shared = ArUtils()
    
    func generateThumbnail(for url: URL, size: CGSize) async throws -> UIImage {
        let request = await QLThumbnailGenerator.Request(fileAt: url,
                                                         size: size,
                                                         scale: UIScreen.main.scale,
                                                         representationTypes: .thumbnail
        )
        let generator = QLThumbnailGenerator.shared
        return try await withCheckedThrowingContinuation { continuation in
            generator.generateBestRepresentation(for: request) { thumbnail, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let image = thumbnail?.uiImage {
                    continuation.resume(returning: image)
                } else {
                    // Caso limite: nessun errore ma nessuna immagine
                    let unknownError = NSError(domain: "ThumbnailError", code: -1, userInfo: nil)
                    continuation.resume(throwing: unknownError)
                }
            }
        }
    }
    
    func generateAllThumbnails(urls: [URL], size: CGSize) async throws  -> [URL:UIImage] {
        var results: [URL: UIImage] = [:]
        // credo un gruppo di task
        try await withThrowingTaskGroup(of: (URL,UIImage)?.self) { group in
            for url in urls {
                group.addTask { [weak self] in
                    guard let self = self else { return nil }
                    let image = try await self.generateThumbnail(for: url, size: size)
                    return (url,image)
                    
                }
            }
            
            for try await result in group {
                if let (url,image) = result {
                    results[url] = image
                }
            }
        }
        
        return results
    }
    
}
