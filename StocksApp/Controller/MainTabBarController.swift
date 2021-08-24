//
//  MainTabBarController.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 23.08.2021.
//

import UIKit

class MainTabBarController : UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainVC = MainViewController()
        let navMainVC = UINavigationController(rootViewController: mainVC)
        navMainVC.navigationBar.topItem?.title = "Main Page"
//        navMainVC.tabBarItem.image = UIImage(systemName: "house")
        navMainVC.tabBarItem.image = UIImage(named: "Icon_home")
        navMainVC.tabBarItem.title = "Home"
        
        let searchVC = SearchViewController()
        let navSearchVC = UINavigationController(rootViewController: searchVC)
        navSearchVC.navigationBar.topItem?.title = "Search"
        navSearchVC.tabBarItem.image = UIImage(named: "Icon_search")
        navSearchVC.tabBarItem.title = "Search"
        
        let favVC = FavoritesViewController()
        let navfavVC = UINavigationController(rootViewController: favVC)
        navfavVC.navigationBar.topItem?.title = "Favorites"
        navfavVC.tabBarItem.image = UIImage(named: "icon_Heart")
        navfavVC.tabBarItem.title = "Favorites"
        
        
        let newsVC = NewsViewController()
        let navNewsVC = UINavigationController(rootViewController: newsVC)
        navNewsVC.navigationBar.topItem?.title = "News"
        navNewsVC.tabBarItem.image = UIImage(named: "Icon_news")
        navNewsVC.tabBarItem.title = "News"
        
        
        let arrayOfNVC = [
            navMainVC,
            navSearchVC,
            navfavVC,
            navNewsVC
        ]
        for i in arrayOfNVC {
            i.navigationBar.barTintColor = UIColor(hexString: "#202F72")
            i.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        }
        viewControllers = arrayOfNVC
        
        tabBar.barTintColor = UIColor(hexString: "#202F72")
        tabBar.tintColor = UIColor(red: 0.467, green: 0.557, blue: 0.95, alpha: 1)
        tabBar.unselectedItemTintColor = .white
      
    }
}
