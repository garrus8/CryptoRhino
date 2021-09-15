//
//  FavoritesViewPresenter.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 15.09.2021.
//

import Foundation

protocol FavoritesViewPresenterProtocol : AnyObject {
    var filteredResults: GeckoList {get}
    var filteredResultsOfFavorites: [Crypto] {get}
    var isFavoritesEmpty : Bool {get}
    func returnNumberOfItems() -> Int
    func getResultForFilteredAndEmpty(indexPath : IndexPath) -> GeckoListElement
    func getResultForFilteredAndFilled(indexPath : IndexPath) -> Crypto
    func getResultForNotFiltered (indexPath : IndexPath) -> Crypto
    func showChartView (indexPath : IndexPath)
    func filter(searchText : String)
    
}
    
class FavoritesViewPresenter : FavoritesViewPresenterProtocol {
    let view : FavoritesViewControllerProtocol
    var filteredResults = GeckoList()
    var filteredResultsOfFavorites = [Crypto]()
    var isFavoritesEmpty : Bool {
        NetworkManager.shared.resultsF.isEmpty
    }
    var builder : Builder
    init(view: FavoritesViewControllerProtocol, builder : Builder) {
        self.view = view
        self.builder = builder
    }
    
    func returnNumberOfItems() -> Int {
        if view.isFiltering && NetworkManager.shared.resultsF.isEmpty {
            return filteredResults.count
        } else if view.isFiltering && !NetworkManager.shared.resultsF.isEmpty {
            return filteredResultsOfFavorites.count
        }
        return NetworkManager.shared.resultsF.count
    }
    
    func getResultForFilteredAndEmpty (indexPath : IndexPath) -> GeckoListElement {
        filteredResults[indexPath.row]
    }
    func getResultForFilteredAndFilled (indexPath : IndexPath) -> Crypto {
        filteredResultsOfFavorites[indexPath.row]
    }
    func getResultForNotFiltered (indexPath : IndexPath) -> Crypto {
        NetworkManager.shared.resultsF[indexPath.row]
    }
    func showChartView (indexPath : IndexPath) {
        let result: Crypto
        if view.isFiltering && isFavoritesEmpty {
            let elem = filteredResults[indexPath.row]
            result = Crypto(symbolOfCrypto: elem.symbol!, nameOfCrypto: elem.name, id: elem.id)
        } else if view.isFiltering && !isFavoritesEmpty {
            result = filteredResultsOfFavorites[indexPath.row]
        } else {
            result = NetworkManager.shared.resultsF[indexPath.row]
        }
        let chartVC = builder.createChartViewModule(crypto: result)
        view.navigationController?.pushViewController(chartVC, animated: true)
    }
    func filter(searchText : String) {
        if isFavoritesEmpty {
            filteredResults = NetworkManager.shared.fullBinanceList.filter({ (searchElem : GeckoListElement) -> Bool in
                
                return searchElem.symbol!.lowercased().hasPrefix(searchText.lowercased()) ||
                    searchElem.name!.split(separator: "/").first!.lowercased().hasPrefix(searchText.lowercased())
            })
        } else {
            filteredResultsOfFavorites = NetworkManager.shared.resultsF.filter({ (searchElem : Crypto) -> Bool in
                
                return searchElem.nameOfCrypto!.lowercased().hasPrefix(searchText.lowercased()) ||
                    searchElem.symbolOfCrypto.split(separator: "/").first!.lowercased().hasPrefix(searchText.lowercased())
            })
        }
    }
}
