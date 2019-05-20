//
//  TableViewController.swift
//  EcwidTestTask
//
//  Created by Тимофей Забалуев on 14/05/2019.
//  Copyright © 2019 Тимофей Забалуев. All rights reserved.
//

import UIKit
import RealmSwift

class TableViewController: UITableViewController, UISearchBarDelegate  {
    var products: Results<Product>? = nil
    var searchedProducts: [Product] = []
    var editingCellIndex: Int?

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mainTableView: UITableView!
    
    @IBAction func addNewProductTapped(_ sender: UIBarButtonItem) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddingNewProductViewControllerID") as! AddingNewProductViewController
        vc.delegate = self
        splitViewController?.showDetailViewController(vc, sender: nil)
    }
    
    //Скрываем второстепенный контроллер
    func hideDetailVC(){
        self.showDetailViewController(UIViewController(), sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        hideDetailVC()
        
        // Регистрируем ячейку чтобы к ней можно было обращаться
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        self.mainTableView.register(nib, forCellReuseIdentifier: "CustomTableViewCellID")
    
        updateDatabase()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: продумать как вынести в переменную
        if searchBar.text == "" {
            return products?.count ?? 0
        }
        return searchedProducts.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProductDescriptionViewControllerID") as! ProductDescriptionViewController
        if searchBar.text == "" {
            vc.name = products![indexPath.row].name
            vc.quantity = products![indexPath.row].quantity
            vc.price = products![indexPath.row].price
            vc.imageData = products![indexPath.row].imageData
        }
        else{
            vc.name = searchedProducts[indexPath.row].name
            vc.quantity = searchedProducts[indexPath.row].quantity
            vc.price = searchedProducts[indexPath.row].price
            vc.imageData = searchedProducts[indexPath.row].imageData
        }
       
        splitViewController?.showDetailViewController(vc, sender: nil)
        
        //Убираем выделение с ячейки
        self.mainTableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
  
    
    //Меняем стандартыне всплывающие кнопки
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        editingCellIndex = indexPath.row
        
        let rowActionDelete = UITableViewRowAction(style: .default, title: "Удалить", handler: { (action, indexpath) in
            
            self.searchBar.text == "" ? try? self.deleteElement(self.products![indexPath.row]) : try? self.deleteElement(self.searchedProducts[indexPath.row])
            
        })
        let rowActionEdit = UITableViewRowAction(style: .normal, title: "Править", handler: { (action, indexpath) in
            let element = (self.searchBar.text == "") ?
                DataBase.shared.realm.objects(Product.self).first(where: {$0 == self.products![indexPath.row]}) :
                DataBase.shared.realm.objects(Product.self).first(where: {$0 == self.searchedProducts[indexPath.row]})
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddingNewProductViewControllerID") as! AddingNewProductViewController
            vc.oldProduct = element
            vc.delegate = self
            vc.isEditingProduct = true
            
            self.splitViewController?.showDetailViewController(vc, sender: nil)
        })
        return [rowActionDelete, rowActionEdit]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCellID", for: indexPath) as! CustomTableViewCell
        let product = searchBar.text == "" ? products![indexPath.row] : searchedProducts[indexPath.row]
        cell.commonInit(name: product.name,
                        quantity: product.quantity,
                        price: product.price,
                        imageData: product.imageData)
        return cell
    }
    
    //Фильтр по названию товара
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedProducts = products!.filter({ product in
            guard let text = searchBar.text else { return false }
            return product.name.contains(text)
        })
        self.mainTableView.reloadSections([0], with: .fade)
    }
    
    //Выгружаем из бд все товоры
    func updateDatabase() {
        products = DataBase.shared.realm.objects(Product.self).sorted(byKeyPath: "name", ascending: true)
    }
    
    func deleteElement(_ element: Product) throws {
        let workItem = DispatchWorkItem {
            element.deleteFromDatabase()
        }
        
        DispatchQueue.global(qos: .userInitiated).sync(execute: workItem)
        
        workItem.notify(queue: .main, execute: {
            if self.searchBar.text != "" {
                self.searchBar.text = ""
                self.mainTableView.reloadData()
            }
            else {
                self.mainTableView.beginUpdates()
                self.mainTableView.deleteRows(at: [IndexPath(row: self.editingCellIndex!, section: 0)], with: .fade)
                self.mainTableView.endUpdates()
            }
        })
    }
}

extension TableViewController: AddAndEditElementDelegate{
    func addElement(_ element: Product) throws {
        let workItem = DispatchWorkItem {
            element.addToDatabase()
        }

        DispatchQueue.global(qos: .userInitiated).sync(execute: workItem)
        
        workItem.notify(queue: .main, execute: {
            let insertingIndex = self.products!.index(of: element)
            self.mainTableView.beginUpdates()
            self.mainTableView.insertRows(at: [IndexPath(row: insertingIndex!, section: 0)], with: .bottom)
            self.mainTableView.endUpdates()
        })
    }
    
    func editElement(oldElement: Product, newElement: Product) throws {
        let workItem = DispatchWorkItem {
            oldElement.deleteFromDatabase()
            newElement.addToDatabase()
        }
        
        DispatchQueue.global(qos: .userInitiated).sync(execute: workItem)
        
        workItem.notify(queue: .main, execute: {
            //Можно как то лучше написть
            if self.searchBar.text != "" {
                self.searchBar.text = ""
                self.mainTableView.reloadData()
            }
            else{
                let insertingIndex = self.products!.index(of: newElement)
                self.mainTableView.beginUpdates()
                self.mainTableView.deleteRows(at: [IndexPath(row: self.editingCellIndex!, section: 0)], with: .fade)
                self.mainTableView.insertRows(at: [IndexPath(row: insertingIndex!, section: 0)], with: .bottom)
                self.mainTableView.endUpdates()
            }
        })
    }
}

