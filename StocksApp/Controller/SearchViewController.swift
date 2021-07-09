//
//  SearchViewController.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 02.07.2021.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let tableView = UITableView(frame: .zero, style: UITableView.Style.grouped)
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
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Name or symbol of cryptocurrency"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        self.view.addSubview(tableView)
        tableView.frame = CGRect.init(origin: .zero, size: self.view.frame.size)
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredResults.count
        } else {
            return NetworkManager.shared.fullBinanceList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.reuseId) as? SearchTableViewCell else {return UITableViewCell()}
        if isFiltering {
            let results = filteredResults[indexPath.row]
            cell.nameOfCrypto.text = results.displaySymbol
            cell.symbolOfCrypto.text = results.fullBinanceListDescription
        } else {
            let results = NetworkManager.shared.fullBinanceList[indexPath.row]
            cell.nameOfCrypto.text = results.displaySymbol
            cell.symbolOfCrypto.text = results.fullBinanceListDescription
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result: FullBinanceListElement
        if isFiltering {
            result = filteredResults[indexPath.row]
        } else {
            result = NetworkManager.shared.fullBinanceList[indexPath.row]
        }
        let ChartVC = self.storyboard?.instantiateViewController(withIdentifier: "ChartViewController") as! ChartViewController
        let crypto = Crypto(symbolOfCrypto: result.displaySymbol!, nameOfCrypto: result.fullBinanceListDescription!, symbolOfTicker: result.symbol!, id: result.id!)
        ChartVC.crypto = crypto
        self.navigationController?.pushViewController(ChartVC, animated: true)
        
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
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
            self.tableView.reloadData()
        }

    }

    
}
