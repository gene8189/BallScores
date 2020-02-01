//
//  HomeTeam+CoreDataProperties.swift
//  BallScores
//
//  Created by Tan Yee Gene on 01/02/2020.
//  Copyright © 2020 Tan Yee Gene. All rights reserved.
//
//

import Foundation
import CoreData


extension HomeTeam {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HomeTeam> {
        return NSFetchRequest<HomeTeam>(entityName: "HomeTeam")
    }

    @NSManaged public var abbreviation: String?
    @NSManaged public var fullName: String?
    @NSManaged public var id: Int32
    @NSManaged public var game: Game?

}
