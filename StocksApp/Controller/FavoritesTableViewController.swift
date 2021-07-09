////
////  FavoritesTableViewController.swift
////  StocksApp
////
////  Created by Григорий Толкачев on 02.03.2021.
////

import UIKit
import CoreData

class FavoritesTableViewController: UITableViewController {
//    let tableView = UITableView(frame: .zero, style: UITableView.Style.grouped)
    let finHubToken = Constants.finHubToken
    var favorites = [Favorites]()
    var results = [Crypto]()
    var symbols = [String]()
    var coinGecoList = [GeckoListElement]()
    private var filteredResults = [Crypto]()
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
        refresh()
//        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "WebsocketDataUpdate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData), name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
 
    }
    
    @objc func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.tableView.reloadData()
            self.refresh()
        }
   }
    @objc func reloadData() {
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredResults.count
        }
        
        return NetworkManager.shared.resultsF.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as? TableViewCell else {return UITableViewCell()}
//
//        if isFiltering {
//            let results = filteredResults[indexPath.row]
//            cell.symbol.text = results.symbolOfCrypto
//            cell.name.text = results.nameOfCrypto
//            cell.price.text = results.price
//            cell.percent.text = results.percent
//            cell.symbolOfTicker = results.symbolOfTicker!
////            cell.idOfCrypto = results.id!
//            cell.textViewTest = results.descriptionOfCrypto ?? ""
//
//        } else {
//            guard let results = NetworkManager.shared.resultsF[indexPath.row] as Crypto? else {return UITableViewCell()}
//            cell.symbol.text = results.symbolOfCrypto
//            cell.name.text = results.nameOfCrypto
//            //            cell.price.text = String(results.index)
//            //            cell.change.text = String(results.diffPrice)
//            //            cell.percent.text = String(results.percent)
//            cell.price.text = results.price
//            cell.percent.text = results.percent
//            cell.textViewTest = results.descriptionOfCrypto ?? ""
//            cell.symbolOfTicker = results.symbolOfTicker!
//        }
//
//        return cell
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoritesCell.reuseId, for: indexPath) as? FavoritesCell else {return UITableViewCell()}

        if isFiltering {
            let results = filteredResults[indexPath.row]
            cell.configure(with: results)


        } else {
            guard let results = NetworkManager.shared.resultsF[indexPath.row] as Crypto? else {return UITableViewCell()}
            cell.configure(with: results)

        }

        return cell
//
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result: Crypto
        if isFiltering {
//            result = NetworkManager.shared.resultsF[indexPath.row]
            result = filteredResults[indexPath.row]
        } else {
            result = NetworkManager.shared.resultsF[indexPath.row]
        }
        let ChartVC = self.storyboard?.instantiateViewController(withIdentifier: "ChartViewController") as! ChartViewController
        ChartVC.crypto = result
        self.navigationController?.pushViewController(ChartVC, animated: true)
    
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
        
//        filteredResults = NetworkManager.shared.fullBinanceList.filter({ (searchElem : FullBinanceListElement) -> Bool in
//
//            return searchElem.fullBinanceListDescription!.lowercased().hasPrefix(searchText.lowercased()) ||
//                searchElem.displaySymbol!.split(separator: "/").first!.lowercased().hasPrefix(searchText.lowercased())
//
//
//        })
        filteredResults = NetworkManager.shared.resultsF.filter({ (searchElem : Crypto) -> Bool in

            return searchElem.symbolOfCrypto.lowercased().hasPrefix(searchText.lowercased()) ||
                searchElem.nameOfCrypto!.split(separator: "/").first!.lowercased().hasPrefix(searchText.lowercased())
            
            
        })
       
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
}
