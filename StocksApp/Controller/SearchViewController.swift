//
//  SearchViewController.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 02.07.2021.
//

import UIKit

class SearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    
    var collectionView : UICollectionView!
    let searchController = UISearchController(searchResultsController: nil)
    private var filteredResults = [FullBinanceListElement]()
    private var isFiltering : Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    var searchBarIsEmpty : Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(hexString: "#202F72")
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.topItem?.title = "Search"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Name or symbol of cryptocurrency", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)])
        searchController.searchBar.searchTextField.backgroundColor = UIColor(red: 0.124, green: 0.185, blue: 0.446, alpha: 0.5)
        setupCollectionView()
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
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
        collectionView.register(SearchTableViewCell.self, forCellWithReuseIdentifier: SearchTableViewCell.reuseId)
        view.addSubview(collectionView)
//        layout.itemSize = CGSize(width: collectionView.bounds.width - 20, height: 60)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    


//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if isFiltering {
//            return filteredResults.count
//        } else {
//            return NetworkManager.shared.fullBinanceList.count
//        }
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.reuseId) as? SearchTableViewCell else {return UITableViewCell()}
//        if isFiltering {
//            let results = filteredResults[indexPath.row]
//            cell.nameOfCrypto.text = results.displaySymbol
//            cell.symbolOfCrypto.text = results.fullBinanceListDescription
//        } else {
//            let results = NetworkManager.shared.fullBinanceList[indexPath.row]
//            cell.nameOfCrypto.text = results.displaySymbol
//            cell.symbolOfCrypto.text = results.fullBinanceListDescription
//        }
//        let margins = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
//        cell.contentView.frame = cell.contentView.frame.inset(by: margins)
//        return cell
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering {
            return filteredResults.count
        } else {
//            return NetworkManager.shared.fullBinanceList.count
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchTableViewCell.reuseId, for: indexPath) as? SearchTableViewCell else {return SearchTableViewCell()}
        if isFiltering {
            let results = filteredResults[indexPath.row]
            cell.configure(with: results)
        } else {
            let results = NetworkManager.shared.fullBinanceList[indexPath.row]
            cell.configure(with: results)
            
        }
        let margins = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        cell.contentView.frame = cell.contentView.frame.inset(by: margins)
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let result: FullBinanceListElement
//        if isFiltering {
//            result = filteredResults[indexPath.row]
//        } else {
//            result = NetworkManager.shared.fullBinanceList[indexPath.row]
//        }
//        let ChartVC = self.storyboard?.instantiateViewController(withIdentifier: "ChartViewController") as! ChartViewController
//        let crypto = Crypto(symbolOfCrypto: result.displaySymbol!, nameOfCrypto: result.fullBinanceListDescription!, symbolOfTicker: result.symbol!, id: result.id!)
//        ChartVC.crypto = crypto
//        self.navigationController?.pushViewController(ChartVC, animated: true)
//
//    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let result: FullBinanceListElement
        if isFiltering {
            result = filteredResults[indexPath.row]
        } else {
            result = NetworkManager.shared.fullBinanceList[indexPath.row]
        }
        let ChartVC = self.storyboard?.instantiateViewController(withIdentifier: "ChartViewController") as! ChartViewController
        let crypto = Crypto(symbolOfCrypto: result.displaySymbol!, nameOfCrypto: result.fullBinanceListDescription!, symbolOfTicker: result.symbol!, id: result.id!)
        ChartVC.crypto = crypto
        print(result.displaySymbol!, result.id!)
        self.navigationController?.pushViewController(ChartVC, animated: true)
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width - 30, height: 60)
    }


}
extension SearchViewController : UISearchResultsUpdating   {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    func filterContentForSearchText(_ searchText : String){

        filteredResults = NetworkManager.shared.fullBinanceList.filter({ (searchElem : FullBinanceListElement) -> Bool in

            return searchElem.fullBinanceListDescription!.lowercased().hasPrefix(searchText.lowercased()) ||
                searchElem.displaySymbol!.split(separator: "/").first!.lowercased().hasPrefix(searchText.lowercased())


        })

        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }

    }

    
}
