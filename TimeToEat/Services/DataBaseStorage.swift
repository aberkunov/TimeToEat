//
//  DataBaseStorage.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 28.05.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit
import CoreData

class DataBaseStorage {
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataBase")
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveViewContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: - Public
    func viewContextItems<T: NSManagedObject>(matching predicate: NSPredicate) -> [T] {
        let results: [T] = T.all(in: persistentContainer.viewContext, matching: predicate)
        return results
    }
    
    func items<T: NSManagedObject>(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> [T] {
        let results: [T] = T.all(in: context, matching: predicate)
        return results
    }
}
