//
//  VrstaProizvoda+CoreDataProperties.swift
//  Magacinsko_poslovanje
//
//  Created by Grupa 1 on 18.11.22..
//
//

import Foundation
import CoreData


extension VrstaProizvoda {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VrstaProizvoda> {
        return NSFetchRequest<VrstaProizvoda>(entityName: "VrstaProizvoda")
    }

    @NSManaged public var brojFakture: String?
    @NSManaged public var cena: Int64
    @NSManaged public var datumFakture: Date?
    @NSManaged public var kolkicinaUneto: Int64
    @NSManaged public var proizvod: Proizvod?

}

extension VrstaProizvoda : Identifiable {

}
