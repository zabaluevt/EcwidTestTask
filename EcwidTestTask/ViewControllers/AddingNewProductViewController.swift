//
//  AddingNewProductViewController.swift
//  EcwidTestTask
//
//  Created by Тимофей Забалуев on 16/05/2019.
//  Copyright © 2019 Тимофей Забалуев. All rights reserved.
//

import UIKit
import Photos

protocol AddAndEditElementDelegate: class {
    func addElement(_ element: Product) throws
    func editElement(oldElement: Product, newElement: Product) throws
}

class AddingNewProductViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var selectedImageButton: UIButton!
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var smallImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var delegate: AddAndEditElementDelegate?
    var oldProduct: Product?
    var isEditingProduct = false
    
    //При появлении изображения задаем высоту изображения для этого используем constraints
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
    
    //Выгружаем изображение из галереи
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
    
    //Открываем галерию
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
        guard let productQuantity = Int(quantityTextField.text!) else {
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

        let newProduct = Product()
        newProduct.name = productNameTextField.text!
        newProduct.quantity = productQuantity
        newProduct.price = productPrice
        newProduct.imageData = smallImage.image?.jpegData(compressionQuality: 0.5)

        
        if self.isEditingProduct {
            try? self.delegate?.editElement(oldElement: self.oldProduct!, newElement: newProduct)
        }
        else{
            try? self.delegate?.addElement(newProduct)
        }
        
        self.closeDetailVC()
        
        navigationController?.popViewController(animated: true)
    }
    
    //Вызывем Alert для показа сообщения пользователю
    func throwAlert(_ message: String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Закрытие клавиатуры срабатывает при нажатии в области не относящиеся к заполнению
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //Добавляем события при открытие и закрытие клавиатуры
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        productNameTextField.text = oldProduct?.name
        quantityTextField.text = String(oldProduct?.quantity ?? 0)
        priceTextField.text = String(oldProduct?.price ?? 0)
        
        if let img = oldProduct?.imageData{
             smallImage.image = UIImage(data: img)!
        }
        
        if let _ = smallImage.image {
            unwrapImageView()
        }
    }
    
//    Данная ф-я не вызывается при нажатии  return
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
    
    //Заканчиваем ввод с клавиатуры
    @objc func dismissKeyboard(touch: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            //Двигаем frame на высоту клавиатуры
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
                
                //Находим верхний constrain и восполяем движение frame
                guard let constraint = scrollView.constraints.first(where: {$0.firstAttribute == .top}) else { return }
                NSLayoutConstraint.deactivate([constraint])
                constraint.constant = keyboardSize.height
                NSLayoutConstraint.activate([constraint])
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        //Возвращаем все на место
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0

            guard let constraint = scrollView.constraints.first(where: {$0.firstAttribute == .top}) else { return }

            NSLayoutConstraint.deactivate([constraint])
            constraint.constant = 0
            NSLayoutConstraint.activate([constraint])
            self.view.layoutIfNeeded()
        }
    }
}

extension AddingNewProductViewController {
    //Удаляем контроллер, нужно для SplitView ограничить ввод пользователю
    func closeDetailVC() {
        splitViewController?.showDetailViewController(UIViewController(), sender: nil)
    }
}
