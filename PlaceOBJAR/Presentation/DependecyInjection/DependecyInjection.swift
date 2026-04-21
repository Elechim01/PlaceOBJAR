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
    
    private lazy var saveExternalModelUseCase: SaveExternalModelUseCase = {
       return SaveExternalModelUseCase()
    }()
    
    private lazy var deleteModelUseCase: DeleteModelUseCase = {
       return DeleteModelUseCase()
    }()
    
    @MainActor
    func makeViewModel() -> ViewModel {
        ViewModel(loadLibraryUseCase: loadLibaryUseCase,
                  generateCacheUseCase: generateCacheUseCase,
                  saveExternalModelUseCase: saveExternalModelUseCase,
                  deleteModelUseCase: deleteModelUseCase
            )
    }
    
}
