//
//  RegisteredStorable.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 12.05.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit
import CoreData


/// The protocol requires to register some initial values for the provided entity.
/// It's supposed to always return an item because it's either registered or saved.
protocol RegisteredStorable {
    associatedtype StorableItemType
    
    func registerInitial()
    func save(_ item: StorableItemType)
    
    var item: StorableItemType { get }
}
