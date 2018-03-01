//
//  Objective.swift
//  GridRace
//
//  Created by Campbell Graham on 27/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class Objective: Codable {
    
    let id: Int
    let name: String
    let desc: String
    var imageURL: URL?
    let hintText: String
    var points: Int = 0
    let latitude: Double?
    let longitude: Double?

}

struct ObjectList: Codable {
    var objects: [Objective]
}
