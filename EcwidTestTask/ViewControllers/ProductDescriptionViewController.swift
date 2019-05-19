//
//  ViewController.swift
//  EcwidTestTask
//
//  Created by Тимофей Забалуев on 14/05/2019.
//  Copyright © 2019 Тимофей Забалуев. All rights reserved.
//

import UIKit

class ProductDescriptionViewController: UIViewController {

    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productQuantity: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    
    var name = ""
    var quantity: UInt = 0
    var price: Double = 0.0
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productName?.text =  name
        productQuantity?.text = "Количество: " + String(quantity)
        productPrice?.text = "Цена: " + String(price)
        productImage?.image = image
    }
}

