//
//  WebSocketManager.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 25.02.2021.
//
import Foundation
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
//    var coinCapDict = FullCoinCapList(data: [["":""]])
    var coinCapDict = [[String: String?]]()
    var dict = [String : [Crypto]]()
    let favoriteVC = FavoritesTableViewController()
    var collectionViewSymbols = [String]()
    var collectionViewArray = [Crypto]()
    var websocketArray = [String]()
    
    let groupOne = DispatchGroup()
    let groupTwo = DispatchGroup()
    let groupThree = DispatchGroup()
    let groupFour = DispatchGroup()
    
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
    
    func getData() {
        // GROUP 1
        
        let context = self.getContext()
        let fetchRequest : NSFetchRequest<Favorites> = Favorites.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            
            self.favorites = try context.fetch(fetchRequest)
            
            self.setData()
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    
    
    func setData() {
        DispatchQueue.global().async {
            self.resultsF.removeAll()
            for i in self.favorites {
                if let symbol = i.symbol{
                    
//                    let crypto = Crypto(symbolOfCrypto: symbol, index: 0, closePrice: 0, nameOfCrypto: i.name, descriptionOfCrypto: i.descrtiption, symbolOfTicker: i.symbolOfTicker, id: "", percentString: "")
                    let crypto = Crypto(symbolOfCrypto: symbol, price: "", change: "", nameOfCrypto: i.name, descriptionOfCrypto: i.descrtiption, symbolOfTicker: i.symbolOfTicker, id: "", percent: "")
                    DispatchQueue.global().async(flags: .barrier) {
                        self.symbolsF.append(i.symbol!)
                        self.resultsF.append(crypto)
                        self.websocketArray.append(symbol)
                    }
                    
//                    self.putFinHubData(symbol: symbol, group: self.groupTwo)
                    
                }
            }
        }
    }
    
//    func getTopOfCrypto(){
//
//        // GROUP 1
//        print("group 1 enter")
//        DispatchQueue.global().async {
//            self.groupOne.enter()
//
//            let request = NSMutableURLRequest(
//                url: NSURL(string: "https://min-api.cryptocompare.com/data/top/totalvolfull?limit=20&tsym=USD")! as URL,
//                cachePolicy: .useProtocolCachePolicy,
//                timeoutInterval: 10.0)
//            request.httpMethod = "GET"
//            self.groupOne.enter()
//            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
//                self.groupOne.leave()
//                guard let stocksData = data, error == nil, response != nil else {return}
//
//                do {
//                    guard let stocksData = try (Toplist.decode(from: stocksData))?.data else {return}
//
//                    for i in 0..<(stocksData.count) {
//                        self.groupOne.enter()
//                        let elem = stocksData[i]
//                        guard let cryptoCompareName = elem.coinInfo!.name else {return}
//
//
//                        if cryptoCompareName != "USDT" && cryptoCompareName != "BNBBEAR" {
//                            guard let cryptoCompareFullName = elem.coinInfo!.fullName else {return}
//                            let id = cryptoCompareFullName.replacingOccurrences(of: " ", with: "-").lowercased()
//                            let crypto = Crypto(symbolOfCrypto: cryptoCompareName, price: "", change: "", nameOfCrypto: cryptoCompareFullName, descriptionOfCrypto: nil, symbolOfTicker: "\(cryptoCompareName)USDT", id: id, percent: "")
////                            DispatchQueue.global().async(flags: .barrier) {
//                                self.groupOne.enter()
//                                self.results.append(crypto)
//                                self.websocketArray.append(cryptoCompareName)
//                                self.symbols.append(cryptoCompareName)
//                                self.groupOne.leave()
//
////                            }
//
////                            self.putFinHubData(symbol: cryptoCompareName, group: self.groupTwo)
//                        }
//                        self.groupOne.leave()
//                    }
//
//                } catch let error as NSError {
//                    print(error.localizedDescription)
//                }
//
//            }.resume()
//
//            self.groupOne.leave()
//        }
//        print("group 1 leave")
//    }
    func getTopOfCrypto(){
        
        // GROUP 1
        print("group 1 enter")
        DispatchQueue.global().async(group: groupOne) {

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
                        guard let cryptoCompareName = elem.coinInfo!.name else {return}
                        
    
                        if cryptoCompareName != "USDT" && cryptoCompareName != "BNBBEAR" {
                            guard let cryptoCompareFullName = elem.coinInfo!.fullName else {return}
                            let id = cryptoCompareFullName.replacingOccurrences(of: " ", with: "-").lowercased()
                            let crypto = Crypto(symbolOfCrypto: cryptoCompareName, price: "", change: "", nameOfCrypto: cryptoCompareFullName, descriptionOfCrypto: nil, symbolOfTicker: "\(cryptoCompareName)USDT", id: id, percent: "")
//                            DispatchQueue.global().async(flags: .barrier) {
                                
                                self.results.append(crypto)
                                self.websocketArray.append(cryptoCompareName)
                                self.symbols.append(cryptoCompareName)
                                
                                
//                            }
                            
//                            self.putFinHubData(symbol: cryptoCompareName, group: self.groupTwo)
                        }
                        
                    }
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
            }.resume()
            
        }
        print("group 1 leave")
    }
//    func getFullListOfCoinGecko(){
//
//        // GROUP 1
//        print("group 1 enter")
//        DispatchQueue.global().async {
//            self.groupOne.enter()
//            let request = NSMutableURLRequest(
//                url: NSURL(string: "https://api.coingecko.com/api/v3/coins/list")! as URL,
//                cachePolicy: .useProtocolCachePolicy,
//                timeoutInterval: 10.0)
//            request.httpMethod = "GET"
//            self.groupOne.enter()
//            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
//            self.groupOne.leave()
//                guard let stocksData = data, error == nil, response != nil else {return}
//
//                do {
//                    guard let stocks = try GeckoList.decode(from: stocksData) else {return}
//                    DispatchQueue.global().async(flags: .barrier) {
//                        self.groupOne.enter()
//                        self.coinGecoList = stocks
//                        print("CoinGeckoList", self.coinGecoList.count)
//                        self.quickSortForCoinGecko(&self.coinGecoList, start: 0, end: self.coinGecoList.count)
//
//                        self.groupOne.leave()
//                    }
//
//                } catch let error as NSError {
//                    print(error.localizedDescription)
//                }
//
//            }.resume()
//            self.groupOne.leave()
//        }
//        print("group 1 leave")
//    }
    func getFullListOfCoinGecko(){
        
        // GROUP 1
        print("group 1 enter")
        DispatchQueue.global().async(group: groupOne) {
            
            let request = NSMutableURLRequest(
                url: NSURL(string: "https://api.coingecko.com/api/v3/coins/list")! as URL,
                cachePolicy: .useProtocolCachePolicy,
                timeoutInterval: 10.0)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
                guard let stocksData = data, error == nil, response != nil else {return}
                
                do {
                    guard let stocks = try GeckoList.decode(from: stocksData) else {return}
                    DispatchQueue.global().async(group : self.groupOne, flags: .barrier) {
                        self.coinGecoList = stocks
                        print("CoinGeckoList", self.coinGecoList.count)
                        self.quickSortForCoinGecko(&self.coinGecoList, start: 0, end: self.coinGecoList.count)
                        DispatchQueue.global().async(){
                        self.putCoinGeckoData(array: &self.results, group: self.groupTwo)
//                            self.collectionViewLoad(coinCapDict: self.coinCapDict)
                        }
                    }
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
            }.resume()
            
        }
        print("group 1 leave")
    }
//    func getFullCoinCapList() {
//
//        // GROUP 1
//        print("group 1 enter")
//        DispatchQueue.global().async {
//            self.groupOne.enter()
//            let request = NSMutableURLRequest(
//                url: NSURL(string: "https://api.coincap.io/v2/assets?limit=700")! as URL,
//                cachePolicy: .useProtocolCachePolicy,
//                timeoutInterval: 10.0)
//            request.httpMethod = "GET"
//
//            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
//                self.groupOne.enter()
//                guard let stocksData = data, error == nil, response != nil else {return}
//                do {
//                    // Дождаться заполнения результатов
//                    guard let elems = try FullCoinCapList.decode(from: stocksData) else {return}
//                    DispatchQueue.global().async(flags: .barrier) {
//                        self.groupOne.enter()
//                        self.coinCapDict = elems.data!
//                        self.groupOne.leave()
//                        print("Array of Results before",self.results.count )
//                        print("Coin Cap dict before", self.coinCapDict.count)
//                    }
//
//
//
//                } catch let error as NSError {
//                    print(error.localizedDescription)
//                }
//                self.groupOne.leave()
//            }.resume()
//
//            self.groupOne.leave()
//        }
//        print("group 1 leave")
//    }
    func getFullCoinCapList() {
        
        // GROUP 1
        print("group 1 enter")
        DispatchQueue.global().async(group: groupOne) {
            let request = NSMutableURLRequest(
                url: NSURL(string: "https://api.coincap.io/v2/assets?limit=700")! as URL,
                cachePolicy: .useProtocolCachePolicy,
                timeoutInterval: 10.0)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in

                guard let stocksData = data, error == nil, response != nil else {return}
                do {
                    // Дождаться заполнения результатов
                    guard let elems = try FullCoinCapList.decode(from: stocksData) else {return}
                    DispatchQueue.global().async(group: self.groupOne, flags: .barrier) {
                        
                        self.coinCapDict = elems.data!
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
            }.resume()
        }
        print("group 1 leave")
    }
    
    let testGroup = DispatchGroup()
    
    
    func coinCap2(arrayOfResults : [Crypto], elems : [[String: String?]]) {
        // GROUP 2
//        groupOne.wait()
        print("Enter array", arrayOfResults.count)
        print("Enter elems", coinCapDict.count)
        DispatchQueue.global().async {
            self.groupTwo.enter()
        for i in arrayOfResults {
            self.groupTwo.enter()
            print("I", i.symbolOfCrypto)
            for j in elems {
                if i.symbolOfCrypto == j["symbol"] {
                    DispatchQueue.global().async(flags: .barrier) {
                        self.groupTwo.enter()
                        i.nameOfCrypto = j["name"]!
                        i.price = j["priceUsd"]!!
                        i.percent = j["changePercent24Hr"]!
                        print("Symbol",i.symbolOfCrypto,"Percent", i.percent)
                        self.groupTwo.leave()
                    }
                }
            }
            self.groupTwo.leave()
        }
            self.groupTwo.leave()
        }
            
    }
    
    func coinCap2Run() {
        groupOne.wait()
//        groupTwo.enter()
        DispatchQueue.global().async(flags: .barrier) { [self] in
        coinCap2(arrayOfResults: NetworkManager.shared.results, elems: coinCapDict)
        coinCap2(arrayOfResults: NetworkManager.shared.resultsF, elems: coinCapDict)
        }
//        groupTwo.leave()
    }
    
    func getFinHubData(symbol : String, interval : String = "day", group: DispatchGroup, complition : @escaping ([String : Any])->()){
        
        DispatchQueue.global().async(group: group) {
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
        
    }
    
    func getCoinGeckoData(symbol: String, group: DispatchGroup, complition : @escaping (GeckoSymbol)->()) {
        DispatchQueue.global().async {
            group.enter()
//            group.enter()
            let request = NSMutableURLRequest(
                url: NSURL(string: "https://api.coingecko.com/api/v3/coins/\(symbol)?localization=false&tickers=false&market_data=false&community_data=true&developer_data=false&sparkline=false")! as URL,
                cachePolicy: .useProtocolCachePolicy,
                timeoutInterval: 10.0)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                
                guard let stocksData = data, error == nil, response != nil else {return}
                
                do {
                    group.enter()
                    if let stocks = try GeckoSymbol.decode(from: stocksData) {
                        complition(stocks)
                    }
                    group.leave()
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }.resume()
            group.leave()
        }
    }
    
 
    
    func putCoinGeckoData(array : inout [Crypto], group: DispatchGroup) {

        // GROUP 2
        groupOne.wait()
//                DispatchQueue.global().sync {
        for i in array {
            DispatchQueue.global().async(group: group) {
                self.groupOne.wait()
                let symbol = i.symbolOfCrypto
                let indexOfSymbol = self.binarySearchFoCoinGeckoList(key: symbol.lowercased(), list: self.coinGecoList)
//                print("SYMBOL:", symbol, "INDEX", indexOfSymbol)
                print("CCC", self.coinGecoList.count)
                self.getCoinGeckoData(symbol: self.coinGecoList[indexOfSymbol!].id!, group: group) { (stocks) in
                    DispatchQueue.global().async(group: group, flags: .barrier) {
                        i.descriptionOfCrypto = stocks.geckoSymbolDescription?.en

                    }
                }
            }
        }
    }
  
    
    
    
    func getFullBinanceList() {
        // GROUP 2
        DispatchQueue.global().async {
            self.groupOne.enter()
            print("getFullBinanceList groupOne in ")
            let request = NSMutableURLRequest(
                url: NSURL(string: "https://finnhub.io/api/v1/crypto/symbol?exchange=binance&token=c12ev3748v6oi252n1fg")! as URL,
                cachePolicy: .useProtocolCachePolicy,
                timeoutInterval: 10.0)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                guard let stocksData = data, error == nil, response != nil else {return}
                
                self.groupOne.leave()
                self.groupOne.wait()
                
                do {
                    //                    self.groupTwo.enter()
                    guard let elems = try FullBinanceList.decode(from: stocksData) else {return}
                    
                    for i in elems {
                        self.groupTwo.enter()
                        let secondElementOfSymbol = i.displaySymbol?.split(separator: "/")[1]
                        let firstElementOfSymbol = i.displaySymbol?.split(separator: "/").first
                        let symbolOfFinHubList = String((i.displaySymbol?.split(separator: "/").first)!)
                        
                        let indexOfGeckoList = self.binarySearchFoCoinGeckoList(key: symbolOfFinHubList.lowercased(), list: self.coinGecoList)
                        
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
                                DispatchQueue.global().async(flags: .barrier) {
                                    self.groupTwo.enter()
                                    self.fullBinanceList.append(elem)
                                    self.groupTwo.leave()
                                }
                            }
                        }
                        self.groupTwo.leave()
                    }
                    
                    self.fullBinanceList.sort{$0.rank ?? 101 < $1.rank ?? 101}
                    //                    self.groupTwo.leave()
                    
                    
                    //                self.collectionViewLoad()
                    
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }.resume()
        }
        
    }
    let queue = DispatchQueue(label: "123", qos: .userInitiated)
    
    func collectionViewLoad(coinCapDict : [[String : String?]]) {

        // GROUP 3
        groupOne.wait()
        groupTwo.wait()
        // Если элемент есть уже в результатах для tableview, не делать запрос, добавлять этот элемент
//        self.groupThree.enter()
        DispatchQueue.global().async{
            self.groupOne.wait()
            self.groupTwo.wait()
            for index in 0..<15 {
                self.groupThree.enter()
                let elemOfCoinCap = coinCapDict[index]

                if elemOfCoinCap["symbol"]!! != "USDT" {
                self.queue.async {
                    self.groupThree.enter()
                    let crypto = Crypto(symbolOfCrypto: elemOfCoinCap["symbol"]!!, price: elemOfCoinCap["priceUsd"]!!, change: "change", nameOfCrypto: elemOfCoinCap["name"]!, descriptionOfCrypto: "descriptionOfCrypto", symbolOfTicker: "symbolOfTicker", id: elemOfCoinCap["id"]!, percent: elemOfCoinCap["changePercent24Hr"]!)
                    self.collectionViewArray.append(crypto)
                    self.websocketArray.append(elemOfCoinCap["symbol"]!!)
                    if index == 15 {
                        DispatchQueue.global().sync {
                            self.putCoinGeckoData(array: &self.collectionViewArray, group: self.groupFour)
                        }
                    }
                    self.groupThree.leave()
                }

            }
            self.groupThree.leave()

        }
            self.groupThree.wait()
//            DispatchQueue.global().sync {
//                self.putCoinGeckoData(array: &self.collectionViewArray, group: self.groupFour)
//            }
        }
//        self.groupThree.leave()
    }
//        func collectionViewLoad(coinCapDict : [[String : String?]]) {
//
//            // GROUP 3
//            groupOne.wait()
//            groupTwo.wait()
//            // Если элемент есть уже в результатах для tableview, не делать запрос, добавлять этот элемент
//    //        self.groupThree.enter()
//            queue.async{
//                self.groupOne.wait()
//                self.groupTwo.wait()
//                for index in 0..<15 {
//                    self.groupThree.enter()
//
//                    let elemOfCoinCap = coinCapDict[index]
//
//                    if elemOfCoinCap["symbol"]!! != "USDT" {
////                    self.queue.async {
//                        self.groupThree.enter()
//                        let crypto = Crypto(symbolOfCrypto: elemOfCoinCap["symbol"]!!, price: elemOfCoinCap["priceUsd"]!!, change: "change", nameOfCrypto: elemOfCoinCap["name"]!, descriptionOfCrypto: "descriptionOfCrypto", symbolOfTicker: "symbolOfTicker", id: elemOfCoinCap["id"]!, percent: elemOfCoinCap["changePercent24Hr"]!)
//                        self.collectionViewArray.append(crypto)
//                        self.websocketArray.append(elemOfCoinCap["symbol"]!!)
//                        self.groupThree.leave()
////                    }
//
//                }
//                self.groupThree.leave()
//
//            }
//                self.groupThree.wait()
//                self.queue.async {
//                    self.putCoinGeckoData(array: &self.collectionViewArray, group: self.groupFour)
//                }
//            }
//    //        self.groupThree.leave()
//        }
//    func collectionViewLoad(coinCapDict : [[String : String?]]) {
//
//        // GROUP 3
//
//        // Если элемент есть уже в результатах для tableview, не делать запрос, добавлять этот элемент
////        self.groupThree.enter()
//        queue.async(group: groupThree ){
//            self.groupOne.wait()
//            self.groupTwo.wait()
//            for index in 0..<15 {
//                let elemOfCoinCap = coinCapDict[index]
//
//                if elemOfCoinCap["symbol"]!! != "USDT" {
//
////                    self.queue.async(group: self.groupThree, flags: .barrier) {
//                    let crypto = Crypto(symbolOfCrypto: elemOfCoinCap["symbol"]!!, price: elemOfCoinCap["priceUsd"]!!, change: "change", nameOfCrypto: elemOfCoinCap["name"]!, descriptionOfCrypto: "descriptionOfCrypto", symbolOfTicker: "symbolOfTicker", id: elemOfCoinCap["id"]!, percent: elemOfCoinCap["changePercent24Hr"]!)
//
//                    self.collectionViewArray.append(crypto)
//                    self.websocketArray.append(elemOfCoinCap["symbol"]!!)
////                }
//            }
//            }
//        }
//
//        queue.async(){
//            self.groupOne.wait()
//            self.groupTwo.wait()
//            self.groupThree.wait()
//            self.putCoinGeckoData(array: &self.collectionViewArray, group: self.groupFour)
//        }
//        }
////        self.groupThree.leave()
////    }
    

    
    
    func updateUI(tableViews : [UITableView], collectionViews : [UICollectionView]){
        groupOne.wait()
        groupTwo.wait()
        groupThree.wait()
        groupFour.wait()
        
        DispatchQueue.main.async {
//            print("UPDATE UI")
            for i in tableViews {
                i.reloadData()
            }
            for i in collectionViews {
                i.reloadData()
            }
        }
        
    }
    
    // WEBSOCKET
    
    
    let webSocketTask = URLSession(configuration: .default).webSocketTask(with: URL(string: "wss://ws.finnhub.io?token=c12ev3748v6oi252n1fg")!)
    
    func webSocket(symbols : [String], symbolsF : [String]) {
        DispatchQueue.global().async {
            
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
        self.groupOne.wait()
        self.groupTwo.wait()
        DispatchQueue.global().async {
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
        DispatchQueue.global().async(qos: .utility) {
            self.webSocketTask.sendPing { error in
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
    }
    
    
    func receiveMessage(tableView : [UITableView], collectionView : [UICollectionView]) {
        self.groupOne.wait()
        self.groupTwo.wait()
        DispatchQueue.global().async {
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
                                self.putDataFromWebSocket(tickData: tickData, array: self.collectionViewArray)
                                self.putDataFromWebSocket(tickData: tickData, array: self.results)
                                self.putDataFromWebSocket(tickData: tickData, array: self.resultsF, isFavorite: true)
                                
                            }
                        }
                        
                    case .data(let data):
                        print("Received data: \(data)")
                    @unknown default:
                        fatalError()
                    }
                    
                    self.updateUI(tableViews: tableView, collectionViews: collectionView)
                    self.receiveMessage(tableView: tableView, collectionView: collectionView)
                }
            }
        }
    }
    
    
    func putDataFromWebSocket (tickData : [Datum], array : [Crypto], isFavorite : Bool = false) {
//            DispatchQueue.global().async {
            for itemA in tickData {
                for (indexB,itemB) in array.enumerated() {
                    let itemBForFinHub = "BINANCE:\(itemB.symbolOfCrypto.uppercased())USDT"
                    if itemA.s == itemBForFinHub {
                        DispatchQueue.global().async(flags: .barrier) {
//                            array[indexB].index = itemA.p
                            array[indexB].price = String(itemA.p)
                        }
                        if isFavorite {
                            self.dict["Key"] = self.resultsF
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WebsocketDataUpdate"), object: nil, userInfo: self.dict)
                        }
                    }
                }
            }
//        }
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
