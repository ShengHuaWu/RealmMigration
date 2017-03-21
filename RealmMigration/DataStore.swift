//
//  DataStore.swift
//  RealmMigration
//
//  Created by ShengHua Wu on 20/03/2017.
//  Copyright © 2017 ShengHuaWu. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

// All changes to an object (addition, modification and deletion) must be done within a write transaction.
final class DataStore {
    // MARK: - Properties
    static let currentSchemaVersion: UInt64 = 3
    
    // MARK: - Static Methods
    static func seedPeople() throws {
        let tom = Person()
        tom.firstName = "Tom"
        tom.lastName = "Cruise"
        tom.age = 54
        
        let bruno = Person()
        bruno.firstName = "Bruno"
        bruno.lastName = "Mars"
        bruno.age = 31
        
        let taylor = Person()
        taylor.firstName = "Taylor"
        taylor.lastName = "Swift"
        taylor.age = 27
        
        let realm = try Realm()
        try realm.write {
            realm.add([tom, bruno, taylor])
        }
    }
    
    static func findAll<T: Object>() throws -> Results<T> {
        let realm = try Realm()
        return realm.objects(T.self)
    }
    
    static func configureMigration() {
        let config = Realm.Configuration(schemaVersion: currentSchemaVersion, migrationBlock: { (migration, oldSchemaVersion) in
            if oldSchemaVersion < 1 {
                migrateFrom0To1(with: migration)
            }
            
            if oldSchemaVersion < 2 {
                migrateFrom1To2(with: migration)
            }
            
            if oldSchemaVersion < 3 {
                migrateFrom2To3(with: migration)
            }
        })
        Realm.Configuration.defaultConfiguration = config
    }
    
    // MARK: - Migrations
    static func migrateFrom0To1(with migration: Migration) {
        // Add an email property
        migration.enumerateObjects(ofType: Person.className()) { (_, newPerson) in
            newPerson?["email"] = ""
        }
    }
    
    static func migrateFrom1To2(with migration: Migration) {
        // Rename name to fullname
        migration.renameProperty(onType: Person.className(), from: "name", to: "fullName")
    }
    
    static func migrateFrom2To3(with migration: Migration) {
        // Replace fullname with firstName and lastName
        migration.enumerateObjects(ofType: Person.className()) { (oldPerson, newPerson) in
            guard let fullname = oldPerson?["fullName"] as? String else {
                fatalError("fullName is not a string")
            }
            
            let nameComponents = fullname.components(separatedBy: " ")
            if nameComponents.count == 2 {
                newPerson?["firstName"] = nameComponents.first
                newPerson?["lastName"] = nameComponents.last
            } else {
                newPerson?["firstName"] = fullname
            }
        }
    }
}
