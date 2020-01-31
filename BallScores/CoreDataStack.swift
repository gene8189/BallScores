//
//  CoreDataStack.swift
//  BallScores
//
//  Created by Tan Yee Gene on 31/01/2020.
//  Copyright © 2020 Tan Yee Gene. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    private let modelName:String
    init(modelName:String) {
        self.modelName = modelName
    }
    
    //managedContext
    lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    // container
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
            print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    //saveContext
    func saveContext() {
        guard managedContext.hasChanges else {
            return
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
}
