////
////  FavoritesTableViewController.swift
////  StocksApp
////
////  Created by Григорий Толкачев on 02.03.2021.
////

import UIKit
import CoreData

class FavoritesTableViewController: UITableViewController {
    
    let finHubToken = Constants.finHubToken
    let networkManager = NetworkManager()
    var favorites = [Favorites]()
    var results = [Crypto]()
    var symbols = [String]()
    var coinGecoList = [GeckoListElement]()
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // DELEGATE
//        networkManager.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(websocketDataUpdate), name: NSNotification.Name(rawValue: "WebsocketDataUpdate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
 
    }
    
    @objc func refresh() {
        print("WORKING")
        
        
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

   }
    

    
    @objc func websocketDataUpdate (notification : Notification) {
        guard let userInfo = notification.userInfo else {return}
        
        let crypto = userInfo["Key"]
        results = crypto as! [Crypto]
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    

    
    private func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    

    
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as? TableViewCell else {return UITableViewCell()}
        guard let results = results[indexPath.row] as Crypto? else {return UITableViewCell()}
        
        cell.symbol.text = results.symbolOfCrypto
        cell.name.text = results.nameOfCrypto
        cell.price.text = String(results.index)
        cell.change.text = String(results.diffPrice)
        cell.percent.text = String(results.percent)
        cell.textViewTest = results.descriptionOfCrypto ?? ""
        cell.symbolOfTicker = results.symbolOfTicker!
        return cell
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChartViewSegueFromFavorites" {
            let chartVC = segue.destination as! ChartViewController
            let cell = sender as! TableViewCell
            chartVC.textTest = cell.textViewTest
            chartVC.symbolOfCurrentCrypto = cell.symbol.text!
            chartVC.symbolOfTicker = cell.symbolOfTicker
            print(chartVC.symbolOfCurrentCrypto)
        }
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
