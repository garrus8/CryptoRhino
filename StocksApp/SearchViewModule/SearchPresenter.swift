//
//  SearchViewPresenter.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 15.09.2021.
//

import Foundation


protocol SearchViewPresenterProtocol : AnyObject {
    var filteredResults : GeckoList {get}
//    var isFiltering : Bool {get}
    func returNnumberOfItems() -> Int
    func showChartView(indexPath : IndexPath)
    func filter(searchText : String)
    func getFilteredResult(indexPath : IndexPath) -> GeckoListElement
    func getTopListElem(indexPath : IndexPath) -> TopSearchItem
}


class SearchViewPresenter : SearchViewPresenterProtocol {
    let view : SearchViewControllerProtocol!
    var filteredResults = GeckoList()
    var builder : Builder

    
    init(view : SearchViewControllerProtocol, builder: Builder) {
        self.view = view
        self.builder = builder
    }
    
    func returNnumberOfItems() -> Int {
        if view.isFiltering {
            return filteredResults.count
        } else {
            return NetworkManager.shared.topList.count
        }
    }
    
    func showChartView(indexPath : IndexPath) {
        let crypto : Crypto
        if view.isFiltering {
            let result = filteredResults[indexPath.row]
            crypto = Crypto(symbolOfCrypto: result.symbol!, nameOfCrypto: result.name, id: result.id)
        } else {
            let result = NetworkManager.shared.topList[indexPath.row]
            crypto = Crypto(symbolOfCrypto: result.symbol, nameOfCrypto: result.name, id: result.id)
        }
        let chartVC = builder.createChartViewModule(crypto: crypto)
        view.navigationController?.pushViewController(chartVC, animated: true)
    }
    
    func filter(searchText : String) {
        filteredResults = NetworkManager.shared.fullBinanceList.filter({ (searchElem : GeckoListElement) -> Bool in

            return searchElem.symbol!.lowercased().hasPrefix(searchText.lowercased()) ||
                searchElem.name!.split(separator: "/").first!.lowercased().hasPrefix(searchText.lowercased())

        })
    }
    func getFilteredResult(indexPath : IndexPath) -> GeckoListElement {
            let result = filteredResults[indexPath.row]
            return result
    }
    func getTopListElem(indexPath : IndexPath) -> TopSearchItem {
            let result = NetworkManager.shared.topList[indexPath.row]
            return result
    }
  
}



    

