//
//  ObjectiveUserData.swift
//  GridRace
//
//  Created by Campbell Graham on 5/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

class ObjectiveUserData: Codable {
    
    let objectiveID: String
    var adjustedPoints: Int?
    var completed: Bool = false
    var imageURL: URL?
    var textResponse: String?
    
    init(id: String) {
        objectiveID = id
    }
}
