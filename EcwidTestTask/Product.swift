//
//  Product.swift
//  EcwidTestTask
//
//  Created by Тимофей Забалуев on 16/05/2019.
//  Copyright © 2019 Тимофей Забалуев. All rights reserved.
//

import UIKit
import RealmSwift

class Product: Object {
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.name == rhs.name && lhs.quantity == rhs.quantity && lhs.price == rhs.price && lhs.imageData == rhs.imageData
    }
    
    @objc dynamic var name = ""
    @objc dynamic var quantity: Int = 0
    @objc dynamic var price: Double = 0.0
    @objc dynamic var imageData: Data?
    
    func addToDatabase() {
        DataBase.shared.beginEntityUpdate()
        DataBase.shared.realm.add(self)
        DataBase.shared.commitEntityUpdate()
    }
    
    func deleteFromDatabase() {
        DataBase.shared.beginEntityUpdate()
        DataBase.shared.realm.delete(self)
        DataBase.shared.commitEntityUpdate()
    }
}
