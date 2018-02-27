//
//  Objective.swift
//  GridRace
//
//  Created by Campbell Graham on 27/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class Objective: Codable {
    
    let name: String
    let desc: String
    let hintText: String
    var pointsCount: Int = 0
    var hintViewed: Bool = false
}

struct ObjectList: Codable {
    var objects: [Objective]
}
