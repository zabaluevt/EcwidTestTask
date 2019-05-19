//
//  Product.swift
//  EcwidTestTask
//
//  Created by Тимофей Забалуев on 16/05/2019.
//  Copyright © 2019 Тимофей Забалуев. All rights reserved.
//

import UIKit
import RealmSwift


struct Product: Equatable {
    @objc dynamic var name: String
    @objc dynamic var quantity: UInt
    @objc dynamic var price: Double
    @objc dynamic var image: UIImage?
}
