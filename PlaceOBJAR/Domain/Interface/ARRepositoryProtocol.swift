//
//  ARRepositoryProtocol.swift
//  PlaceOBJAR
//
//  Created by Michele Manniello on 15/04/26.
//

import Foundation
import UIKit

protocol ARRepositoryProtocol {
    func fetchLocalModels() -> [ARObjectModel]
    func generateThumbnails(for urls: [URL])  async throws -> [URL: UIImage]
}
