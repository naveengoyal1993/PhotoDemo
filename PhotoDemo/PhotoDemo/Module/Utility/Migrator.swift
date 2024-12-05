//
//  Untitled.swift
//  SimplePhoto
//
//  Created by Naveen Goyal on 05/12/24.
//


import Foundation
import RealmSwift

class Migrator {
    
    init() {
        updateSchema()
    }
    
    func updateSchema() {
        
        let config = Realm.Configuration(schemaVersion: 1) { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                // add new fields
                migration.enumerateObjects(ofType: ImageEntry.className()) { oldObject, newObject in
//                    newObject!["fileName"] = ""
                }
            }
        }
        
        Realm.Configuration.defaultConfiguration = config
        let _ = try! Realm()
        
    }
    
}
