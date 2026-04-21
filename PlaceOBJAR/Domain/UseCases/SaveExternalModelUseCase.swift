//
//  SaveExternalModelUseCase.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 20/04/26.
//

import Foundation

final class SaveExternalModelUseCase {
    func execute(from source: URL) throws -> URL {
        let fileManager = FileManager.default
        
        // 1. Definiamo la cartella di destinazione (Documents/Models)
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let modelsDirectory = documentsURL.appendingPathComponent("Models", isDirectory: true)
        
        // 2. Controlliamo se esiste la cartella
        if !fileManager.fileExists(atPath: modelsDirectory.path()) {
            try fileManager.createDirectory(at: modelsDirectory, withIntermediateDirectories: true)
        }
        // 3. Prepariamo l'url di destinazione mantenendo il nome originale
        let destinationURL = modelsDirectory.appendingPathComponent(source.lastPathComponent)
        
        // 4. se esiste già un file con lo stesso nome lo rinominiamo
        if fileManager.fileExists(atPath: destinationURL.path()){
            try fileManager.removeItem(at: destinationURL)
        }
        
        // 5.copiamo il file
        try fileManager.copyItem(at: source, to: destinationURL)
        
        return destinationURL
    }
}
