//
//  Game+CoreDataProperties.swift
//  BallScores
//
//  Created by Tan Yee Gene on 01/02/2020.
//  Copyright © 2020 Tan Yee Gene. All rights reserved.
//
//

import Foundation
import CoreData


extension Game {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Game> {
        return NSFetchRequest<Game>(entityName: "Game")
    }

    @NSManaged public var homeTeamScore: Int32
    @NSManaged public var id: Int32
    @NSManaged public var season: Int32
    @NSManaged public var status: String?
    @NSManaged public var visitorTeamScore: Int32
    @NSManaged public var gameTime: String?
    @NSManaged public var homeTeam: HomeTeam?
    @NSManaged public var visitorTeam: VisitorTeam?
    

}
