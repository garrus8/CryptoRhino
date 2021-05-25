////
////  FavoritesTableViewController.swift
////  StocksApp
////
////  Created by Григорий Толкачев on 02.03.2021.
////

import UIKit
import CoreData

class FavoritesTableViewController: UITableViewController {
    
    let finHubToken = Constants.finHubToken
//    let networkManager = NetworkManager()
    var favorites = [Favorites]()
    var results = [Crypto]()
    var symbols = [String]()
    var coinGecoList = [GeckoListElement]()
    private var filteredResults = [FullBinanceListElement]()
    let searchController = UISearchController(searchResultsController: nil)
    var searchBarIsEmpty : Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    private var isFiltering : Bool {
        return searchController.isActive && !searchBarIsEmpty
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Name or symbol of cryptocurrency"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        // DELEGATE
//        networkManager.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "WebsocketDataUpdate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
 
    }
    
    @objc func refresh() {
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

   }
    
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredResults.count
        }
        
        return NetworkManager.shared.resultsF.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as? TableViewCell else {return UITableViewCell()}
        
        
        
        if isFiltering {
            let results = filteredResults[indexPath.row]
            cell.symbol.text = results.displaySymbol
            cell.name.text = results.fullBinanceListDescription
            cell.price.text = ""
            cell.change.text = ""
            cell.percent.text = ""
            cell.symbolOfTicker = results.symbol!
            cell.idOfCrypto = results.id!
            cell.textViewTest = ""
            
        } else {
            guard let results = NetworkManager.shared.resultsF[indexPath.row] as Crypto? else {return UITableViewCell()}
            cell.symbol.text = results.symbolOfCrypto
            cell.name.text = results.nameOfCrypto
            cell.price.text = String(results.index)
            cell.change.text = String(results.diffPrice)
            cell.percent.text = String(results.percent)
            cell.textViewTest = results.descriptionOfCrypto ?? ""
            cell.symbolOfTicker = results.symbolOfTicker!
        }
        
        return cell
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChartViewSegueFromFavorites" {
            let chartVC = segue.destination as! ChartViewController
            let cell = sender as! TableViewCell
            chartVC.textTest = cell.textViewTest
            chartVC.symbolOfCurrentCrypto = cell.symbol.text!
            chartVC.symbolOfTicker = cell.symbolOfTicker
            chartVC.diffPriceOfCryptoText = cell.percent.text!
            chartVC.priceOfCryptoText = cell.price.text!
            chartVC.nameOfCryptoText = cell.name.text!
            chartVC.idOfCrypto = cell.idOfCrypto
        }
        
    }
    
}
// DELEGATE
//extension FavoritesTableViewController : NetworkManagerDelegate {
//    func updateData(results: [Crypto]) {
//        print(results)
//    }
//
//
//}

extension FavoritesTableViewController : UISearchResultsUpdating   {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    func filterContentForSearchText(_ searchText : String){
        
        filteredResults = NetworkManager.shared.fullBinanceList.filter({ (searchElem : FullBinanceListElement) -> Bool in

            return searchElem.fullBinanceListDescription!.lowercased().hasPrefix(searchText.lowercased()) ||
                searchElem.displaySymbol!.split(separator: "/").first!.lowercased().hasPrefix(searchText.lowercased())
            
            
        })
       
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
}
