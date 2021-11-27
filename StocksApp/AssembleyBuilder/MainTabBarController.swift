//
//  MainTabBarController.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 23.08.2021.
//

import UIKit

final class MainTabBarController : UITabBarController {
    
    private var builder : Builder!
    
    init(builder : Builder) {
        self.builder = builder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainVC = builder.createMainViewModule()
        let navMainVC = UINavigationController(rootViewController: mainVC)
        navMainVC.navigationBar.topItem?.title = "Main"
        navMainVC.tabBarItem.image = UIImage(named: "Icon_home")
        navMainVC.tabBarItem.title = "Home"
        
        let searchVC = builder.createSearchViewModule()
        let navSearchVC = UINavigationController(rootViewController: searchVC)
        navSearchVC.navigationBar.topItem?.title = "Search"
        navSearchVC.tabBarItem.image = UIImage(named: "Icon_search")
        navSearchVC.tabBarItem.title = "Search"
        
        let favVC = builder.createFavoritesViewModule()
        let navfavVC = UINavigationController(rootViewController: favVC)
        navfavVC.navigationBar.topItem?.title = "Favorites"
        navfavVC.tabBarItem.image = UIImage(named: "icon_Heart")
        navfavVC.tabBarItem.title = "Favorites"
        
        
        let newsVC = builder.createNewsViewModule()
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
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor(hexString: "#4158B7")
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 17)!]
            appearance.shadowImage = UIImage()
            i.navigationBar.standardAppearance = appearance
        }
        
        viewControllers = arrayOfNVC
        
        if #available(iOS 15, *) {
            let tabBarAppearance = UITabBarAppearance()
            let tabBarItemAppearance = UITabBarItemAppearance()
            tabBarItemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 12)!]
            tabBarItemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 12)!, .foregroundColor: UIColor.white]
            tabBarAppearance.backgroundColor = UIColor(red: 0.058, green: 0.109, blue: 0.329, alpha: 1)
            tabBarItemAppearance.normal.iconColor = .white
            tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
            tabBar.standardAppearance = tabBarAppearance
            tabBar.scrollEdgeAppearance = tabBarAppearance
        } else {
            tabBar.isTranslucent = false
            tabBar.tintColor = UIColor(red: 0.467, green: 0.557, blue: 0.95, alpha: 1)
            tabBar.unselectedItemTintColor = .white
            tabBar.barTintColor = UIColor(red: 0.058, green: 0.109, blue: 0.329, alpha: 1)
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 12)!], for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 12)!], for: .selected)
        }
    }
}
