//
//  NSManagedObject+Extensions.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 05.09.17.
//  Copyright © 2017 MB. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    static var entityName: String {
        return self.entity().name ?? String(describing: self)
    }
    
    static func all<T: NSFetchRequestResult>(in context: NSManagedObjectContext, matching predicate: NSPredicate? = nil) -> [T] {
        var result = [T]()
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = predicate
        
        context.performAndWait {
            let objects = try? context.fetch(request)
            result = objects ?? []
        }
        return result
    }
    
    static func first<T: NSManagedObject>(in context: NSManagedObjectContext, matching predicate: NSPredicate? = nil) -> T? {
        let objects: [T] = all(in: context, matching: predicate)
        return objects.first
    }
}
