//
//  RecentCoordinator.swift
//  FlickrSearch
//
//  Created by Gary Hanson on 2/2/22.
//

import UIKit


final class RecentsCoordinator: Coordinator {
    var navigationController: UINavigationController

    
    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController

        let viewController = RecentsViewController.instantiate()
        viewController.tabBarItem = UITabBarItem(title: "Recents", image: UIImage(named: "first"), tag: 0)
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

