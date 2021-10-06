//
//  SearchViewController.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 02.07.2021.
//

import UIKit

protocol SearchViewControllerProtocol : UIViewController {
    var isFiltering: Bool { get }
    
}

class SearchViewController: UIViewController, SearchViewControllerProtocol  {
    
    private var collectionView : UICollectionView!
    private var searchController = UISearchController(searchResultsController: nil)
    var presenter : SearchViewPresenterProtocol!
    var isFiltering : Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    private var searchBarIsEmpty : Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCollectionView()
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Name or symbol of cryptocurrency", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)])
        searchController.searchBar.searchTextField.backgroundColor = UIColor(red: 0.124, green: 0.185, blue: 0.446, alpha: 0.5)
        searchController.searchBar.searchTextField.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)
        searchController.searchBar.searchTextField.leftView?.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)
        searchController.searchBar.tintColor = .white
    }
    private func setupCollectionView() {
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
}
extension SearchViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.returNnumberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let margins = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)

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
}
extension SearchViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        presenter.showChartView(indexPath : indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width - 30, height: 63)
    }
}

extension SearchViewController : UICollectionViewDelegateFlowLayout {
    
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
extension SearchViewController : UISearchResultsUpdating   {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    func filterContentForSearchText(_ searchText : String){

        presenter.filter(searchText: searchText)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}
