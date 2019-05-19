//
//  AddingNewProductViewController.swift
//  EcwidTestTask
//
//  Created by Тимофей Забалуев on 16/05/2019.
//  Copyright © 2019 Тимофей Забалуев. All rights reserved.
//

import UIKit
import Photos

protocol AddAndRemoveElementDelegate: class {
    func addElement(_ element: Product)
    func deleteElenent(_ element: Product)
}

class AddingNewProductViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var selectedImageButton: UIButton!
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var smallImage: UIImageView!
    weak var delegate: AddAndRemoveElementDelegate?
    var oldProduct: Product?
    var isEditingProduct = false
    
    func unwrapImageView() {
        DispatchQueue.main.async {
            self.selectedImageButton.titleLabel?.text = "Выбрать другое изображение"
        }
        guard let constraintHeight = smallImage.constraints.first(where: {$0.firstAttribute == .height}) else { return }
        let newConstraintHeight = smallImage.heightAnchor.constraint(equalToConstant: 200)
    
        //Заменяем constraint для отображения изображения
        NSLayoutConstraint.deactivate([constraintHeight])
        NSLayoutConstraint.activate([newConstraintHeight])
    
    }
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            smallImage.image = image
            unwrapImageView()
        }
        else {
            throwAlert("Ошибка загрузки фотографии")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageTapped(_ sender: UIButton) {
        PHPhotoLibrary.requestAuthorization({
            (newStatus) in
            if newStatus ==  PHAuthorizationStatus.authorized {
                let image = UIImagePickerController()
                image.delegate = self
                image.sourceType = UIImagePickerController.SourceType.photoLibrary
                image.allowsEditing = false
                DispatchQueue.main.sync(execute: {
                    self.present(image, animated: true, completion: nil)
                })
            }
        })
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        guard !productNameTextField.text!.isEmpty else {
            throwAlert("Заполните название продукта.")
            return
        }
        guard !quantityTextField.text!.isEmpty else {
            throwAlert("Заполните количество продукта.")
            return
        }
        guard let productQuantity = UInt(quantityTextField.text!) else {
            throwAlert("Количество должно быть положительным числом.")
            return
        }
        guard !priceTextField.text!.isEmpty else {
            throwAlert("Заполните цену продукта.")
            return
        }
        guard let productPrice = Double(priceTextField.text!), productPrice > 0  else {
            throwAlert("Цена должна быть натуральным числом(больше нуля).")
            return
        }

        let newProduct = Product(name: productNameTextField.text!,
                                 quantity: productQuantity,
                                 price: productPrice,
                                 image: smallImage?.image)
        
        // Как должно проще быть...
        let workItem = DispatchWorkItem {
            if self.isEditingProduct {
                self.delegate?.deleteElenent(self.oldProduct!)
            }
        }
        
        DispatchQueue.global(qos: .default).async(execute: workItem)

        workItem.notify(queue: .main, execute: {
            self.delegate?.addElement(newProduct)
        })
        navigationController?.popViewController(animated: true)
    }
    
    func throwAlert(_ message: String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productNameTextField.text = oldProduct?.name
        quantityTextField.text = String(oldProduct?.quantity ?? 0)
        priceTextField.text = String(oldProduct?.price ?? 0)
        smallImage.image = oldProduct?.image
        
        if let _ = smallImage.image {
            unwrapImageView()
        }
    }
}
