//
//  SplitViewController.swift
//  EcwidTestTask
//
//  Created by Тимофей Забалуев on 16/05/2019.
//  Copyright © 2019 Тимофей Забалуев. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    static let shared = SplitViewController()
    override func viewDidLoad() {
        self.delegate = self
        //Отображаем два контроллера для планшета
        self.preferredDisplayMode = .allVisible
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
