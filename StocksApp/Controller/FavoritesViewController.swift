////
////  FavoritesTableViewController.swift
////  StocksApp
////
////  Created by Григорий Толкачев on 02.03.2021.
////

import UIKit
import CoreData

class FavoritesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    var collectionView : UICollectionView!
    let finHubToken = Constants.finHubToken
    var favorites = [Favorites]()
    var results = [Crypto]()
    var symbols = [String]()
    var coinGecoList = [GeckoListElement]()
//    private var filteredResults = [Crypto]()
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
        setupCollectionView()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Name or symbol of cryptocurrency"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        collectionView.delegate = self
        collectionView.dataSource = self

        // DELEGATE
//        networkManager.delegate = self
        refresh()
//        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "WebsocketDataUpdate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData), name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
 
    }
    func setupCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: self.view.frame.size.width - 20, height: self.view.frame.size.height / 8)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.9725490196, blue: 0.9921568627, alpha: 1)
        collectionView.register(TableCollectionViewCell.self, forCellWithReuseIdentifier: TableCollectionViewCell.reuseId)
        collectionView.register(SearchTableViewCell.self, forCellWithReuseIdentifier: SearchTableViewCell.reuseId)
        view.addSubview(collectionView)
//        layout.itemSize = CGSize(width: collectionView.bounds.width - 20, height: 60)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    @objc func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.collectionView.reloadData()
            self.refresh()
        }
   }
    @objc func reloadData() {
        collectionView.reloadData()
    }
    
    
    // MARK: - Table view data source
    
    
//     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if isFiltering {
//            return filteredResults.count
//        }
//        
//        return NetworkManager.shared.resultsF.count
//        
//    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering {
            return filteredResults.count
        }
        
        return NetworkManager.shared.resultsF.count
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        80
//    }
    
//     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as? TableViewCell else {return UITableViewCell()}
////
////        if isFiltering {
////            let results = filteredResults[indexPath.row]
////            cell.symbol.text = results.symbolOfCrypto
////            cell.name.text = results.nameOfCrypto
////            cell.price.text = results.price
////            cell.percent.text = results.percent
////            cell.symbolOfTicker = results.symbolOfTicker!
//////            cell.idOfCrypto = results.id!
////            cell.textViewTest = results.descriptionOfCrypto ?? ""
////
////        } else {
////            guard let results = NetworkManager.shared.resultsF[indexPath.row] as Crypto? else {return UITableViewCell()}
////            cell.symbol.text = results.symbolOfCrypto
////            cell.name.text = results.nameOfCrypto
////            //            cell.price.text = String(results.index)
////            //            cell.change.text = String(results.diffPrice)
////            //            cell.percent.text = String(results.percent)
////            cell.price.text = results.price
////            cell.percent.text = results.percent
////            cell.textViewTest = results.descriptionOfCrypto ?? ""
////            cell.symbolOfTicker = results.symbolOfTicker!
////        }
////
////        return cell
//        
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoritesCell.reuseId, for: indexPath) as? FavoritesCell else {return UITableViewCell()}
//
//        if isFiltering {
//            let results = filteredResults[indexPath.row]
//            cell.configure(with: results)
//
//
//        } else {
//            guard let results = NetworkManager.shared.resultsF[indexPath.row] as Crypto? else {return UITableViewCell()}
//            cell.configure(with: results)
//
//        }
//
//        return cell
////
//    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoritesCell.reuseId, for: indexPath) as? FavoritesCell else {return UICollectionViewCell()}
        

        if isFiltering {
//            let results = filteredResults[indexPath.row]
//            cell.configure(with: results)
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchTableViewCell.reuseId, for: indexPath) as? SearchTableViewCell else {return UICollectionViewCell()}
            let results = filteredResults[indexPath.row]
            cell.nameOfCrypto.text = results.displaySymbol
            cell.symbolOfCrypto.text = results.fullBinanceListDescription
            return cell


        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TableCollectionViewCell.reuseId, for: indexPath) as? TableCollectionViewCell else {return UICollectionViewCell()}
            guard let results = NetworkManager.shared.resultsF[indexPath.row] as Crypto? else {return UICollectionViewCell()}
            cell.configure(with: results)
            return cell

        }

//        return cell
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let result: Crypto
//        if isFiltering {
////            result = NetworkManager.shared.resultsF[indexPath.row]
//            result = filteredResults[indexPath.row]
//        } else {
//            result = NetworkManager.shared.resultsF[indexPath.row]
//        }
//        let ChartVC = self.storyboard?.instantiateViewController(withIdentifier: "ChartViewController") as! ChartViewController
//        ChartVC.crypto = result
//        self.navigationController?.pushViewController(ChartVC, animated: true)
        
        let ChartVC = self.storyboard?.instantiateViewController(withIdentifier: "ChartViewController") as! ChartViewController
        if isFiltering {
//            result = NetworkManager.shared.resultsF[indexPath.row]
            let elem = filteredResults[indexPath.row]
            result = Crypto(symbolOfCrypto: elem.displaySymbol!, nameOfCrypto: elem.fullBinanceListDescription!, symbolOfTicker: elem.symbol!, id: elem.id!)
        } else {
            result = NetworkManager.shared.resultsF[indexPath.row]
        }
        
        ChartVC.crypto = result
        self.navigationController?.pushViewController(ChartVC, animated: true)
        }
    
}


extension FavoritesViewController : UISearchResultsUpdating   {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    func filterContentForSearchText(_ searchText : String){
        

//        filteredResults = NetworkManager.shared.resultsF.filter({ (searchElem : Crypto) -> Bool in
//
//            return searchElem.symbolOfCrypto.lowercased().hasPrefix(searchText.lowercased()) ||
//                searchElem.nameOfCrypto!.split(separator: "/").first!.lowercased().hasPrefix(searchText.lowercased())
            
        filteredResults = NetworkManager.shared.fullBinanceList.filter({ (searchElem : FullBinanceListElement) -> Bool in

            return searchElem.fullBinanceListDescription!.lowercased().hasPrefix(searchText.lowercased()) ||
                searchElem.displaySymbol!.split(separator: "/").first!.lowercased().hasPrefix(searchText.lowercased())
        })
       
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
    
}
