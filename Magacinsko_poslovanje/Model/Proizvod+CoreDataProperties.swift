//
//  Proizvod+CoreDataProperties.swift
//  Magacinsko_poslovanje
//
//  Created by Grupa 1 on 18.11.22..
//
//

import Foundation
import CoreData


extension Proizvod {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Proizvod> {
        return NSFetchRequest<Proizvod>(entityName: "Proizvod")
    }

    @NSManaged public var nazivProizvoda: String?
    @NSManaged public var sifraProizvoda: String?
    @NSManaged public var ukupnoProizvoda: Int64
    @NSManaged public var vrstaProizvoda: NSSet?

}

// MARK: Generated accessors for vrstaProizvoda
extension Proizvod {

    @objc(addVrstaProizvodaObject:)
    @NSManaged public func addToVrstaProizvoda(_ value: VrstaProizvoda)

    @objc(removeVrstaProizvodaObject:)
    @NSManaged public func removeFromVrstaProizvoda(_ value: VrstaProizvoda)

    @objc(addVrstaProizvoda:)
    @NSManaged public func addToVrstaProizvoda(_ values: NSSet)

    @objc(removeVrstaProizvoda:)
    @NSManaged public func removeFromVrstaProizvoda(_ values: NSSet)

}

extension Proizvod : Identifiable {

}
