//
//  OBJModel.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 13/11/22.
//

import Foundation

struct OBJCModel:Identifiable {
    var id =  UUID().uuidString
    var name: String
    var modelName:String
    
    var getModelname: String {
        return  String(modelName.split(separator: ".").first!)
    }
}
extension Notification.Name{
    static let taskAddedNotification = Notification.Name("TaskAddedNotification")
}
