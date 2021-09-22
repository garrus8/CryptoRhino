//
//  SearchViewController.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 02.07.2021.
//

import UIKit

protocol SearchViewControllerProtocol : UIViewController {
//    var searchController : UISearchController { get set }
    var isFiltering: Bool { get }
    
}

class SearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SearchViewControllerProtocol  {
    
    var collectionView : UICollectionView!
    var searchController = UISearchController(searchResultsController: nil)
    //MARK: - Presenter
    var presenter : SearchViewPresenterProtocol!
//    private var filteredResults = GeckoList()
    var isFiltering : Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    var headerText = "123"
    
    var searchBarIsEmpty : Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor(hexString: "#4158B7")
        collectionView.register(SearchTableViewCell.self, forCellWithReuseIdentifier: SearchTableViewCell.reuseId)
        collectionView.register(SearchTableViewCellWithImage.self, forCellWithReuseIdentifier: SearchTableViewCellWithImage.reuseId)
        collectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionReusableView.id)
//        layout.itemSize = CGSize(width: collectionView.bounds.width - 20, height: 60)
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //MARK: - Presenter
//        if isFiltering {
//            return filteredResults.count
//        } else {
//            return NetworkManager.shared.topList.count
//        }
        presenter.returNnumberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //MARK: - Presenter
        let margins = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
//        if presenter.isFiltering {
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchTableViewCell.reuseId, for: indexPath) as? SearchTableViewCell else {return SearchTableViewCell()}
//            let result = presenter.filteredResults[indexPath.row]
//            cell.configure(with: result)
//            cell.contentView.frame = cell.contentView.frame.inset(by: margins)
//            return cell
//        } else {
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchTableViewCellWithImage.reuseId, for: indexPath) as? SearchTableViewCellWithImage else {return SearchTableViewCellWithImage()}
//            let result = NetworkManager.shared.topList[indexPath.row]
//            cell.configure(with: result)
//            cell.contentView.frame = cell.contentView.frame.inset(by: margins)
//            return cell
//        }
        if isFiltering {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchTableViewCell.reuseId, for: indexPath) as? SearchTableViewCell else {return SearchTableViewCell()}
            let result = presenter.getFilteredResult(indexPath: indexPath)
            cell.configure(with: result)
            cell.contentView.frame = cell.contentView.frame.inset(by: margins)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchTableViewCellWithImage.reuseId, for: indexPath) as? SearchTableViewCellWithImage else {return SearchTableViewCellWithImage()}
            let result = presenter.getTopListElem(indexPath: indexPath)
            cell.configure(with: result)
            cell.contentView.frame = cell.contentView.frame.inset(by: margins)
            return cell
        }
    
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //MARK: - Presenter
//        let crypto : Crypto
//        if presenter.isFiltering {
//            let result = presenter.filteredResults[indexPath.row]
//            crypto = Crypto(symbolOfCrypto: result.symbol!, nameOfCrypto: result.name, id: result.id)
//        } else {
//            let result = NetworkManager.shared.topList[indexPath.row]
//            crypto = Crypto(symbolOfCrypto: result.symbol, nameOfCrypto: result.name, id: result.id)
//        }
//        let ChartVC = ChartViewController()
//        ChartVC.crypto = crypto
//        self.navigationController?.pushViewController(ChartVC, animated: true)
        presenter.showChartView(indexPath : indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width - 30, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionReusableView.id, for: indexPath) as! HeaderCollectionReusableView
        if isFiltering {
            header.changeText(str: "Search Results: ")
        } else {
            header.changeText(str: "Trending search")
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 40)
    }


}
//MARK: - Presenter
extension SearchViewController : UISearchResultsUpdating   {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    func filterContentForSearchText(_ searchText : String){

//        filteredResults = NetworkManager.shared.fullBinanceList.filter({ (searchElem : GeckoListElement) -> Bool in
//
//            return searchElem.symbol!.lowercased().hasPrefix(searchText.lowercased()) ||
//                searchElem.name!.split(separator: "/").first!.lowercased().hasPrefix(searchText.lowercased())
//
//        })
        presenter.filter(searchText: searchText)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }

    }
}
