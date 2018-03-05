//
//  Objective.swift
//  GridRace
//
//  Created by Campbell Graham on 27/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

class Objective: Codable {

    let id: String
    let name: String
    let desc: String
    var imageURL: URL?
    let hintText: String
    var points: Int
    let latitude: Double?
    let longitude: Double?
    let objectiveType: ObjectiveType
    var coordinate: CLLocationCoordinate2D? {

        if let lat = latitude, let long = longitude {
            let cord = CLLocationCoordinate2D(latitude: lat, longitude: long)
            return cord
        }

        return nil
    }
    
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
