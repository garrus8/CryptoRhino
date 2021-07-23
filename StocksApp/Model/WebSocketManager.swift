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
    
    var sections = [SectionOfCrypto]()
    var searchSections = [SectionOfCrypto]()
    var imageCache = NSCache<NSString,UIImage>()
    let finHubToken = Constants.finHubToken
    var results = [Crypto]()
    var symbols = [String]()
    var coinGecoList = [GeckoListElement]()
    var favorites = [Favorites]()
    var resultsF = [Crypto]()
    var symbolsF = [String]()
    var fullBinanceList = [FullBinanceListElement]()
    //    var fullBinanceList = [Crypto]()
    //    var coinCapDict = FullCoinCapList(data: [["":""]])
    var coinCapDict = [[String: String?]]()
    var dict = [String : [Crypto]]()
//    let favoriteVC = FavoritesViewController()
    var collectionViewSymbols = [String]()
    var collectionViewArray = [Crypto]()
    var websocketArray = [String]()
    
    let queue = DispatchQueue(label: "123", qos: .userInitiated)
    
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
        DispatchQueue.global().async(group: groupTwo) {
            self.resultsF.removeAll()
            for i in self.favorites {
                if let symbol = i.symbol{
                    let crypto = Crypto(symbolOfCrypto: symbol, nameOfCrypto: i.name!, descriptionOfCrypto: i.descrtiption!, symbolOfTicker: i.symbolOfTicker!, image: UIImage(named: "pngwing.com")!)
                    DispatchQueue.global().async(flags: .barrier) {
                        self.symbolsF.append(i.symbol!)
                        self.resultsF.append(crypto)
                        self.websocketArray.append(symbol)
                    }
                }
            }
        }
    }

    func addData(object : Favorites) {
        
            if let symbol = object.symbol {
                let crypto = Crypto(symbolOfCrypto: symbol, nameOfCrypto: object.name!, descriptionOfCrypto: object.descrtiption!, symbolOfTicker: object.symbolOfTicker!, image: UIImage(named: "pngwing.com")!)
                for j in coinCapDict {
                    if symbol == j["symbol"] {
                        DispatchQueue.global().async(flags: .barrier) {
                            crypto.price = j["priceUsd"]!!
                            crypto.percent = j["changePercent24Hr"]!
                        }
                    }
                }

                    DispatchQueue.global().async(flags: .barrier) {
                        self.symbolsF.insert(object.symbol!, at: 0)
                        self.resultsF.insert(crypto, at: 0)
                        self.websocketArray.append(symbol)
                        self.putCoinGeckoData(array: &self.resultsF, group: self.groupTwo, isFavorites: true)
                    }
            }
        }
    

    
    func getTopOfCrypto(){
        
        // GROUP 1
        
        DispatchQueue.global().async(group: groupOne) {
            
            let request = NSMutableURLRequest(
                url: NSURL(string: "https://min-api.cryptocompare.com/data/top/totalvolfull?limit=20&tsym=USD")! as URL,
                cachePolicy: .useProtocolCachePolicy,
                timeoutInterval: 10.0)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                DispatchQueue.global().async(group: self.groupOne) {
                guard let stocksData = data, error == nil, response != nil else {return}
                
                do {
                    guard let stocksData = try (Toplist.decode(from: stocksData))?.data else {return}
                    
                    for i in 0..<(stocksData.count) {
                        
                        let elem = stocksData[i]
                        guard let cryptoCompareName = elem.coinInfo!.name else {return}
                        
                        
                        if cryptoCompareName != "USDT" && cryptoCompareName != "BNBBEAR" {
                            guard let cryptoCompareFullName = elem.coinInfo!.fullName else {return}
                            let id = cryptoCompareFullName.replacingOccurrences(of: " ", with: "-").lowercased()
                            let crypto = Crypto(symbolOfCrypto: cryptoCompareName, price: "", change: "", nameOfCrypto: cryptoCompareFullName, descriptionOfCrypto: nil, symbolOfTicker: "\(cryptoCompareName)USDT", id: id, percent: "", image: UIImage(named: "pngwing.com")!)
                            
                            self.queue.async(group : self.groupOne, flags : .barrier) {
                            self.results.append(crypto)
                            print("RESULSTS ADDED", self.results.count)
                            self.websocketArray.append(cryptoCompareName)
                                print(self.websocketArray)
                            self.symbols.append(cryptoCompareName)
                            }
                        }
                    }
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
            }
            }.resume()
        }
        
    }
    
    func getFullListOfCoinGecko(){
        
        // GROUP 1
        
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
                        
                        if self.coinGecoList.isEmpty {
                            // Вывести вью с лейблом: Вы превысили количество запросов, пожалуйста попробуйте через минуту
                        }
                        
                        self.quickSortForCoinGecko(&self.coinGecoList, start: 0, end: self.coinGecoList.count)
//                        self.filterForCoinGecko(&self.coinGecoList)
                        self.coinGecoList.removeAll{ $0.id!.contains("binance-peg")}
                        DispatchQueue.global().async(flags: .barrier) {
                            self.putCoinGeckoData(array: &self.results, group: self.groupTwo, isFavorites: false)
                            self.putCoinGeckoData(array: &self.resultsF, group: self.groupTwo, isFavorites: true)
                            
                        }
                    }
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
            }.resume()
            
        }
        
    }
    
    func getFullCoinCapList() {
        
        // GROUP 1
        
        queue.sync {
            groupOne.enter()
            let request = NSMutableURLRequest(
                url: NSURL(string: "https://api.coincap.io/v2/assets?limit=500")! as URL,
                cachePolicy: .useProtocolCachePolicy,
                timeoutInterval: 10.0)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                guard let stocksData = data, error == nil, response != nil else {return}
                self.groupOne.enter()
                do {

                    guard let elems = try FullCoinCapList.decode(from: stocksData) else {return}
                    
//                    self.queue.async(group: self.groupOne, flags: .barrier) {
                        self.coinCapDict = elems.data!
//                    }
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                self.groupOne.leave()
            }.resume()
            groupOne.leave()
        }
    }
    
    let testGroup = DispatchGroup()
    
    
    func coinCap2(arrayOfResults :  [Crypto], elems : [[String: String?]]) {
        // GROUP 2
        DispatchQueue.global().async(group : groupTwo) {
            for i in arrayOfResults {
                for j in elems {
                    if i.symbolOfCrypto == j["symbol"] {
                        
                        DispatchQueue.global().async(flags: .barrier) {
                            i.nameOfCrypto = j["name"]!
                            let priceDouble = Double(j["priceUsd"]!!)
                            i.price = String(round(priceDouble! * 100) / 100.0)
                            if let percent = j["changePercent24Hr"] {
                                if let percentDouble = Double(percent ?? "") {
                                    i.percent = String(round(percentDouble * 10) / 10)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func coinCap2Run() {
        groupOne.wait()
        DispatchQueue.global().async(flags: .barrier) { [self] in
            coinCap2(arrayOfResults: NetworkManager.shared.results, elems: coinCapDict)
            coinCap2(arrayOfResults: NetworkManager.shared.resultsF, elems: coinCapDict)
        }
    }
    
    func getFinHubData(symbol : String, interval : String = "day", group: DispatchGroup, complition : @escaping ([String : Any])->()){
        
        DispatchQueue.global().async(group: group) {
            let symbolForFinHub = "BINANCE:\(symbol)USDT"
            
            // Вынести все юниксы в константы в другой файл
            let prevDayUnix = Int((Calendar.current.date(byAdding: .hour, value: -25, to: Date()))!.timeIntervalSince1970)
            let prevMonthUnix = Int((Calendar.current.date(byAdding: .day, value: -21, to: Date()))!.timeIntervalSince1970)
            let prevYearUnix = Int((Calendar.current.date(byAdding: .month, value: -12, to: Date()))!.timeIntervalSince1970)
            let prevWeekUnix = Int((Calendar.current.date(byAdding: .day, value: -7, to: Date()))!.timeIntervalSince1970)
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
            case "week":
                dateFormat = "dd.MM.yy"
                prevValue = prevWeekUnix
                resolution = "60"
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
        
        DispatchQueue.global().async(group : group) {
            

            let request = NSMutableURLRequest(
                url: NSURL(string: "https://api.coingecko.com/api/v3/coins/\(symbol)?localization=false&tickers=false&market_data=true&community_data=true&developer_data=false&sparkline=false")! as URL,
                cachePolicy: .useProtocolCachePolicy,
                timeoutInterval: 10.0)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                
                guard let stocksData = data, error == nil, response != nil else {return}
                
                do {
                    

                    if let stocks = try GeckoSymbol.decode(from: stocksData) {
                        
                        complition(stocks)
                    }

                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }.resume()

        }
    }
    
    
    
    func putCoinGeckoData(array : inout [Crypto], group: DispatchGroup, isFavorites : Bool) {
        
        // GROUP 2
        groupOne.wait()
        let countArray = array.count
        var countIterations = 0
        for i in array {
            DispatchQueue.global().async(group: group) {
                self.groupOne.wait()
                let symbol = i.symbolOfCrypto
                var indexOfSymbol: Int?
                DispatchQueue.global().sync {
                     indexOfSymbol = self.binarySearchFoCoinGeckoList(key: symbol.lowercased(), list: self.coinGecoList)
                    
                }
//                let symbolCoinGecko = self.coinGecoList[indexOfSymbol!].id!.replacingOccurrences(of: "binance-peg-", with: "")
                let symbolCoinGecko = self.coinGecoList[indexOfSymbol!].id!
                print("SYMBOLOFCG", symbolCoinGecko)
                self.getCoinGeckoData(symbol: symbolCoinGecko, group: group) { (stocks) in
                    DispatchQueue.global().async(group: group, flags: .barrier) {
                        
                        if let stringUrl = stocks.image?.large {
                        self.obtainImage(StringUrl: stringUrl) { image in
                            i.image = image
                            i.imageString = (stocks.image?.large)!
                            countIterations += 1
                            if countIterations == countArray - 1 && !isFavorites {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newImage"), object: nil)
                            }
                        }
                        }
                        
                        i.descriptionOfCrypto = stocks.geckoSymbolDescription?.en
                        i.links = stocks.links
                        guard let marketData = stocks.marketData else {return}
                        i.marketDataArray = MarketDataArray(marketData: marketData)
                        guard let communityData = stocks.communityData else {return}
                        i.communityDataArray = CommunityDataArray(communityData: communityData)
                        
                        
                    }
                }
            }
        }
    }
    
    func obtainImage(StringUrl : String, complition : @escaping ((UIImage) -> Void) ) {
        
        DispatchQueue.global().async {
            if let cachedImage = self.imageCache.object(forKey: StringUrl as NSString) {
            complition(cachedImage)
        } else {
            
            guard let url = URL(string: StringUrl) else {return}
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, response != nil, error == nil else {return}
                guard let image = UIImage(data: data) else {return}
                self.imageCache.setObject(image, forKey: StringUrl as NSString)
                complition(image)
                
            }.resume()
        }
        }
    }
    
    
    func getFullBinanceList() {
        // GROUP 2
        DispatchQueue.global().async(){
            self.groupOne.enter()
            
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
                    
                    guard let elems = try FullBinanceList.decode(from: stocksData) else {return}
                    
                    for i in elems {
                        self.groupTwo.enter()
                        let secondElementOfSymbol = i.displaySymbol?.split(separator: "/")[1]
                        let firstElementOfSymbol = i.displaySymbol?.split(separator: "/").first
                        let symbolOfFinHubList = String((i.displaySymbol?.split(separator: "/").first)!)
                        var coinGeckoListCopy : [GeckoListElement]?
                      
                        DispatchQueue.global().sync {
                            coinGeckoListCopy = self.coinGecoList
                        }
                        let indexOfGeckoList = self.binarySearchFoCoinGeckoList(key: symbolOfFinHubList.lowercased(), list: coinGeckoListCopy!)
                        
                        if secondElementOfSymbol == "USDT" {
                            if indexOfGeckoList != nil {
                                
//                                let name = coinGeckoListCopy![indexOfGeckoList!].name!.replacingOccurrences(of: "Binance-Peg", with: "")
                                let name = coinGeckoListCopy![indexOfGeckoList!].name!
                                let displaySymbol = coinGeckoListCopy![indexOfGeckoList!].symbol?.uppercased()
                                var rank = 101
                                let id = coinGeckoListCopy![indexOfGeckoList!].id
                                
                                for j in self.coinCapDict {
                                    if j["symbol"]!! == firstElementOfSymbol! {
                                        rank = Int(j["rank"]!!)!
                                    }
                                }
                                let elem = FullBinanceListElement(fullBinanceListDescription: name, displaySymbol: displaySymbol, symbol: i.symbol, id : id, rank: rank)
                                
                                DispatchQueue.global().async(flags : .barrier) {
                                self.groupTwo.enter()
                                self.fullBinanceList.append(elem)
                                self.groupTwo.leave()
                                }
                            }
                        }
                        self.groupTwo.leave()
                    }
                    
                    self.fullBinanceList.sort{$0.rank ?? 101 < $1.rank ?? 101}
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }.resume()
        }
        
    }
    
    
    func collectionViewLoad() {
        
        // GROUP 3
        groupOne.wait()
        groupTwo.wait()
        // Если элемент есть уже в результатах для tableview, не делать запрос, добавлять этот элемент
        
        queue.sync() {
            for index in 0..<15 {
//                self.groupOne.wait()
//                self.groupTwo.wait()
                let elemOfCoinCap = self.coinCapDict[index]
                
                let priceDouble = Double(elemOfCoinCap["priceUsd"]!!)
                let price = String(round(priceDouble! * 100) / 100.0)
                let percentDouble = Double(elemOfCoinCap["changePercent24Hr"]!!)
                let percent = String(round(percentDouble! * 10) / 10)
                
                if elemOfCoinCap["symbol"]!! != "USDT" {
                    let crypto = Crypto(symbolOfCrypto: elemOfCoinCap["symbol"]!!, price: price, change: "change", nameOfCrypto: elemOfCoinCap["name"]!, descriptionOfCrypto: "descriptionOfCrypto", symbolOfTicker: "symbolOfTicker", id: elemOfCoinCap["id"]!, percent: percent, image: UIImage(named: "pngwing.com")!)
                    
                    queue.async(group : self.groupFour, flags : .barrier) {
                        self.collectionViewArray.append(crypto)
                        self.websocketArray.append(elemOfCoinCap["symbol"]!!)
                    }
                    if index == 14 {
                        self.groupOne.wait()
                        self.putCoinGeckoData(array: &self.collectionViewArray, group: self.groupThree, isFavorites: false)
                    }
                }
            }
        }
    }
    
    func updateUI(tableViews : [UITableView], collectionViews: [UICollectionView]){
        groupOne.wait()
        groupTwo.wait()
        groupThree.wait()
        groupFour.wait()
        print("updateUI")
        DispatchQueue.main.async {
            for i in tableViews {
                i.reloadData()
            }
            for i in collectionViews {
                i.reloadData()
            }
        }
    }
    func recoursiveUpdateUI(tableViews : [UITableView], collectionViews: [UICollectionView]){
        updateUI(tableViews: tableViews, collectionViews: collectionViews)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.recoursiveUpdateUI(tableViews: tableViews, collectionViews: collectionViews)
        }
    }
    let groupSetupSections = DispatchGroup()
    
    func setupSections() {
        
        groupOne.wait()
        groupTwo.wait()
        groupThree.wait()
        groupFour.wait()
        
        DispatchQueue.global().async(group : groupSetupSections, flags: .barrier) {
            let carousel = SectionOfCrypto(type: "carousel", title: "Top", items: self.collectionViewArray)
            let table = SectionOfCrypto(type: "table", title: "Hot", items: self.results)
            self.sections = [carousel,table]
            
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
                        array[indexB].price = String(itemA.p)
                    }
//                    if isFavorite {
//                        self.dict["Key"] = self.resultsF
//                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WebsocketDataUpdate"), object: nil, userInfo: self.dict)
//                    }
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
