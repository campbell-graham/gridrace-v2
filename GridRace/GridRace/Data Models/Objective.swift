//
//  Objective.swift
//  GridRace
//
//  Created by Campbell Graham on 27/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class Objective: Codable, Equatable {
   
    static func ==(lhs: Objective, rhs: Objective) -> Bool {
        var isSame = true
        
        if lhs.id != rhs.id {
            isSame = false
        }
        if lhs.name != rhs.name {
            isSame = false
        }
        if lhs.desc != rhs.desc {
            isSame = false
        }
        if lhs.imageURL != rhs.imageURL {
            isSame = false
        }
        if lhs.hintText != rhs.hintText {
            isSame = false
        }
        if lhs.points != rhs.points {
            isSame = false
        }
        if lhs.latitude != rhs.latitude {
            isSame = false
        }
        if lhs.longitude != rhs.longitude {
            isSame = false
        }
        if lhs.objectiveType != rhs.objectiveType {
            isSame = false
        }
        
        return isSame
    }
    
   
    let id: String
    let name: String
    let desc: String
    var imageURL: URL?
    let hintText: String
    var points: Int
    let latitude: Double?
    let longitude: Double?
    let objectiveType: ObjectiveType
    
    var hintTaken: Bool {
        let value = ObjectiveManager.shared.objectivePointMap[id]
        return value != nil && value != points
    }
}

struct ObjectList: Codable {
    var places: [Objective]
    var bonus: [Objective]
}

enum ObjectiveType: String, Codable {
    case photo
    case text
    case password
}
