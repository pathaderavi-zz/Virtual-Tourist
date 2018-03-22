//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Ravikiran Pathade on 3/20/18.
//  Copyright © 2018 Ravikiran Pathade. All rights reserved.
//

import Foundation
import CoreData

class DataController{
    let persistentContainer: NSPersistentContainer
    
    var viewContext:NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    init(modelName:String){
        persistentContainer = NSPersistentContainer(name:modelName)
    }
    
    func load(completion:(()-> Void)? = nil){
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
