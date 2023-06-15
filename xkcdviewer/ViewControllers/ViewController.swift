//
//  ViewController.swift
//  xkcdviewer
//
//  Created by Dipro on 6/14/23.
//  Copyright © 2023 TheRedSpecial. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarController()
    }
    
    private func setupTabBarController() {
        let tabBarVC = UITabBarController()
        tabBarVC.delegate = self
        
        let comicVC = ComicViewController()
        comicVC.tabBarItem = UITabBarItem(title: "Current", image: UIImage(named: "ComicIcon"), selectedImage: nil)
        
        let searchVC = SearchViewController()
        searchVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "SearchIcon"), selectedImage: nil)
        
        let aboutVC = AboutViewController()
        aboutVC.title = "About"
        aboutVC.tabBarItem = UITabBarItem(title: "About", image: UIImage(named: "AboutIcon"), selectedImage: nil)
        
        tabBarVC.setViewControllers([comicVC, searchVC, aboutVC], animated: false)
        
        addChild(tabBarVC)
        view.addSubview(tabBarVC.view)
        tabBarVC.didMove(toParent: self)
    }
    
    private func createViewController(color: UIColor, title: String) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = color
        viewController.title = title
        viewController.tabBarItem = UITabBarItem(title: title, image: nil, selectedImage: nil)
        return viewController
    }
}
