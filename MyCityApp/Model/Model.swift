//
//  Model.swift
//  MyCityApp
//
//  Created by Мустафа Натур on 23.02.2023.
//

import Foundation

struct Place {
    
    var name:String
    var location:String
    var type:String
    var image: String
    
    
    static let places = [
            "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
            "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
            "Speak Easy", "Morris Pub", "Вкусные истории",
            "Классик", "Love&Life", "Шок", "Бочка"
    ]
    
    static func getPlaces() -> [Place] {
        var arr:[Place] = []
        places.forEach{arr.append(Place(name: $0, location: "None", type: "None", image: $0))}
        return arr
    }
}
