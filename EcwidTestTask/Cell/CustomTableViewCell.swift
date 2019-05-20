//
//  CustomTableViewCell.swift
//  EcwidTestTask
//
//  Created by Тимофей Забалуев on 14/05/2019.
//  Copyright © 2019 Тимофей Забалуев. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productQuantity: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    
    func commonInit(name: String, quantity: Int, price: Double, imageData: Data?) {
        productName.text = name
        productQuantity.text = "Количество: " + String(quantity)
        productPrice.text = String(price) + " ₽"
        productImage.image = imageData != nil ? UIImage(data: imageData!) : UIImage(named: "NoImage.png")
    }
}
