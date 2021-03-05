//
//  FavoritesTableViewController.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 02.03.2021.
//

import UIKit
import CoreData

class FavoritesTableViewController: UITableViewController {
    
    let mboumToken = Constants.mboumToken
    var favorites = [Favorites]()
    private var results = [DirectStockData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        favoritesJson()
    }
    
    private func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func getData() {
        let context = getContext()
        let fetchRequest : NSFetchRequest<Favorites> = Favorites.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "symbol", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            favorites = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
//        for item in favorites {
//            if let symbol = item.symbol {
//                favoritesJson(symbol)
//            }
//        }
    }
    func favoritesJson(){
        let request = NSMutableURLRequest(
            url: NSURL(string: "https://mboum.com/api/v1/qu/quote/?symbol=CAN")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = mboumToken
        
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let stocksData = data, error == nil, response != nil else {return}
            do {
                let decoder = JSONDecoder()
                let stocks = try decoder.decode(DirectStockData.self, from: stocksData)
                self.results.append(stocks)
                print(stocks)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }.resume()
    }
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as? FavoritesTableViewCell else {return UITableViewCell()}
        guard let results = results[indexPath.row] as DirectStockData? else {return UITableViewCell()}
        
        cell.symbol.text = results.symbol
        cell.title.text = results.shortName
        cell.change.text = String(results.regularMarketChange)
        cell.price.text = String(results.regularMarketPrice)
        
        return cell
        
    }
    
}


