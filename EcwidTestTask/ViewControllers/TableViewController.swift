//
//  TableViewController.swift
//  EcwidTestTask
//
//  Created by Тимофей Забалуев on 14/05/2019.
//  Copyright © 2019 Тимофей Забалуев. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UISearchBarDelegate  {
  
    private var commonProductArray: [Product] = []
    private var searchedProductArray: [Product] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mainTableView: UITableView!
    
    @IBAction func addNewProductTapped(_ sender: UIBarButtonItem) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddingNewProductViewControllerID") as! AddingNewProductViewController
        vc.delegate = self
        splitViewController?.showDetailViewController(vc, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        self.mainTableView.register(nib, forCellReuseIdentifier: "CustomTableViewCellID")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: продумать как вынести в переменную
        if searchBar.text == "" {
            return commonProductArray.count
        }
        return searchedProductArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProductDescriptionViewControllerID") as! ProductDescriptionViewController
        vc.name = commonProductArray[indexPath.row].name
        vc.quantity = commonProductArray[indexPath.row].quantity
        vc.price = commonProductArray[indexPath.row].price
        vc.image = commonProductArray[indexPath.row].image
        splitViewController?.showDetailViewController(vc, sender: nil)
        self.mainTableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
  
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let rowActionDelete = UITableViewRowAction(style: .default, title: "Удалить", handler: { (action, indexpath) in
            self.commonProductArray.remove(at: indexPath.row)
            self.mainTableView.deleteRows(at: [indexPath], with: .automatic)
        })
        let rowActionEdit = UITableViewRowAction(style: .normal, title: "Править", handler: { (action, indexpath) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddingNewProductViewControllerID") as! AddingNewProductViewController
            vc.delegate = self
            vc.oldProduct = Product(name: self.commonProductArray[indexPath.row].name,
                                    quantity: self.commonProductArray[indexPath.row].quantity,
                                    price: self.commonProductArray[indexPath.row].price,
                                    image: self.commonProductArray[indexPath.row].image)
            vc.isEditingProduct = true
            self.splitViewController?.showDetailViewController(vc, sender: nil)
        })
        return [rowActionDelete, rowActionEdit]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCellID", for: indexPath) as! CustomTableViewCell
        let product = searchBar.text == "" ? commonProductArray[indexPath.row]: searchedProductArray[indexPath.row]
        cell.commonInit(name: product.name,
                        quantity: product.quantity,
                        price: product.price,
                        image: product.image)
        
        if product.quantity == 0 {
            // Здесь можно добавить изменить отображение ячейки когда количество равно нулю
        }
        
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedProductArray = commonProductArray.filter({ product in
            guard let text = searchBar.text else { return false }
            return product.name.contains(text)
        })
        self.mainTableView.reloadSections([0], with: .fade)
    }
}

extension TableViewController: AddAndRemoveElementDelegate{
    func addElement(_ element: Product) {
        let workItem = DispatchWorkItem {
            self.commonProductArray.append(element)
            self.commonProductArray.sort(by: {$0.name < $1.name})
        }
        
        DispatchQueue.global(qos: .userInitiated).sync(execute: workItem)
        
        workItem.notify(queue: .main, execute: {
            let insertingIndex = self.commonProductArray.firstIndex{$0.name == element.name}
            self.mainTableView.beginUpdates()
            self.mainTableView.insertRows(at: [IndexPath(row: insertingIndex!, section: 0)], with: .bottom)
            self.mainTableView.endUpdates()
        })
    }
    
    func deleteElenent(_ element: Product) {
        let index = self.commonProductArray.firstIndex(of: element)!
        let workItem = DispatchWorkItem{
            self.commonProductArray.remove(at: index)
        }
        
        DispatchQueue.global(qos: .userInitiated).sync(execute: workItem)
        
        workItem.notify(queue: .main, execute: {
            self.mainTableView.beginUpdates()
            self.mainTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.mainTableView.endUpdates()
        })
    }
}

