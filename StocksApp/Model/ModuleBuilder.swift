//
//  ModuleBuilder.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 14.09.2021.
//

import UIKit

protocol Builder {
    func createMainViewModule() -> UIViewController
    func createSearchViewModule() -> UIViewController
    func createFavoritesViewModule() -> UIViewController
    func createNewsViewModule() -> UIViewController
    func createChartViewModule(crypto: Crypto) -> UIViewController
}

class ModuleBuilder : Builder {
    //MARK: - УБРАТЬ STATIC
    
    func createMainViewModule() -> UIViewController {
        let view = MainViewController()
        let networkManager = NetworkManager()
        let webSocketManager = WebSocketManager()
        let coreDataManager = CoreDataManager(networkManager: networkManager)
        let presenter = MainViewPresenter(view: view, builder: self, networkManager: networkManager,webSocketManager: webSocketManager, coreDataManager: coreDataManager)
        view.presenter = presenter
        return view
    }
    
    func createSearchViewModule() -> UIViewController {
        let view = SearchViewController()
        let presenter = SearchViewPresenter(view: view, builder: self)
        view.presenter = presenter
        return view
    }
    func createFavoritesViewModule() -> UIViewController {
        let view = FavoritesViewController()
        let presenter = FavoritesViewPresenter(view: view, builder: self)
        view.presenter = presenter
        return view
    }
    func createNewsViewModule() -> UIViewController {
        let view = NewsViewController()
        let networkManager = NetworkManager()
        let presenter = NewsViewPresenter(view: view, networkManager : networkManager)
        view.presenter = presenter
        return view
    }
    
    func createChartViewModule(crypto: Crypto) -> UIViewController {
        let view = ChartViewController()
        let networkManager = NetworkManager()
        let webSocketManager = WebSocketManager()
        let coreDataManager = CoreDataManager(networkManager: networkManager)
        let presenter = ChartViewPresenter(crypto : crypto, view: view, networkManager: networkManager, coreDataManager: coreDataManager, websocketManager: webSocketManager)
//        view.crypto = crypto
        view.presenter = presenter
        return view
    }
}
