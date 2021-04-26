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
 
    }
    
    @objc func websocketDataUpdate (notification : Notification) {
        guard let userInfo = notification.userInfo else {return}
        let crypto = userInfo["Key"]
        results = crypto as! [Crypto]
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
    
//    func getData() {
//        let context = getContext()
//        let fetchRequest : NSFetchRequest<Favorites> = Favorites.fetchRequest()
//        let sortDescriptor = NSSortDescriptor(key: "symbol", ascending: false)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        
//        do {
//            favorites = try context.fetch(fetchRequest)
//            
//            for i in favorites {
//                if let symbol = i.symbol{
//                    symbols.append(symbol)
//                    let crypto = Crypto(symbolOfCrypto: symbol, index: 0, closePrice: 0, nameOfCrypto: nil, descriptionOfCrypto: nil)
//                    self.results.append(crypto)
//                    self.json(symbol: symbol)
//                }
//                
//            }
//
//        } catch let error as NSError {
//            print(error.localizedDescription)
//        }
//        
//        self.json3()
////        self.networkManager.webSocket(symbols)
//        receiveMessage()
//        ping()
//        
//        
//    }
//    func json(symbol:String){
//        let symbolForFinHub = "BINANCE:\(symbol)USDT"
//        let prevDayUnix = Int((Calendar.current.date(byAdding: .hour, value: -25, to: Date()))!.timeIntervalSince1970)
//        let nextMinuteUnix = Int((Calendar.current.date(byAdding: .minute, value: +1, to: Date()))!.timeIntervalSince1970)
//        
//        
//        let request = NSMutableURLRequest(
//            url: NSURL(string: "https://finnhub.io/api/v1/crypto/candle?symbol=\(symbolForFinHub)&resolution=15&from=\(prevDayUnix)&to=\(nextMinuteUnix)&token=c12ev3748v6oi252n1fg")! as URL,
//            cachePolicy: .useProtocolCachePolicy,
//            timeoutInterval: 10.0)
//        request.httpMethod = "GET"
//        request.allHTTPHeaderFields = finHubToken
//        
//        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
//            guard let stocksData = data, error == nil, response != nil else {return}
//            
//            do {
//                let stocks = try GetData.decode(from: stocksData)
//                if stocks == nil {
//                    for (index, elem) in self.symbols.enumerated() {
//                        if elem == symbol {
//                            self.symbols.remove(at: index)
//                            self.results.remove(at: index)
//                        }
//                    }
//                }
//                guard let stocks2 = stocks else {return}
//                guard let stockLast = stocks2.c?.last else {return}
//                guard let stockFirst = stocks2.c?.first else {return}
//                
//                for (index,elem) in self.symbols.enumerated() {
//                    if elem == symbol {
//                        self.results[index].symbolOfCrypto = symbol
//                        self.results[index].index = stockLast
//                        self.results[index].closePrice = stockFirst
//                        
//                    }
//                }
//                
//                
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//                
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
//            
//        }.resume()
//        
//    }
//    
//    func json3(){
//        
//        let request = NSMutableURLRequest(
//            url: NSURL(string: "https://api.coingecko.com/api/v3/coins/list")! as URL,
//            cachePolicy: .useProtocolCachePolicy,
//            timeoutInterval: 10.0)
//        request.httpMethod = "GET"
//        
//        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
//            guard let stocksData = data, error == nil, response != nil else {return}
//            
//            do {
//                let stocks = try GeckoList.decode(from: stocksData)
//                self.coinGecoList = stocks!
//                
////                for i in self.symbols {
////                    for j in self.coinGecoList {
////                        if i.lowercased() == j.symbol {
////                            self.json4(symbol: j.id!)
////
////                        }
////                    }
////                }
//                self.quickSortForCoinGecko(&self.coinGecoList, start: 0, end: self.coinGecoList.count)
//
//                for i in self.symbols {
//                    let indexOfSymbol = self.binarySearchFoCoinGeckoList(key: i.lowercased(), list: self.coinGecoList)
//                    self.json4(symbol: self.coinGecoList[indexOfSymbol!].id!)
//                }
//                
//                
//                
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
//            
//        }.resume()
//       
//        
//    }
//    func binarySearchFoCoinGeckoList(key : String, list : [GeckoListElement]) -> Int? {
//        
//        var low = 0
//        var high = list.count - 1
//        
//        while low <= high {
//            let mid = low + (high - low) / 2
//            
//            if key < list[mid].symbol! {
//                high = mid - 1
//            } else if key > list[mid].symbol! {
//                low = mid + 1
//            } else {
//                return mid
//            }
//        }
//        return nil
//    }
//    func quickSortForCoinGecko (_ list : inout [GeckoListElement], start : Int, end : Int) {
//        
//        if end - start < 2 {
//            return
//        }
//        let pivot = list[start + (end - start) / 2]
//        var low = start
//        var high = end - 1
//        
//        
//        while (low <= high) {
//            if list[low].symbol! < pivot.symbol! {
//                low += 1
//                continue
//            }
//            if list[high].symbol! > pivot.symbol! {
//                high -= 1
//                continue
//            }
//            
//            let temp = list[low]
//            list[low] = list[high]
//            list[high] = temp
//            
//            low += 1
//            high -= 1
//        }
//        quickSortForCoinGecko(&list, start: start, end: high + 1)
//        quickSortForCoinGecko(&list, start: high + 1, end: end)
//        
//    }
//    
//    func json4(symbol: String) {
//        let request = NSMutableURLRequest(
//            url: NSURL(string: "https://api.coingecko.com/api/v3/coins/\(symbol)?localization=false&tickers=false&market_data=false&community_data=true&developer_data=false&sparkline=false")! as URL,
//            cachePolicy: .useProtocolCachePolicy,
//            timeoutInterval: 10.0)
//        request.httpMethod = "GET"
//        
//        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
//            guard let stocksData = data, error == nil, response != nil else {return}
//            
//            do {
//                let stocks = try GeckoSymbol.decode(from: stocksData)
//                
//                for elemOfResults in self.results {
//                    if elemOfResults.symbolOfCrypto == stocks?.symbol?.uppercased() {
//                        elemOfResults.nameOfCrypto = stocks?.name
//                        elemOfResults.descriptionOfCrypto = stocks?.geckoSymbolDescription?.en
//                        
//                    }
//                }
//                
//                
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
//        }.resume()
//        
//    }
//    
//    
//    let webSocketTask = URLSession(configuration: .default).webSocketTask(with: URL(string: "wss://ws.finnhub.io?token=c12ev3748v6oi252n1fg")!)
//    
//    func webSocket(_ symbols : [String]) {
//        for symbol in symbols {
//            let symbolForFinHub = "BINANCE:\(symbol)USDT"
//            let message = URLSessionWebSocketTask.Message.string("{\"type\":\"subscribe\",\"symbol\":\"\(symbolForFinHub)\"}")
//            
//            
//            webSocketTask.send(message) { error in
//                if let error = error {
//                    print("WebSocket couldn’t send message because: \(error)")
//                }
//            }
//        }
//    }
//    
//    func receiveMessage() {
//        webSocketTask.receive { result in
//            switch result {
//            case .failure(let error):
//                print("Error in receiving message: \(error)")
//            case .success(let message):
//                switch message {
//                case .string(let text):
//                    if let data: Data = text.data(using: .utf8) {
//                        if let tickData = try? WebSocketData.decode(from: data)?.data {
//                            
//                            for itemA in tickData {
//                                for (indexB,itemB) in (self.results).enumerated() {
//                                    let itemBForFinHub = "BINANCE:\(itemB.symbolOfCrypto.uppercased())USDT"
//                                    if itemA.s == itemBForFinHub {
//                                        self.results[indexB].index = itemA.p
//                                        
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    
//                    
//                case .data(let data):
//                    print("Received data: \(data)")
//                @unknown default:
//                    fatalError()
//                }
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//                self.receiveMessage()
//            }
//        }
//    }
//    
//    
//    func ping() {
//        webSocketTask.sendPing { error in
//            if let error = error {
//                print("Error when sending PING \(error)")
//            } else {
//                print("Web Socket connection is alive")
//                DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
//                    self.ping()
//                }
//            }
//        }
//    }
    
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as? TableViewCell else {return UITableViewCell()}
        guard let results = results[indexPath.row] as Crypto? else {return UITableViewCell()}
        print("Results : \(results)")
        cell.symbol.text = results.symbolOfCrypto
        cell.name.text = results.nameOfCrypto
        cell.price.text = String(results.index)
        cell.change.text = String(results.diffPrice)
        cell.percent.text = String(results.percent)
        cell.textViewTest = results.descriptionOfCrypto ?? ""
        
        return cell
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChartViewSegueFromFavorites" {
            let chartVC = segue.destination as! ChartViewController
            let cell = sender as! TableViewCell
            chartVC.textTest = cell.textViewTest
            chartVC.symbolOfCurrentCrypto = cell.symbol.text ?? ""

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
