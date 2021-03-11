//
//  ViewController.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 25.02.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    let finHubToken = Constants.finHubToken
    let networkManager = NetworkManager()
    @IBOutlet weak var tableView: UITableView!
    var results = [Datum]()
    let symbols = ["BINANCE:BTCUSDT", "BINANCE:LTCUSDT"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webSocketTask.resume()
        webSocket(symbols)
        receiveMessage()
        ping()
        json()
    }
    
    func json(){
        let request = NSMutableURLRequest(
            url: NSURL(string: "https://finnhub-realtime-stock-price.p.rapidapi.com/quote?symbol=BINANCE:BTCUSDT")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = finHubToken
        
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let stocksData = data, error == nil, response != nil else {return}
            
//            do {
//                let decoder = JSONDecoder()
//                let stocks = try decoder.decode(StocksData.self, from: stocksData)
//                self.results = stocks.quotes
//
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
            
            
            
        }.resume()
        
    }
    
    
    let webSocketTask = URLSession(configuration: .default).webSocketTask(with: URL(string: "wss://ws.finnhub.io?token=c12ev3748v6oi252n1fg")!)
    
    func webSocket(_ symbols : [String]) {
        for symbol in symbols {
            let message = URLSessionWebSocketTask.Message.string("{\"type\":\"subscribe\",\"symbol\":\"\(symbol)\"}")
            
            webSocketTask.send(message) { error in
                if let error = error {
                    print("WebSocket couldn’t send message because: \(error)")
                }
            }
        }
    }
    
    var array2 = [String]()
    
    func receiveMessage() {
        webSocketTask.receive { result in
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
//                    print("Received string: \(text)")
                    if let data: Data = text.data(using: .utf8) {
                        if let tickData = try? WebSocketData.decode(from: data)?.data {
                            
                            for i in tickData {
                                if let symbol = i.s {
                                    if !(self.array2.contains(symbol)) {
                                        self.array2.append(symbol)
                                        self.results.append(i)
                                    }
                                }
                                
                            }
                            
                            for itemA in tickData {
                                for (indexB,itemB) in (self.results).enumerated() {
                                    if itemA.s == itemB.s {
                                        self.results[indexB] = itemA
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                    
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    fatalError()
                }
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }
                self.receiveMessage()
            }
        }
    }
    
    final func indexesOfStocks(stocks:[Datum]) -> [Int] {
        
        return stocks.reduce([]) { (currentResult, currentStocks) in
            
            if let currentStockIndex = self.results.firstIndex(where: { currentStocks.s == $0.s }) {
                
                return currentResult + [currentStockIndex]
            }
            return currentResult
        }
    }
    final func updateArrContacts(indexesOfStocksValue:[Int], tickDataArr:[Datum]) {
        
        for i in stride(from: 0, to: indexesOfStocksValue.count, by: 1) {
            
            self.results[indexesOfStocksValue[i]] = tickDataArr[i]
        }
    }
    final func updateRows(stocksIndexes:[Int]) {
        
        DispatchQueue.main.async {
            
            self.tableView.performBatchUpdates({
                
                let indexesToUpdate = stocksIndexes.reduce([], { (currentResult, currentStocksIndex) -> [IndexPath] in
                    
                    if currentStocksIndex < self.tableView.numberOfRows(inSection: 0) {
                        
                        return currentResult + [IndexPath.init(row: currentStocksIndex, section: 0)]
                    }
                    return currentResult
                })
                self.tableView.reloadRows(at: indexesToUpdate, with: UITableView.RowAnimation.automatic)
            }) { (_) in
                
            }
        }
    }
    
    func ping() {
        webSocketTask.sendPing { error in
            if let error = error {
                print("Error when sending PING \(error)")
            } else {
                print("Web Socket connection is alive")
                DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                    self.ping()
                }
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? TableViewCell
        else {return UITableViewCell()}
        cell.symbol.text = results[indexPath.row].s
        cell.price.text = String(results[indexPath.row].p ?? 0)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let favoriteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            
            let context = self.getContext()
            let favorite = self.results[indexPath.row].s
            let object = Favorites(context: context)
            object.symbol = favorite
            
            do {
                try context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            completionHandler(true)
        }
        
        favoriteAction.image = UIImage(systemName: "suit.heart.fill")
        favoriteAction.backgroundColor = .systemBlue
        let configuration = UISwipeActionsConfiguration(actions: [favoriteAction])
        return configuration
    }
    
}


//    func json(){
//        let request = NSMutableURLRequest(
//            url: NSURL(string: "https://finnhub-realtime-stock-price.p.rapidapi.com/quote?symbol=AAPL")! as URL,
//            cachePolicy: .useProtocolCachePolicy,
//            timeoutInterval: 10.0)
//        request.httpMethod = "GET"
//        request.allHTTPHeaderFields = finHubToken
//
//        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
//            guard let stocksData = data, error == nil, response != nil else {return}
//
//            do {
//                let decoder = JSONDecoder()
//                let stocks = try decoder.decode(StocksData.self, from: stocksData)
//                self.results = stocks.quotes
//
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
//
//
//
//        }.resume()
//
//    }
