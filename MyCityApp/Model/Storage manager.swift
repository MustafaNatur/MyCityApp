//
//  Storage manager.swift
//  MyCityApp
//
//  Created by Мустафа Натур on 24.02.2023.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
}
