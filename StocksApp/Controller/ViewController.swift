//
//  ViewController.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 25.02.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {

    
    let finHubToken = Constants.finHubToken
//    let networkManager = NetworkManager()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
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
        collectionView.delegate = self
        collectionView.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Name or symbol of cryptocurrency"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        let queue1 = DispatchQueue(label: "1")
        
        queue1.sync {
//            NetworkManager.shared.deleteAllData()
            NetworkManager.shared.getData()
            NetworkManager.shared.getTopOfCrypto(tableView: [self.tableView])
            NetworkManager.shared.getFullListOfCrypto()
            NetworkManager.shared.test2(array: &NetworkManager.shared.resultsF)
            NetworkManager.shared.test2(array: &NetworkManager.shared.results)
//            NetworkManager.shared.webSocket(symbols: NetworkManager.shared.symbols, symbolsF: NetworkManager.shared.symbolsF)
            
            
            
            NetworkManager.shared.webSocket2(symbols: NetworkManager.shared.websocketArray)
            NetworkManager.shared.receiveMessage(tableView: [self.tableView], collectionView: self.collectionView)
        
            NetworkManager.shared.getFullCoinCapList()
            self.collectionView.reloadData()
        }
        
        
        
    }


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredResults.count
        }
        
//        return NetworkManager.shared.results.count
        return NetworkManager.shared.results.count
        
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
//            let results = NetworkManager.shared.results[indexPath.row]
            let results = NetworkManager.shared.results[indexPath.row]
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return NetworkManager.shared.collectionViewArray.count
        NetworkManager.shared.collectionViewArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else {return UICollectionViewCell()}
//        cell.label.text = NetworkManager.shared.collectionViewArray[indexPath.row].nameOfCrypto
        let item = NetworkManager.shared.collectionViewArray[indexPath.item]
        
        cell.update(item: item)
        cell.backgroundColor = .blue
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
        let chartVC = segue.destination as! ChartViewController
        if segue.identifier == "TableVIewSegue" {
            let cell = sender as! TableViewCell
            chartVC.textTest = cell.textViewTest
            chartVC.symbolOfCurrentCrypto = cell.symbol.text!
            chartVC.symbolOfTicker = cell.symbolOfTicker
            chartVC.idOfCrypto = cell.idOfCrypto
            chartVC.diffPriceOfCryptoText = cell.percent.text!
            chartVC.priceOfCryptoText = cell.price.text!
            chartVC.nameOfCryptoText = cell.name.text!
            
        }
        if segue.identifier == "CollectionViewSegue" {
            let cell = sender as! CollectionViewCell
            chartVC.symbolOfCurrentCrypto = cell.symbolOfCrypto
            chartVC.textTest = cell.textViewTest
            chartVC.nameOfCrypto = cell.nameOfElelm
            chartVC.diffPriceOfCryptoText = cell.percent
            chartVC.priceOfCryptoText = cell.index.text!
            chartVC.nameOfCryptoText = cell.nameOfElelm.text!
            chartVC.symbolOfTicker = cell.symbolOfTicker
        }
        
    }
    

    
    
    
}

extension ViewController : UISearchResultsUpdating   {
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


// DELEGATE
//extension ViewController : NetworkManagerDelegate {
//    func updateData(results: [Crypto]) {
//        print(results)
//    }
//
//
//}


