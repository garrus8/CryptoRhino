////
////  FavoritesTableViewController.swift
////  StocksApp
////
////  Created by Григорий Толкачев on 02.03.2021.
////

import UIKit
import CoreData

protocol FavoritesViewControllerProtocol : UIViewController {
    var isFiltering: Bool { get }
}

class FavoritesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FavoritesViewControllerProtocol  {
    
    var collectionView : UICollectionView!
    let finHubToken = Constants.finHubToken
    //MARK: - PRESENTER
    var presenter : FavoritesViewPresenterProtocol!
//    var favorites = [Favorites]()
//    var results = [Crypto]()
//    var symbols = [String]()
//    var coinGecoList = [GeckoListElement]()
//    private var filteredResults = [Crypto]()
    
//    private var filteredResults = GeckoList()
//    private var filteredResultsOfFavorites = [Crypto]()
    //MARK: - PRESENTER
    let searchController = UISearchController(searchResultsController: nil)
    
    var searchBarIsEmpty : Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    var isFiltering : Bool {
        return searchController.isActive && !searchBarIsEmpty
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupCollectionView()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.searchBar.placeholder = "Name or symbol of cryptocurrency"
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Name or symbol of cryptocurrency", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)])
        searchController.searchBar.searchTextField.backgroundColor = UIColor(red: 0.124, green: 0.185, blue: 0.446, alpha: 0.5)
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.searchBar.searchTextField.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)
        searchController.searchBar.searchTextField.leftView?.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)
        searchController.searchBar.tintColor = .red
    }
    func setupCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: self.view.frame.size.width - 20, height: self.view.frame.size.height / 8)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor(hexString: "#4158B7")
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //MARK: - PRESENTER
//        if isFiltering && NetworkManager.shared.resultsF.isEmpty {
//            return filteredResults.count
//        } else if isFiltering && !NetworkManager.shared.resultsF.isEmpty {
//            return filteredResultsOfFavorites.count
//        }
//        return NetworkManager.shared.resultsF.count
        presenter.returnNumberOfItems()
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width - 30, height: 60)
    }

//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
////        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoritesCell.reuseId, for: indexPath) as? FavoritesCell else {return UICollectionViewCell()}
//
//
//        if isFiltering {
//
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchTableViewCell.reuseId, for: indexPath) as? SearchTableViewCell else {return UICollectionViewCell()}
//            let results = filteredResults[indexPath.row]
//            cell.nameOfCrypto.text = results.displaySymbol
//            cell.symbolOfCrypto.text = results.fullBinanceListDescription
//            return cell
//
//
//        } else {
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TableCollectionViewCell.reuseId, for: indexPath) as? TableCollectionViewCell else {return UICollectionViewCell()}
//            guard let results = NetworkManager.shared.resultsF[indexPath.row] as Crypto? else {return UICollectionViewCell()}
//            cell.configure(with: results)
//            return cell
//
//        }
//
////        return cell
//    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //MARK: - PRESENTER
        if isFiltering && presenter.isFavoritesEmpty {

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchTableViewCell.reuseId, for: indexPath) as? SearchTableViewCell else {return UICollectionViewCell()}
            let results = presenter.getResultForFilteredAndEmpty(indexPath: indexPath)
            cell.nameOfCrypto.text = results.name
            cell.symbolOfCrypto.text = results.symbol
            return cell

        } else if isFiltering && !presenter.isFavoritesEmpty {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TableCollectionViewCell.reuseId, for: indexPath) as? TableCollectionViewCell else {return UICollectionViewCell()}
            let results = presenter.getResultForFilteredAndFilled(indexPath: indexPath)
            cell.configure(with: results)
            return cell
            
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TableCollectionViewCell.reuseId, for: indexPath) as? TableCollectionViewCell else {return UICollectionViewCell()}
            let results = presenter.getResultForNotFiltered(indexPath: indexPath)
            cell.configure(with: results)
            return cell
        }

    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //MARK: - PRESENTER
//        let result: Crypto
//        
////        let ChartVC = ChartViewController()
//        if isFiltering && presenter.isFavoritesEmpty {
//            let elem = filteredResults[indexPath.row]
//            result = Crypto(symbolOfCrypto: elem.symbol!, nameOfCrypto: elem.name, id: elem.id)
//        } else if isFiltering && !presenter.isFavoritesEmpty {
//            result = filteredResultsOfFavorites[indexPath.row]
//        } else {
//            result = NetworkManager.shared.resultsF[indexPath.row]
//        }
//        let ChartVC = ChartViewController()
//        ChartVC.crypto = result
//        self.navigationController?.pushViewController(ChartVC, animated: true)
        presenter.showChartView(indexPath: indexPath)
        
        }
    
}


extension FavoritesViewController : UISearchResultsUpdating   {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    func filterContentForSearchText(_ searchText : String){
        //MARK: - PRESENTER
//        if NetworkManager.shared.resultsF.isEmpty {
//            filteredResults = NetworkManager.shared.fullBinanceList.filter({ (searchElem : GeckoListElement) -> Bool in
//                
//                return searchElem.symbol!.lowercased().hasPrefix(searchText.lowercased()) ||
//                    searchElem.name!.split(separator: "/").first!.lowercased().hasPrefix(searchText.lowercased())
//            })
//        } else {
//            filteredResultsOfFavorites = NetworkManager.shared.resultsF.filter({ (searchElem : Crypto) -> Bool in
//                
//                return searchElem.nameOfCrypto!.lowercased().hasPrefix(searchText.lowercased()) ||
//                    searchElem.symbolOfCrypto.split(separator: "/").first!.lowercased().hasPrefix(searchText.lowercased())
//            })
//        }
        presenter.filter(searchText: searchText)
            
       
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
    
}
