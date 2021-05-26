//
//  WebSocketManager.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 25.02.2021.
//

import UIKit
import CoreData
// DELEGATE
//protocol NetworkManagerDelegate : class {
//    func updateData (results : [Crypto])
//}

/*
 СДЕЛАТЬ ВСЕ МЕТОДЫ ЭТОГО КЛАССА static, чтобы не создавать экземпляр класса
 TABLEVIEW ПЕРЕДАВАТЬ В ЗАМЫКАНИЕ, А НЕ В ПАРАМЕТР МЕТОДА, И УЖЕ ТАМ ВЫЗЫВАТЬ МЕТОД И ПЕРЕДАВАТЬ ТУДА АКТУАЛЬНЫЙ ТЭЙБЛВЬЮ
 Вынести ячейки в ксиб
 В избранных хранить не только символ но и название, чтобы потом его не запрашивать с коингеко
 Сделать обработку ответа от сервера, при запросе графика, если request.statusCode == error => в  контроллере ячейка с графиком пустая и его вообще нет.
 */


class NetworkManager  {
    // DELEGATE
    //    weak var delegate : NetworkManagerDelegate?
    
    let finHubToken = Constants.finHubToken
    var results = [Crypto]()
    var symbols = [String]()
    var coinGecoList = [GeckoListElement]()
    var favorites = [Favorites]()
    var resultsF = [Crypto]()
    var symbolsF = [String]()
    var fullBinanceList = [FullBinanceListElement]()
    var coinCapDict = [[String: String?]]()
    var dict = [String : [Crypto]]()
    //    var searchElements = [SearchElement]()
    let favoriteVC = FavoritesTableViewController()
    var collectionViewSymbols = [String]()
    var collectionViewArray = [Crypto]()
    var websocketArray = [String]()
    
    
    static let shared = NetworkManager()
    private init() {}
    
    private func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    func deleteAllData() {
        let context = getContext()
        let fetchRequest : NSFetchRequest<Favorites> = Favorites.fetchRequest()
        if let objects = try? context.fetch(fetchRequest) {
            for object in objects {
                context.delete(object)
            }
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    let queueA = DispatchQueue(label: "A")
    let groupA = DispatchGroup()
    let groupCoreData = DispatchGroup()
    
    func getData() {
        
        groupCoreData.enter()
        let context = self.getContext()
        let fetchRequest : NSFetchRequest<Favorites> = Favorites.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            self.favorites = try context.fetch(fetchRequest)
            setData(tableView : [favoriteVC.tableView])
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        groupCoreData.leave()
    }
    
    func setData(tableView : [UITableView]) {
        self.resultsF.removeAll()
        for i in self.favorites {
            if let symbol = i.symbol{
                
                let crypto = Crypto(symbolOfCrypto: symbol, index: 0, closePrice: 0, nameOfCrypto: nil, descriptionOfCrypto: nil, symbolOfTicker: i.symbolOfTicker)
                self.symbolsF.append(i.symbol!)
                self.resultsF.append(crypto)
                // ХЫЧ ХЫЧ
//                self.getFinHubData(symbol: symbol, tableView : [favoriteVC.tableView])
                self.newMethod(symbol: symbol)
                self.websocketArray.append(symbol)
            }
        }
        DispatchQueue.main.async {
            for i in tableView {
                i.reloadData()
            }
        }
    }
    
    
    
    func getTopOfCrypto(tableView : [UITableView]){
        groupA.enter()
        queueA.async(group : groupA, flags: .barrier){
            
            let request = NSMutableURLRequest(
                url: NSURL(string: "https://min-api.cryptocompare.com/data/top/totalvolfull?limit=20&tsym=USD")! as URL,
                cachePolicy: .useProtocolCachePolicy,
                timeoutInterval: 10.0)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                guard let stocksData = data, error == nil, response != nil else {return}
                
                do {
                    guard let stocksData = try (Toplist.decode(from: stocksData))?.data else {return}
                    
                    for i in 0..<(stocksData.count) {
                        let elem = stocksData[i]
                        guard let string = elem.coinInfo!.name else {return}
                        
                        if string != "USDT" && string != "BNBBEAR" {
                            self.symbols.append(string)
                            let crypto = Crypto(symbolOfCrypto: string, index: 0, closePrice: 0, nameOfCrypto: nil, descriptionOfCrypto: nil, symbolOfTicker: "\(string)USDT")
                            self.results.append(crypto)
                            self.websocketArray.append(string)
                            // ХЫЧ ХЫЧ
//                            self.getFinHubData(symbol: string, tableView : tableView)
                            self.newMethod(symbol: string)
                            
                        }
                    }
                    DispatchQueue.main.async {
                        for i in tableView {
                            i.reloadData()
                        }
                    }
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                
                self.groupA.leave()
                
            }.resume()
            
        }
    }
    
    
//    func getFinHubData(symbol:String, tableView : [UITableView]){
//        groupA.enter()
//        queueA.async(group : groupA, flags: .barrier){
//
//
//            let symbolForFinHub = "BINANCE:\(symbol)USDT"
//
//            // Вынести все юниксы в константы в другой файл
//            let prevDayUnix = Int((Calendar.current.date(byAdding: .hour, value: -24, to: Date()))!.timeIntervalSince1970)
//            let nextMinuteUnix = Int((Calendar.current.date(byAdding: .minute, value: +1, to: Date()))!.timeIntervalSince1970)
//
//
//            let request = NSMutableURLRequest(
//                url: NSURL(string: "https://finnhub.io/api/v1/crypto/candle?symbol=\(symbolForFinHub)&resolution=5&from=\(prevDayUnix)&to=\(nextMinuteUnix)&token=c12ev3748v6oi252n1fg")! as URL,
//                cachePolicy: .useProtocolCachePolicy,
//                timeoutInterval: 10.0)
//            //Нужно ли указывать метод? Он же по дефолту ГЕТ
//            request.httpMethod = "GET"
//            request.allHTTPHeaderFields = self.finHubToken
//
//
//            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
//                guard let stocksData = data, error == nil, response != nil else {return}
//
//                do {
//                    let stocks = try GetData.decode(from: stocksData)
//
//                    if stocks == nil {
//                        for (index, elem) in self.symbols.enumerated() {
//                            if elem == symbol {
//                                self.symbols.remove(at: index)
//                                self.results.remove(at: index)
//
//                            }
//                        }
//                        for (index, elem) in self.symbolsF.enumerated() {
//                            if elem == symbol {
//
//                                self.symbolsF.remove(at: index)
//                                self.resultsF.remove(at: index)
//
//                            }
//                        }
//                    }
//                    guard let stocks2 = stocks else {return}
//                    guard let stockLast = stocks2.c?.last else {return}
//                    guard let stockFirst = stocks2.c?.first else {return}
//
//                    for (index,elem) in self.symbols.enumerated() {
//                        if elem == symbol {
//
//                            self.results[index].symbolOfCrypto = symbol
//                            self.results[index].index = stockLast
//                            self.results[index].closePrice = stockFirst
//                        }
//                    }
//
//
//
//                    for elem in self.resultsF {
//                        if elem.symbolOfCrypto == symbol {
//
//                            elem.index = stockLast
//                            elem.closePrice = stockFirst
//
//
//                        }
//                    }
//
//
//
//                    DispatchQueue.main.async {
//                        for i in tableView {
//                            i.reloadData()
//                        }
//                    }
//
//                } catch let error as NSError {
//                    print(error.localizedDescription)
//                }
//
//
//            }.resume()
//        }
//        self.groupA.leave()
//    }
    
    
//    func getFinHubData(symbol : String, complition : @escaping (GetData?)->()){
//        groupA.enter()
//        queueA.async(group : groupA, flags: .barrier){
//
//
//            let symbolForFinHub = "BINANCE:\(symbol)USDT"
//
//            // Вынести все юниксы в константы в другой файл
//            let prevDayUnix = Int((Calendar.current.date(byAdding: .hour, value: -25, to: Date()))!.timeIntervalSince1970)
//            let nextMinuteUnix = Int((Calendar.current.date(byAdding: .minute, value: +1, to: Date()))!.timeIntervalSince1970)
//
//
//            let request = NSMutableURLRequest(
//                url: NSURL(string: "https://finnhub.io/api/v1/crypto/candle?symbol=\(symbolForFinHub)&resolution=5&from=\(prevDayUnix)&to=\(nextMinuteUnix)&token=c12ev3748v6oi252n1fg")! as URL,
//                cachePolicy: .useProtocolCachePolicy,
//                timeoutInterval: 10.0)
//            //Нужно ли указывать метод? Он же по дефолту ГЕТ
//            request.httpMethod = "GET"
//            request.allHTTPHeaderFields = self.finHubToken
//
//
//            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
//                guard let stocksData = data, error == nil, response != nil else {return}
//
//                do {
//                    let stocks = try GetData.decode(from: stocksData)
//                    complition(stocks)
//
//                } catch let error as NSError {
//                    print(error.localizedDescription)
//                }
//
//
//            }.resume()
//        }
//        self.groupA.leave()
//    }
    
    func getFinHubData(symbol : String, interval : String = "day", complition : @escaping ([String : Any])->()){
        groupA.enter()
        queueA.async(group : groupA, flags: .barrier){
            print("SYMBOL \(symbol)")
            
            let symbolForFinHub = "BINANCE:\(symbol)USDT"
            
            // Вынести все юниксы в константы в другой файл
            let prevDayUnix = Int((Calendar.current.date(byAdding: .hour, value: -25, to: Date()))!.timeIntervalSince1970)
            let prevMonthUnix = Int((Calendar.current.date(byAdding: .day, value: -21, to: Date()))!.timeIntervalSince1970)
            let prevYearUnix = Int((Calendar.current.date(byAdding: .month, value: -12, to: Date()))!.timeIntervalSince1970)
            let nextMinuteUnix = Int((Calendar.current.date(byAdding: .minute, value: +1, to: Date()))!.timeIntervalSince1970)
            
            var prevValue = Int()
            var resolution = String()
            var dateFormat = String()
            
            switch interval {
            case "day":
                dateFormat = "MM/dd HH:mm"
                prevValue = prevDayUnix
                resolution = "5"
            case "month":
                dateFormat = "MMM d"
                prevValue = prevMonthUnix
                resolution = "60"
            case "year":
                dateFormat = "dd.MM.yy"
                prevValue = prevYearUnix
                resolution = "D"
            default:
                print("ПРОБЛЕМА В СВИЧ")
            }
            
            let request = NSMutableURLRequest(
                url: NSURL(string: "https://finnhub.io/api/v1/crypto/candle?symbol=\(symbolForFinHub)&resolution=\(resolution)&from=\(prevValue)&to=\(nextMinuteUnix)&token=c12ev3748v6oi252n1fg")! as URL,
                cachePolicy: .useProtocolCachePolicy,
                timeoutInterval: 10.0)
            //Нужно ли указывать метод? Он же по дефолту ГЕТ
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = self.finHubToken
            
            
            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                guard let stocksData = data, error == nil, response != nil else {return}
                
                do {
                    guard let stocks = try GetData.decode(from: stocksData) else {return}
                    let dict = ["stocks" : stocks, "dateFormat" : dateFormat] as [String : Any]

                    complition(dict)
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                
            }.resume()
        }
        self.groupA.leave()
    }
    
    
    func newMethod(symbol:String) {
        
        getFinHubData(symbol: symbol) { (dict) in
            
//            if stocks == nil {
//                for (index, elem) in self.symbols.enumerated() {
//                    if elem == symbol {
//                        self.symbols.remove(at: index)
//                        self.results.remove(at: index)
//
//                    }
//                }
//                for (index, elem) in self.symbolsF.enumerated() {
//                    if elem == symbol {
//
//                        self.symbolsF.remove(at: index)
//                        self.resultsF.remove(at: index)
//
//                    }
//                }
//            }
            
            // HHHHHHHHHH
            let stocks = dict["stocks"] as! GetData

            guard let stockLast = stocks.c?.last else {return}
            guard let stockFirst = stocks.c?.first else {return}
            
            for (index,elem) in self.symbols.enumerated() {
                if elem == symbol {
                    
                    self.results[index].symbolOfCrypto = symbol
                    self.results[index].index = stockLast
                    self.results[index].closePrice = stockFirst
                }
            }
            
            for elem in self.resultsF {
                if elem.symbolOfCrypto == symbol {
                    
                    elem.index = stockLast
                    elem.closePrice = stockFirst
                    
                }
            }
            
            
        }

    }
    
    //УДАЛИТЬ
//    func getFinHubData2(symbol:String, complition : @escaping ([Double])-> ()){
//        let symbolForFinHub = "BINANCE:\(symbol)USDT"
//
//        let prevDayUnix = Int((Calendar.current.date(byAdding: .hour, value: -25, to: Date()))!.timeIntervalSince1970)
//        let nextMinuteUnix = Int((Calendar.current.date(byAdding: .minute, value: +1, to: Date()))!.timeIntervalSince1970)
//
//
//        let request = NSMutableURLRequest(
//            url: NSURL(string: "https://finnhub.io/api/v1/crypto/candle?symbol=\(symbolForFinHub)&resolution=5&from=\(prevDayUnix)&to=\(nextMinuteUnix)&token=c12ev3748v6oi252n1fg")! as URL,
//            cachePolicy: .useProtocolCachePolicy,
//            timeoutInterval: 10.0)
//        //Нужно ли указывать метод? Он же по дефолту ГЕТ
//        request.httpMethod = "GET"
//        request.allHTTPHeaderFields = self.finHubToken
//
//
//        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
//            guard let stocksData = data, error == nil, response != nil else {return}
//
//            do {
//                let stocks = try GetData.decode(from: stocksData)
//
//                guard let stocks2 = stocks else {return}
//                guard let stockLast = stocks2.c?.last else {return}
//                guard let stockFirst = stocks2.c?.first else {return}
//                let arr = [stockLast,stockFirst]
//                complition(arr)
//
//
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
//
//
//        }.resume()
//
//
//    }
    
    
    
    let queueB = DispatchQueue(label: "B")
    
    func getFullListOfCrypto(){
        groupA.enter()
        queueA.async(group : groupA, flags: .barrier){
            
            let request = NSMutableURLRequest(
                url: NSURL(string: "https://api.coingecko.com/api/v3/coins/list")! as URL,
                cachePolicy: .useProtocolCachePolicy,
                timeoutInterval: 10.0)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                
                guard let stocksData = data, error == nil, response != nil else {return}
                
                do {
                    guard let stocks = try GeckoList.decode(from: stocksData) else {return}
                    self.coinGecoList = stocks
                    
                    self.quickSortForCoinGecko(&self.coinGecoList, start: 0, end: self.coinGecoList.count)
                    
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                self.groupA.leave()
                
            }.resume()
        }
    }
    
    
    
//    func test(array : [String], tableView : [UITableView] ) {
//        groupA.wait()
//
//        for i in array {
//
//            let indexOfSymbol = self.binarySearchFoCoinGeckoList(key: i.lowercased(), list: self.coinGecoList)
//            self.getCoinGeckoData(symbol: self.coinGecoList[indexOfSymbol!].id!, tableView: tableView)
//
//        }
//
//    }
    
//    func test(tableView : [UITableView] ) {
//        groupA.wait()
//
//        for i in self.symbols {
//
//            let indexOfSymbol = self.binarySearchFoCoinGeckoList(key: i.lowercased(), list: self.coinGecoList)
//            self.getCoinGeckoData(symbol: self.coinGecoList[indexOfSymbol!].id!, tableView: tableView)
//        }
//        for i in self.symbolsF {
//
//            let indexOfSymbol = self.binarySearchFoCoinGeckoList(key: i.lowercased(), list: self.coinGecoList)
//            self.getCoinGeckoData(symbol: self.coinGecoList[indexOfSymbol!].id!, tableView: tableView)
//
//        }
//
//    }
    
    func test2(array : inout [Crypto]) {
        groupA.wait()
        
        for i in array {
            let symbol = i.symbolOfCrypto
            let indexOfSymbol = self.binarySearchFoCoinGeckoList(key: symbol.lowercased(), list: self.coinGecoList)
            self.getCoinGeckoData2(symbol: self.coinGecoList[indexOfSymbol!].id!) { (stocks) in
                i.descriptionOfCrypto = stocks.geckoSymbolDescription?.en
                i.nameOfCrypto = stocks.name
                
            }
        }
    }
    
    
    
//    func getCoinGeckoData(symbol: String, tableView : [UITableView]) {
//
//        queueB.sync(flags: .barrier){
//
//            let request = NSMutableURLRequest(
//                url: NSURL(string: "https://api.coingecko.com/api/v3/coins/\(symbol)?localization=false&tickers=false&market_data=false&community_data=true&developer_data=false&sparkline=false")! as URL,
//                cachePolicy: .useProtocolCachePolicy,
//                timeoutInterval: 10.0)
//            request.httpMethod = "GET"
//
//            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
//                guard let stocksData = data, error == nil, response != nil else {return}
//                do {
//                    let stocks = try GeckoSymbol.decode(from: stocksData)
//                    for elemOfResults in self.results {
//                        if elemOfResults.symbolOfCrypto == stocks?.symbol?.uppercased() {
//                            elemOfResults.nameOfCrypto = stocks?.name
//                            elemOfResults.descriptionOfCrypto = stocks?.geckoSymbolDescription?.en
//                        }
//                    }
//                    for elemOfResults in self.resultsF {
//                        if elemOfResults.symbolOfCrypto == stocks?.symbol?.uppercased() {
//                            elemOfResults.nameOfCrypto = stocks?.name
//                            elemOfResults.descriptionOfCrypto = stocks?.geckoSymbolDescription?.en
//
//                        }
//                    }
//                    DispatchQueue.main.async {
//                        tableView.first?.reloadData()
//                    }
//
//                } catch let error as NSError {
//                    print(error.localizedDescription)
//                }
//            }.resume()
//        }
//    }
    
    func getCoinGeckoData2(symbol: String, complition : @escaping (GeckoSymbol)->()) {
        
        queueB.sync(flags: .barrier){
            
            let request = NSMutableURLRequest(
                url: NSURL(string: "https://api.coingecko.com/api/v3/coins/\(symbol)?localization=false&tickers=false&market_data=false&community_data=true&developer_data=false&sparkline=false")! as URL,
                cachePolicy: .useProtocolCachePolicy,
                timeoutInterval: 10.0)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                guard let stocksData = data, error == nil, response != nil else {return}
                do {
                    let stocks = try GeckoSymbol.decode(from: stocksData)
                    
                    complition(stocks!)
  
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }.resume()
        }
    }
    
    let queueD = DispatchQueue(label: "D")
    
    //    func getFullBinanceList() {
    //        groupA.wait()
    //        queueD.sync{
    //            let request = NSMutableURLRequest(
    //                url: NSURL(string: "https://finnhub.io/api/v1/crypto/symbol?exchange=binance&token=c12ev3748v6oi252n1fg")! as URL,
    //                cachePolicy: .useProtocolCachePolicy,
    //                timeoutInterval: 10.0)
    //            request.httpMethod = "GET"
    //
    //            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
    //                guard let stocksData = data, error == nil, response != nil else {return}
    //                do {
    //
    //                    guard let elems = try FullBinanceList.decode(from: stocksData) else {return}
    //
    ////                    self.fullBinanceList = elems
    //                    var index = 0
    //                    for i in elems {
    //                        let secondElementOfSymbol = i.displaySymbol?.split(separator: "/")[1]
    //                        let firstElementOfSymbol = i.displaySymbol?.split(separator: "/").first
    //
    //
    //                        if secondElementOfSymbol == "USDT" {
    //
    //                            self.fullBinanceList.append(i)
    //
    //                            for j in self.coinCapDict {
    //                                if j["symbol"]!! == firstElementOfSymbol! {
    //                                    self.fullBinanceList[index].rank = Int(j["rank"]!!)
    //                                }
    //
    ////
    //                        }
    //                            index += 1
    //                        }
    ////
    //                    }
    //                    self.fullBinanceList.sort{$0.rank ?? 101 < $1.rank ?? 101}
    //
    //
    //                    self.x()
    //
    //                } catch let error as NSError {
    //                    print(error.localizedDescription)
    //                }
    //            }.resume()
    //
    //        }
    //
    //
    //    }
    
    func getFullBinanceList() {
        
        let request = NSMutableURLRequest(
            url: NSURL(string: "https://finnhub.io/api/v1/crypto/symbol?exchange=binance&token=c12ev3748v6oi252n1fg")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let stocksData = data, error == nil, response != nil else {return}
            
            do {
                guard let elems = try FullBinanceList.decode(from: stocksData) else {return}
//                var index = 0
//                var btc = 0
                
                for i in elems {
                    
                    let secondElementOfSymbol = i.displaySymbol?.split(separator: "/")[1]
                    let firstElementOfSymbol = i.displaySymbol?.split(separator: "/").first
                    let symbolOfFinHubList = String((i.displaySymbol?.split(separator: "/").first)!)
                    let indexOfGeckoList = self.binarySearchFoCoinGeckoList(key: symbolOfFinHubList.lowercased(), list: self.coinGecoList)
                    
//                    if firstElementOfSymbol == "BTC" {
//                        btc += 1
//                    }
                    if secondElementOfSymbol == "USDT" {
                        if indexOfGeckoList != nil {
                            let name = self.coinGecoList[indexOfGeckoList!].name!
                            let displaySymbol = self.coinGecoList[indexOfGeckoList!].symbol?.uppercased()
                            var rank = 101
                            let id = self.coinGecoList[indexOfGeckoList!].id
                            for j in self.coinCapDict {
                                if j["symbol"]!! == firstElementOfSymbol! {
                                    rank = Int(j["rank"]!!)!
                                }
                            }
                            let elem = FullBinanceListElement(fullBinanceListDescription: name, displaySymbol: displaySymbol, symbol: i.symbol, id : id, rank: rank)
                            self.fullBinanceList.append(elem)
//                            index += 1
                        }
                    }
                }
                
                self.fullBinanceList.sort{$0.rank ?? 101 < $1.rank ?? 101}
                
                self.collectionViewLoad()
                
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }.resume()
        
    }
    
    func collectionViewLoad() {
        
        for index in 0..<20 {
            let symbolOfCrypto = self.fullBinanceList[index].displaySymbol!
            
            let crypto = Crypto(symbolOfCrypto: symbolOfCrypto, index: 0.0, closePrice: 0.0, nameOfCrypto: self.fullBinanceList[index].fullBinanceListDescription, descriptionOfCrypto: "", symbolOfTicker: self.fullBinanceList[index].symbol)
            
            self.collectionViewArray.append(crypto)
            self.websocketArray.append(symbolOfCrypto)
            
            
            self.getFinHubData(symbol: symbolOfCrypto) { (dict) in
                let stocks = dict["stocks"] as! GetData
                guard let stockLast = stocks.c?.last else {return}
                guard let stockFirst = stocks.c?.first else {return}
                self.collectionViewArray[index].index = stockLast
                self.collectionViewArray[index].closePrice = stockFirst
            }

        }
        
        self.test2(array: &self.collectionViewArray)
        self.webSocket2(symbols: self.websocketArray)
        
    }
    
    
    
    func getFullCoinCapList() {
        
        let request = NSMutableURLRequest(
            url: NSURL(string: "https://api.coincap.io/v2/assets")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let stocksData = data, error == nil, response != nil else {return}
            do {
                
                guard let elems = try FullCoinCapList.decode(from: stocksData) else {return}
                self.coinCapDict = elems.data!
                
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }.resume()
        
        getFullBinanceList()
    }
    
    //func x() {
    //
    //    for i in 0..<self.fullBinanceList.count {
    //
    //        let symbolOfFinHubList = String((self.fullBinanceList[i].displaySymbol?.split(separator: "/").first)!)
    //        let indexOfGeckoList = self.binarySearchFoCoinGeckoList(key: symbolOfFinHubList.lowercased(), list: self.coinGecoList)
    //        if indexOfGeckoList != nil {
    //            let name = self.coinGecoList[indexOfGeckoList!].name!
    //            self.fullBinanceList[i].fullBinanceListDescription = name
    //            self.fullBinanceList[i].displaySymbol = self.coinGecoList[indexOfGeckoList!].symbol?.uppercased()
    //
    //
    //        } else {
    //            self.fullBinanceList[i].fullBinanceListDescription = "1"
    //        }
    //    }
    //
    //
    //}
    
    
    
    
    
    // WEBSOCKET
    
    let queueC = DispatchQueue(label: "C")
    
    let webSocketTask = URLSession(configuration: .default).webSocketTask(with: URL(string: "wss://ws.finnhub.io?token=c12ev3748v6oi252n1fg")!)
    
    func webSocket(symbols : [String], symbolsF : [String]) {
        groupA.wait()
        queueC.async {
            
            let set = Set(symbols).union(Set(symbolsF))
            
            for symbol in set {
                let symbolForFinHub = "BINANCE:\(symbol)USDT"
                let message = URLSessionWebSocketTask.Message.string("{\"type\":\"subscribe\",\"symbol\":\"\(symbolForFinHub)\"}")
                
                
                self.webSocketTask.send(message) { error in
                    if let error = error {
                        print("WebSocket couldn’t send message because: \(error)")
                    }
                }
            }
            
            
            self.webSocketTask.resume()
            self.ping()
            
        }
    }
    func webSocket2(symbols: [String]) {
        groupA.wait()
        queueC.async {
            
            let set = Set(symbols)
            for symbol in set {
                let symbolForFinHub = "BINANCE:\(symbol)USDT"
                let message = URLSessionWebSocketTask.Message.string("{\"type\":\"subscribe\",\"symbol\":\"\(symbolForFinHub)\"}")
                
                
                self.webSocketTask.send(message) { error in
                    if let error = error {
                        print("WebSocket couldn’t send message because: \(error)")
                    }
                }
            }
            
            
            self.webSocketTask.resume()
            self.ping()
            
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
    //var dict = [String : [Crypto]]()
    
    func receiveMessage(tableView : [UITableView], collectionView : UICollectionView) {
        groupA.wait()
        queueC.async {
            self.webSocketTask.receive { [weak self] result in
                guard let self = self else {return}
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
                                            
                                            
                                            // DELEGATE
                                            //                                        self.delegate?.updateData(results: self.results)
                                            
                                        }
                                    }
                                    for (indexB,itemB) in (self.collectionViewArray).enumerated() {
                                        let itemBForFinHub = "BINANCE:\(itemB.symbolOfCrypto.uppercased())USDT"
                                        if itemA.s == itemBForFinHub {
                                            
                                            self.collectionViewArray[indexB].index = itemA.p
                                            
                                            
                                            // DELEGATE
                                            //                                        self.delegate?.updateData(results: self.results)
                                            
                                        }
                                    }
                                    for (indexB,itemB) in (self.resultsF).enumerated() {
                                        let itemBForFinHub = "BINANCE:\(itemB.symbolOfCrypto.uppercased())USDT"
                                        if itemA.s == itemBForFinHub {
                                            self.resultsF[indexB].index = itemA.p
                                            self.dict["Key"] = self.resultsF
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WebsocketDataUpdate"), object: nil, userInfo: self.dict)
                                            
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
                        for i in tableView {
                            i.reloadData()
                        }
                        collectionView.reloadData()
                        
                    }
                    self.receiveMessage(tableView: tableView, collectionView: collectionView)
                }
            }
        }
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
