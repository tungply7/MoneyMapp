//
//  Expense+CoreDataProperties.swift
//  MoneyMapp
//
//  Created by Tung Ly on 6/2/16.
//  Copyright © 2016 Tung Ly. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Expense {

    @NSManaged var amount: NSNumber?
    @NSManaged var date: NSDate?
    @NSManaged var dateString: String?
    @NSManaged var isExpense: NSNumber?
    @NSManaged var monthOfTheYear: NSNumber?
    @NSManaged var name: String?
    @NSManaged var weekOfTheYear: NSNumber?
    @NSManaged var year: NSNumber?

}
