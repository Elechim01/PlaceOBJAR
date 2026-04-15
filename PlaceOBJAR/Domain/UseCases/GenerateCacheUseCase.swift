//
//  GenerateCacheUseCase.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 15/04/26.
//

import Foundation
import UIKit

final class GenerateCacheUseCase {
    private let repository: ARRepositoryProtocol
    
    init(repository: ARRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(urls: [URL]) async throws -> [URL: UIImage] {
        return try await repository.generateThumbnails(for: urls)
    }
}
