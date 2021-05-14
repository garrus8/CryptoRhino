//
//  ViewController.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 25.02.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    let finHubToken = Constants.finHubToken
    let networkManager = NetworkManager()
    @IBOutlet weak var tableView: UITableView!
    var results = [Crypto]()
    var symbols = [String]()
    var coinGecoList = [GeckoListElement]()
    let favoritesVC = FavoritesTableViewController()
    var favorites = [Favorites]()
    var resultsF = [Crypto]()
    var symbolsF = [String]()
    
    private var filteredResults = [FullBinanceListElement]()
    private var isFiltering : Bool {
        return searchController.isActive && !searchBarIsEmpty
    }

    
    @IBAction func xxx(_ sender: Any) {
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchBarIsEmpty : Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // DELEGATE
//        networkManager.delegate = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Name or symbol of cryptocurrency"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        let queue1 = DispatchQueue(label: "1")
        
        queue1.sync {
            
            self.networkManager.getData()
            self.networkManager.getTopOfCrypto(tableView: [self.tableView])
            self.networkManager.getFullListOfCrypto()
            self.networkManager.test(tableView: [self.tableView])
//            self.networkManager.webSocket(symbols: self.networkManager.symbols, symbolsF: self.networkManager.symbolsF)
//            self.networkManager.receiveMessage(tableView: [self.tableView])
            
//            self.networkManager.getFullBinanceList()
            self.networkManager.getFullCoinCapList()
            
        }
        
        
        
    }


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredResults.count
        }
        
        return networkManager.results.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? TableViewCell
        else {return UITableViewCell()}
        
        
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
            let results = networkManager.results[indexPath.row]
            cell.symbol.text = results.symbolOfCrypto
            cell.name.text = results.nameOfCrypto
            cell.price.text = String(results.index)
            cell.change.text = String(results.diffPrice)
            cell.percent.text = String(results.percent)
            cell.textViewTest = results.descriptionOfCrypto ?? ""
            cell.symbolOfTicker = "BINANCE:\(results.symbolOfTicker!)"
            
            
        }
        
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChartViewSegue" {
            let chartVC = segue.destination as! ChartViewController
            let cell = sender as! TableViewCell
            chartVC.textTest = cell.textViewTest
            chartVC.symbolOfCurrentCrypto = cell.symbol.text!
            chartVC.symbolOfTicker = cell.symbolOfTicker
            chartVC.idOfCrypto = cell.idOfCrypto
            
            
            
            
        }
    }
    

    
    
    
}

extension ViewController : UISearchResultsUpdating   {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    func filterContentForSearchText(_ searchText : String){
        
        filteredResults = networkManager.fullBinanceList.filter({ (searchElem : FullBinanceListElement) -> Bool in

            return searchElem.fullBinanceListDescription!.lowercased().hasPrefix(searchText.lowercased()) ||
                searchElem.displaySymbol!.split(separator: "/").first!.lowercased().hasPrefix(searchText.lowercased())
            
            
        })
       
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
}


// DELEGATE
//extension ViewController : NetworkManagerDelegate {
//    func updateData(results: [Crypto]) {
//        print(results)
//    }
//
//
//}


