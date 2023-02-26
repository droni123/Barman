//
//  BDBebidas+CoreDataProperties.swift
//  Barman
//
//  Created by De la Cruz Hernandez on 25/02/23.
//
//

import Foundation
import CoreData


extension BDBebidas {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BDBebidas> {
        return NSFetchRequest<BDBebidas>(entityName: "BDBebidas")
    }

    @NSManaged public var directions: String?
    @NSManaged public var img: String?
    @NSManaged public var ingredients: String?
    @NSManaged public var name: String?
    @NSManaged public var isremoto: Bool

}

extension BDBebidas : Identifiable {

}
