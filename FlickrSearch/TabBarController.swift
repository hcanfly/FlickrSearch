//
//  TabBarViewController.swift
//  FlickrSearch
//
//  Created by Gary Hanson on 2/2/22.
//

import UIKit


final class TabBarController: UITabBarController {
    private let searchCoordinator = SearchCoordinator()
    private let recentsCoordinator = RecentsCoordinator()

    
    override func viewDidLoad() {

        viewControllers = [searchCoordinator.navigationController, recentsCoordinator.navigationController]
    }

    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
        
    }
}
