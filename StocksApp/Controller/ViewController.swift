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
//    var results = [Datum]()
    var crypto = [Crypto]()
    let symbols = ["BINANCE:BTCUSDT","BINANCE:LTCUSDT", "BINANCE:ETHUSDT"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in self.symbols {
            let crypto = Crypto(name: i, index: 0, closePrice: 0)
            self.crypto.append(crypto)
            json(symbol: i)
        }
        
        webSocketTask.resume()
        webSocket(symbols)
        receiveMessage()
        ping()
        
        
    }
    
    
    func json(symbol:String){
        let currentDateUnix = Date().timeIntervalSince1970
        let prevHourUnix = Int((Calendar.current.date(byAdding: .day, value: -1, to: Date()))!.timeIntervalSince1970)
        print(Calendar.current.date(byAdding: .day, value: -1, to: Date()))
        let nextMinuteUnix = Int((Calendar.current.date(byAdding: .minute, value: +1, to: Date()))!.timeIntervalSince1970)
      

        
        let request = NSMutableURLRequest(
            url: NSURL(string: "https://finnhub.io/api/v1/crypto/candle?symbol=\(symbol)&resolution=60&from=\(prevHourUnix)&to=\(nextMinuteUnix)&token=c12ev3748v6oi252n1fg")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = finHubToken

        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let stocksData = data, error == nil, response != nil else {return}

            do {
                let stocks = try GetData.decode(from: stocksData)
                print(stocks)
                let crypto = Crypto(name: symbol, index: (stocks?.c.last)!, closePrice: (stocks?.c.first)!)
                
                for (index,elem) in self.symbols.enumerated() {
                    if elem == symbol {
                        self.crypto[index] = crypto
                    }
                }

                
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
                    if let data: Data = text.data(using: .utf8) {
                        if let tickData = try? WebSocketData.decode(from: data)?.data {
//                            for i in tickData {
//                                if let symbol = i.s {
//                                    if !(self.array2.contains(symbol)) {
//                                        self.array2.append(symbol)
//                                        let crypto = Crypto(name: symbol, index: i.p!)
//                                        self.crypto.append(crypto)
//                                    }
//                                }
//
//                            }
                            
                            for itemA in tickData {
                                for (indexB,itemB) in (self.crypto).enumerated() {
                                    if itemA.s == itemB.name {
                                        self.crypto[indexB].index = itemA.p!
                                        
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
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        crypto.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? TableViewCell
        else {return UITableViewCell()}
        cell.symbol.text = crypto[indexPath.row].name
        cell.price.text = String(crypto[indexPath.row].index)
        cell.change.text = String(crypto[indexPath.row].diffPrice)
        
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
            let favorite = self.crypto[indexPath.row].name
            let object = Favorites(context: context)
            object.symbol = favorite
            print(object)
            
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




