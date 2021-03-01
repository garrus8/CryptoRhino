//
//  ViewController.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 25.02.2021.
//

import UIKit

class ViewController: UIViewController, UITabBarDelegate, UITableViewDataSource {
    
    
    let mboumToken = Constants.mboumToken
    let networkManager = NetworkManager()
    @IBOutlet weak var tableView: UITableView!
    private var results = [Quote]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        json()
    }
    
    func json(){
        let request = NSMutableURLRequest(
            url: NSURL(string: "https://mboum.com/api/v1/co/collections/?list=day_gainers&start=1")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = mboumToken

        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let stocksData = data, error == nil, response != nil else {return}

            do {
                let decoder = JSONDecoder()
                let stocks = try decoder.decode(StocksData.self, from: stocksData)
                self.results = stocks.quotes
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }



        }.resume()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? TableViewCell
        else {return UITableViewCell()}
        cell.title.text = results[indexPath.row].shortName
        cell.symbol.text = results[indexPath.row].symbol
        cell.price.text = String(results[indexPath.row].regularMarketPrice)
        cell.change.text = String(results[indexPath.row].regularMarketChange)
        return cell
    }
    
}

