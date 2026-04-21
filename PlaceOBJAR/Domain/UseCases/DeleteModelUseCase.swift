//
//  DeleteModelUseCase.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 20/04/26.
//

import Foundation
import ElechimCore

final class DeleteModelUseCase {
    func execute(at url: URL) throws {
        let fileManager = FileManager.default
        guard url.path().contains("/Documents") else {
            throw CustomError.internalFile
        }
        
        if fileManager.fileExists(atPath: url.path()) {
            try fileManager.removeItem(atPath: url.path())
        }
        
    }
}
