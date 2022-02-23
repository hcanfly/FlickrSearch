//
//  SearchCoordinator.swift
//  FlickrSearch
//
//  Created by Gary Hanson on 2/29/20.
//  Copyright © 2020 Gary Hanson. All rights reserved.
//

import UIKit


final class SearchCoordinator: Coordinator {
    var navigationController: UINavigationController

    
    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController

        let viewController = SearchViewController.instantiate()
        viewController.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "Search"), tag: 0)
        viewController.coordinator = self

        navigationController.viewControllers = [viewController]
    }

    func photoSelected(photo: FlickrPhoto) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: PhotoViewController.self)) as! PhotoViewController
        
        vc.photo = photo
        navigationController.pushViewController(vc, animated: false)
    }
}
