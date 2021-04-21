//
//  WebSocketManager.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 25.02.2021.
//

import UIKit
import CoreData

class NetworkManager  {

    let finHubToken = Constants.finHubToken
    var results = [Crypto]()
    var symbols = [String]()
    var coinGecoList = [GeckoListElement]()
    let favoritesVC = FavoritesTableViewController()
    var favorites = [Favorites]()
    var resultsF = [Crypto]()
    var symbolsF = [String]()

    let webSocketTask = URLSession(configuration: .default).webSocketTask(with: URL(string: "wss://ws.finnhub.io?token=c12ev3748v6oi252n1fg")!)

    func webSocket(symbols : [String], symbolsF : [String]) {
        let set = Set(symbols).union(Set(symbolsF))
        for symbol in set {
            let symbolForFinHub = "BINANCE:\(symbol)USDT"
            let message = URLSessionWebSocketTask.Message.string("{\"type\":\"subscribe\",\"symbol\":\"\(symbolForFinHub)\"}")


            webSocketTask.send(message) { error in
                if let error = error {
                    print("WebSocket couldn’t send message because: \(error)")
                }
            }
        }


        webSocketTask.resume()
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

    func receiveMessage(tableView : UITableView) {
        webSocketTask.receive { result in
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    if let data: Data = text.data(using: .utf8) {
                        if let tickData = try? WebSocketData.decode(from: data)?.data {

                            for itemA in tickData {
                                for (indexB,itemB) in (self.results).enumerated() {
                                    let itemBForFinHub = "BINANCE:\(itemB.symbolOfCrypto.uppercased())USDT"
                                    if itemA.s == itemBForFinHub {
                                        self.results[indexB].index = itemA.p

                                    }
                                }
                                for (indexB,itemB) in (self.resultsF).enumerated() {
                                    let itemBForFinHub = "BINANCE:\(itemB.symbolOfCrypto.uppercased())USDT"
                                    if itemA.s == itemBForFinHub {
                                        self.resultsF[indexB].index = itemA.p



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
                    tableView.reloadData()
                }
                self.receiveMessage(tableView: tableView)
            }
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


            for i in favorites {
                if let symbol = i.symbol{
                    symbolsF.append(symbol)
                    let crypto = Crypto(symbolOfCrypto: symbol, index: 0, closePrice: 0, nameOfCrypto: nil, descriptionOfCrypto: nil)
                    self.resultsF.append(crypto)
                    self.favoritesVC.results.append(crypto)

                }

            }
            DispatchQueue.main.async {
                self.favoritesVC.tableView.reloadData()
            }

        } catch let error as NSError {
            print(error.localizedDescription)
        }

    }
    func json(symbol:String){
        let symbolForFinHub = "BINANCE:\(symbol)USDT"
        let prevDayUnix = Int((Calendar.current.date(byAdding: .hour, value: -24, to: Date()))!.timeIntervalSince1970)
        let nextMinuteUnix = Int((Calendar.current.date(byAdding: .minute, value: +1, to: Date()))!.timeIntervalSince1970)


        let request = NSMutableURLRequest(
            url: NSURL(string: "https://finnhub.io/api/v1/crypto/candle?symbol=\(symbolForFinHub)&resolution=5&from=\(prevDayUnix)&to=\(nextMinuteUnix)&token=c12ev3748v6oi252n1fg")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = finHubToken

        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let stocksData = data, error == nil, response != nil else {return}

            do {
                let stocks = try GetData.decode(from: stocksData)
                if stocks == nil {
                    for (index, elem) in self.symbols.enumerated() {
                        if elem == symbol {
                            self.symbols.remove(at: index)
                            self.results.remove(at: index)
                        }
                    }
                }
                guard let stocks2 = stocks else {return}
                guard let stockLast = stocks2.c?.last else {return}
                guard let stockFirst = stocks2.c?.first else {return}

                for (index,elem) in self.symbols.enumerated() {
                    if elem == symbol {

                        self.results[index].symbolOfCrypto = symbol
                        self.results[index].index = stockLast
                        self.results[index].closePrice = stockFirst

                    }
                }


//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }

            } catch let error as NSError {
                print(error.localizedDescription)
            }

        }.resume()

    }

    func json2(tableView : UITableView){

        let request = NSMutableURLRequest(
            url: NSURL(string: "https://min-api.cryptocompare.com/data/top/totalvolfull?limit=10&tsym=USD")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let stocksData = data, error == nil, response != nil else {return}

            do {

                let stocks = try Toplist.decode(from: stocksData)

                for i in 0..<(stocks?.data!.count)! {

                    let elem = stocks?.data![i]
                    let string = elem!.coinInfo!.name
                    self.symbols.append(string!)
                    let crypto = Crypto(symbolOfCrypto: string!, index: 0, closePrice: 0, nameOfCrypto: nil, descriptionOfCrypto: nil)
                    self.results.append(crypto)
                    self.json(symbol: string!)

                }

            } catch let error as NSError {
                print(error.localizedDescription)
            }

            self.json3()
            self.webSocketTask.resume()
            self.webSocket(symbols: self.symbols, symbolsF: self.symbolsF)
            self.receiveMessage(tableView: tableView)
            self.ping()


        }.resume()

    }

    func json3(){


        let request = NSMutableURLRequest(
            url: NSURL(string: "https://api.coingecko.com/api/v3/coins/list")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let stocksData = data, error == nil, response != nil else {return}

            do {
                let stocks = try GeckoList.decode(from: stocksData)
                self.coinGecoList = stocks!

                self.quickSortForCoinGecko(&self.coinGecoList, start: 0, end: self.coinGecoList.count)

                for i in self.symbols {
                    let indexOfSymbol = self.binarySearchFoCoinGeckoList(key: i.lowercased(), list: self.coinGecoList)
                    self.json4(symbol: self.coinGecoList[indexOfSymbol!].id!)
                }



            } catch let error as NSError {
                print(error.localizedDescription)
            }

        }.resume()

    }


    func json4(symbol: String) {
        let request = NSMutableURLRequest(
            url: NSURL(string: "https://api.coingecko.com/api/v3/coins/\(symbol)?localization=false&tickers=false&market_data=false&community_data=true&developer_data=false&sparkline=false")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let stocksData = data, error == nil, response != nil else {return}

            do {
                let stocks = try GeckoSymbol.decode(from: stocksData)

                for elemOfResults in self.results {
                    if elemOfResults.symbolOfCrypto == stocks?.symbol?.uppercased() {
                        elemOfResults.nameOfCrypto = stocks?.name
                        elemOfResults.descriptionOfCrypto = stocks?.geckoSymbolDescription?.en

                    }
                }


            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }.resume()

    }

    func quickSortForCoinGecko (_ list : inout [GeckoListElement], start : Int, end : Int) {

        if end - start < 2 {
            return
        }
        let pivot = list[start + (end - start) / 2]
        var low = start
        var high = end - 1


        while (low <= high) {
            if list[low].symbol! < pivot.symbol! {
                low += 1
                continue
            }
            if list[high].symbol! > pivot.symbol! {
                high -= 1
                continue
            }

            let temp = list[low]
            list[low] = list[high]
            list[high] = temp

            low += 1
            high -= 1
        }
        quickSortForCoinGecko(&list, start: start, end: high + 1)
        quickSortForCoinGecko(&list, start: high + 1, end: end)

    }

    func binarySearchFoCoinGeckoList(key : String, list : [GeckoListElement]) -> Int? {

        var low = 0
        var high = list.count - 1

        while low <= high {
            let mid = low + (high - low) / 2

            if key < list[mid].symbol! {
                high = mid - 1
            } else if key > list[mid].symbol! {
                low = mid + 1
            } else {
                return mid
            }
        }
        return nil
    }


}
