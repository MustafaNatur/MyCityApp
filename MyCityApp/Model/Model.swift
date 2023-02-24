//
//  Model.swift
//  MyCityApp
//
//  Created by Мустафа Натур on 23.02.2023.
//

import Foundation
import RealmSwift



class Place: Object {
    @objc dynamic var name:String = ""
    @objc dynamic var location:String?
    @objc dynamic var type:String?
    @objc dynamic var imageData: Data?
    @objc dynamic var date = Date()
    @objc dynamic var rating:Double = 0.0
}
