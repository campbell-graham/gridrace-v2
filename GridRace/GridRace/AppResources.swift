//
//  AppResources.swift
//  GridRace
//
//  Created by Campbell Graham on 26/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit


struct AppColors {
    static var textPrimaryColor = #colorLiteral(red: 0.9503886421, green: 0.9503886421, blue: 0.9503886421, alpha: 1)
    static var textSecondaryColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    static var cellColor = #colorLiteral(red: 0.2039215686, green: 0.2470588235, blue: 0.2941176471, alpha: 1)
    static var backgroundColor = #colorLiteral(red: 0.1647058824, green: 0.1960784314, blue: 0.2352941176, alpha: 1)
    static var greenHighlightColor = #colorLiteral(red: 0.07450980392, green: 0.8078431373, blue: 0.4, alpha: 1)
    static var starPointsColor = #colorLiteral(red: 0.9176470588, green: 1, blue: 0.3607843137, alpha: 1)
}

class ObjectiveManager {
    
    typealias ObjectiveID = String
    typealias Value = Int
    
    var objectivePointMap = [ObjectiveID: Value]()
  
    var completeObjectives = Set<ObjectiveID>()
    
    var savedTextResponses = [ObjectiveID: String]()
    
    //images will be saved seperately, with this dictionary pointing to their locations
    var savedImageResponses = [ObjectiveID: URL]()

    static let shared = ObjectiveManager()

    func pointValue(for objective: Objective) -> Value {
        return objectivePointMap[objective.id] ?? objective.points
    }
    
    private init() {
        
    }
}


