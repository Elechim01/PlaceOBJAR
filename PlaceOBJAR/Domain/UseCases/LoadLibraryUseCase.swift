//
//  LoadLibraryUseCase.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 15/04/26.
//

import Foundation

final class LoadLibraryUseCase {
    
    private let repository: ARRepositoryProtocol
    
    init(repository: ARRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() -> [ARObjectModel] {
        return repository.fetchLocalModels()
    }
}
