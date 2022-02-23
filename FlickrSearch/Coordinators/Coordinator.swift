//
//  Coordinator.swift
//  TabBarApp
//
//  Created by Gary Hanson on 2/29/20.
//  Copyright © 2020 Gary Hanson. All rights reserved.
//

import UIKit


protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
}




protocol Storyboarded { }

extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        let storyboardIdentifier = String(describing: self)
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
    }
}
