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
    var favorites = [Favorites]()
    private var results = [Datum]()
    var symbols = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        for i in favorites {
            if let symbol = i.symbol{
            symbols.append(symbol)
            }
        }
        webSocketTask.resume()
        
        for i in self.symbols {
        if !(i.contains("BINANCE")) {
            json(symbol: i)
        }
        }
        
        webSocket(symbols)
        receiveMessage()
        ping()
    }
    func delete() {
        let context = getContext()
        let fetchRequest : NSFetchRequest<Favorites> = Favorites.fetchRequest()
        if let favorites = try? context.fetch(fetchRequest){
            for i in favorites {
                context.delete(i)
            }
        }
      
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
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
    func json(symbol:String){
        let request = NSMutableURLRequest(
            url: NSURL(string: "https://finnhub.io/api/v1/quote?symbol=\(symbol)")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = finHubToken
        
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let stocksData = data, error == nil, response != nil else {return}
            
            do {
                var stocks = try Datum.decode(from: stocksData)
                stocks?.s = symbol
                self.results.append(stocks!)
                
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            
            
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
    
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as? FavoritesTableViewCell else {return UITableViewCell()}
        guard let results = results[indexPath.row] as Datum? else {return UITableViewCell()}
        
        cell.symbol.text = results.s
        
        if let x = results.p {
        cell.price.text = String(x)
        }
        return cell
        
    }
    
}


