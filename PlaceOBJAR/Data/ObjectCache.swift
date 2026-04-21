//
//  ObjectCache.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 15/02/26.
//

import Foundation
import SceneKit


final class ObjectCache {
    static let shared = ObjectCache()
    
    private var cache = NSCache<NSString, SCNScene>()
    
    func addObjectToCache(model: ARObjectModel) -> Bool {
        guard let scene = SCNScene(named: model.modelName) else {
            return false
        }
        cache.setObject(scene, forKey: NSString(string:  model.id))
        return true
    }
    
    func getObject(id: String) -> SCNScene? {
        cache.object(forKey: NSString(string: id))
    }
}
