//
//  DependecyInjection.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 15/04/26.
//

import Foundation

class DependecyInjection {
    
   private lazy var arRepository: ARRepositoryProtocol = {
        return ARRepository()
    }()
    
    private lazy var loadLibaryUseCase: LoadLibraryUseCase = {
        return LoadLibraryUseCase(repository: arRepository)
    }()
    
    private lazy var generateCacheUseCase: GenerateCacheUseCase = {
        return GenerateCacheUseCase(repository: arRepository)
    }()
    
    @MainActor
    func makeViewModel() -> ViewModel {
        ViewModel(loadLibraryUseCase: loadLibaryUseCase,
                  generateCacheUseCase: generateCacheUseCase)
    }
    
}
