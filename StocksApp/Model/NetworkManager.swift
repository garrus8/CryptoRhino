//
//  WebSocketManager.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 25.02.2021.
//
import Foundation
import UIKit
//import CoreData
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
    
    //    var sections = [SectionOfCrypto]()
    //    var searchSections = [SectionOfCrypto]()
    //    var imageCache = NSCache<NSString,UIImage>()
    //    let finHubToken = Constants.finHubToken
    //    var results = [Crypto]()
    //    var symbols = [String]()
    //    var coinGecoList = [GeckoListElement]()
    //    var favorites = [Favorites]()
    //    var resultsF = [Crypto]()
    //    var symbolsF = [String]()
    //    var fullBinanceList = GeckoList()
    //    var topList = [TopSearchItem]()
    //    var coinCapDict = [[String: String?]]()
    //    var dict = [String : [Crypto]]()
    //    var collectionViewSymbols = [String]()
    //    var collectionViewArray = [Crypto]()
    //    var websocketArray = [String]()
    
    let queue = DispatchQueue(label: "123", qos: .userInitiated)
    
//    let groupOne = DispatchGroup()
//    let groupTwo = DispatchGroup()
//    let groupThree = DispatchGroup()
//    let groupFour = DispatchGroup()
    
//    static let shared = NetworkManager()
//    private init() {}
    
//    private func getContext () -> NSManagedObjectContext {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        return appDelegate.persistentContainer.viewContext
//    }
    
//    func deleteAllData() {
//        let context = getContext()
//        let fetchRequest : NSFetchRequest<Favorites> = Favorites.fetchRequest()
//        if let objects = try? context.fetch(fetchRequest) {
//            for object in objects {
//                context.delete(object)
//            }
//        }
//
//        do {
//            try context.save()
//        } catch let error as NSError {
//            print(error.localizedDescription)
//        }
//    }
    
//    func getData() {
//        // GROUP 1
//        
//        let context = self.getContext()
//        let fetchRequest : NSFetchRequest<Favorites> = Favorites.fetchRequest()
//        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        
//        do {
//            DataSingleton.shared.favorites = try context.fetch(fetchRequest)
//            self.setData()
//            
//        } catch let error as NSError {
//            print(error.localizedDescription)
//        }
//    }
//    
//    
//    func setData() {
//        DispatchQueue.global().async(group: groupOne) {
//            DataSingleton.shared.resultsF.removeAll()
//            DispatchQueue.global().async(flags: .barrier) {
//                for i in DataSingleton.shared.favorites {
//                    if let symbol = i.symbol{
//                        let crypto = Crypto(symbolOfCrypto: symbol, nameOfCrypto: i.name!, descriptionOfCrypto: i.descrtiption!, image: UIImage(named: "pngwing.com")!, percentages: Persentages())
//                        //                    DispatchQueue.global().async(flags: .barrier) {
//                        print("self.resultsF",DataSingleton.shared.resultsF.count)
//                        DataSingleton.shared.symbolsF.append(i.symbol!)
//                        DataSingleton.shared.resultsF.append(crypto)
//                        DataSingleton.shared.websocketArray.append(symbol)
//                        self.dict1[symbol] = 0
//                    }
//                }
//            }
//        }
//    }
//    
//    func addData(object : Favorites) {
//        
//        if let symbol = object.symbol {
//            let crypto = Crypto(symbolOfCrypto: symbol, nameOfCrypto: object.name!, descriptionOfCrypto: object.descrtiption!, image: UIImage(named: "pngwing.com")!, percentages: Persentages())
//            
//            DispatchQueue.global().async(flags: .barrier) {
//                DataSingleton.shared.symbolsF.insert(object.symbol!, at: 0)
//                DataSingleton.shared.resultsF.insert(crypto, at: 0)
//                DataSingleton.shared.websocketArray.append(symbol)
//                self.dict1[symbol] = 0
//                var sub = [DataSingleton.shared.resultsF.first!]
//                //                        self.putCoinGeckoData(array: &self.resultsF, group: self.groupTwo)
//                self.putCoinGeckoData(array: &sub, group: self.groupTwo, otherArray: [])
//                DataSingleton.shared.resultsF[0] = sub.first!
//            }
//        }
//    }
    
    
    var countTopOfCrypto = 0
    func getTopOfCrypto(group : DispatchGroup) {
        
        // GROUP 1
        
        DispatchQueue.global().async(group: group) {
            if self.countTopOfCrypto < 10 {
                group.enter()
                NetworkRequestManager.request(url: Urls.topOfCrypto.rawValue) { data, response, error in
                    guard let stocksData = data, error == nil, response != nil else {
                        self.countTopOfCrypto += 1;
                        self.getTopOfCrypto(group: group);
                        print("getTopOfCrypto 1")
                        group.leave();
                        return}
                    
                    do {
                        guard let stocksData = try (Toplist.decode(from: stocksData))?.data else {
                            self.countTopOfCrypto += 1;
                            self.getTopOfCrypto(group: group);
                            print("getTopOfCrypto 2")
                            group.leave();
                            return}
                        
                        for i in 0..<(stocksData.count) {
                            group.enter()
                            let elem = stocksData[i]
                            
                            guard let cryptoCompareName = elem.coinInfo?.name else { print("getTopOfCrypto 3"); return}
                            
                            if cryptoCompareName != "USDT" && cryptoCompareName != "BNBBEAR" {
                                guard let cryptoCompareFullName = elem.coinInfo?.fullName else {return}
                                let crypto = Crypto(symbolOfCrypto: cryptoCompareName, price: "", change: "", nameOfCrypto: cryptoCompareFullName, descriptionOfCrypto: nil, id: "", percentages: Persentages(), image: UIImage(named: "pngwing.com")!)
                                
                                self.queue.async(group : group, flags : .barrier) {
                                    DataSingleton.shared.dict1[cryptoCompareName] = 0
                                    DataSingleton.shared.results.append(crypto)
                                    print("RESULSTS ADDED", DataSingleton.shared.results.count)
                                    DataSingleton.shared.websocketArray.append(cryptoCompareName)
                                    DataSingleton.shared.symbols.append(cryptoCompareName.uppercased())
                                }
                            }
                            group.leave()
                        }
                        group.leave()
                        
                    } catch let error as NSError {
                        print("getTopOfCrypto 4")
                        print(error.localizedDescription)
                    }
                    
                }
            } else {
                DispatchQueue.main.async() {
                    group.enter()
                    print("getTopOfCrypto 5")
                    let alert = UIAlertController(title: "We have server problems", message: "You can restart the app or try later ", preferredStyle: .alert)
                    alert.show()
                    group.leave()
                }
            }
        }
    }
    
    func getTopSearch(group : DispatchGroup) {
        
        // GROUP 1
        
        DispatchQueue.global().async(group: group) {
            if self.countTopOfCrypto < 10 {
                group.enter()
                NetworkRequestManager.request(url: Urls.topSearch.rawValue) { data, response, error in
                    guard let stocksData = data, error == nil, response != nil else {
                        self.countTopOfCrypto += 1;
                        self.getTopSearch(group: group);
                        group.leave();
                        return}
                    
                    do {
                        guard let data = try (TopSearch.decode(from: stocksData)) else {
                            self.countTopOfCrypto += 1;
                            self.getTopSearch(group: group);
                            group.leave();
                            return}
                        
                        for elem in data.coins {
                            let item = elem.item
                            group.enter()
                            self.obtainImage(StringUrl: item.large, group: DispatchGroups.shared.groupTwo) { image in
                                let crypto = TopSearchItem(id: item.id, name: item.name, symbol: item.symbol, large: image)
                                DataSingleton.shared.topList.append(crypto)
                                group.leave()
                            }
                            
                        }
                        group.leave()
                        
                    } catch let error as NSError {
                        print("getTopOfCrypto 4")
                        print(error.localizedDescription)
                    }
                    
                }
            }
        }
    }
    
    var countOfFullListCoinGecko = 0
    
    func getFullListOfCoinGecko(group : DispatchGroup, waitingGroup : DispatchGroup) {
        
        // GROUP 1
        
        DispatchQueue.global().async(group: group) {
            if self.countOfFullListCoinGecko < 10 {
                group.enter()
                NetworkRequestManager.request(url: Urls.fullListOfCoinGecko.rawValue) { data, response, error in
                    guard let stocksData = data, error == nil, response != nil else {
                        self.countOfFullListCoinGecko += 1;
                        self.getFullListOfCoinGecko(group : group, waitingGroup : waitingGroup);
                        print("getFullListOfCoinGecko 1")
                        group.leave();
                        return}
                    do {
                        guard let stocks = try GeckoList.decode(from: stocksData) else {
                            self.countOfFullListCoinGecko += 1;
                            self.getFullListOfCoinGecko(group : group, waitingGroup : waitingGroup);
                            print("getFullListOfCoinGecko 2")
                            group.leave();
                            return}
                        
                        DispatchQueue.global().async(group : group, flags: .barrier) {
                            
                            DataSingleton.shared.coinGecoList = stocks
                            self.quickSortForCoinGecko(&DataSingleton.shared.coinGecoList, start: 0, end: DataSingleton.shared.coinGecoList.count)
                            DataSingleton.shared.coinGecoList.removeAll{ $0.id!.contains("binance-peg")}
                            
                            waitingGroup.wait()
                            for (index,i) in DataSingleton.shared.coinGecoList.enumerated() {
                                //                            var elem = FullBinanceListElement(fullBinanceListDescription: i.name, displaySymbol: i.symbol?.uppercased(), symbol: i.symbol, id : i.id, rank: 101)
                                var elem = GeckoListElement(id: i.id, symbol: i.symbol?.uppercased(), name: i.name, rank: 101)
                                for j in DataSingleton.shared.coinCapDict {
                                    if j["symbol"]!! == i.symbol?.uppercased() {
                                        elem.rank = Int(j["rank"]!!)!
                                        DataSingleton.shared.coinGecoList[index].rank = Int(j["rank"]!!)!
                                    }
                                }
                                
                                DataSingleton.shared.fullBinanceList.append(elem)
                                
                            }
                            DataSingleton.shared.fullBinanceList.sort{$0.rank ?? 101 < $1.rank ?? 101}
                            group.leave()
                        }
                        
                    } catch let error as NSError {
                        print("getFullListOfCoinGecko 3")
                        print(error.localizedDescription)
                    }
                }
                
            } else {
                DispatchQueue.main.async() {
                    group.enter()
                    let alert = UIAlertController(title: "We have server problems", message: "You can restart the app or try later ", preferredStyle: .alert)
                    alert.show()
                    print("getFullListOfCoinGecko 4")
                    group.leave()
                }
            }
        }
    }
    
    var countOfCoinCap = 0
    func getFullCoinCapList(group : DispatchGroup) {
        
        // GROUP 1
        DispatchQueue.global().async(group: group) {
            if self.countOfCoinCap < 10 {
                group.enter()
                NetworkRequestManager.request(url: Urls.fullCoinCapList.rawValue) { data, response, error in
                    guard let stocksData = data, error == nil, response != nil else {
                        self.countOfCoinCap += 1
                        self.getFullCoinCapList(group: group);
                        group.leave();
                        print("getFullCoinCapList 1")
                        return}
                    do {
                        guard let elems = try FullCoinCapList.decode(from: stocksData) else {
                            self.countOfCoinCap += 1
                            self.getFullCoinCapList(group: group);
                            group.leave()
                            print("getFullCoinCapList 2")
                            return}
                        
                        DataSingleton.shared.coinCapDict = elems.data!
                        group.leave()
                        
                    } catch let error as NSError {
                        print("getFullCoinCapList 3")
                        print(error.localizedDescription)
                    }
                    
                }
            } else {
                DispatchQueue.main.async() {
                    group.enter()
                    let alert = UIAlertController(title: "We have server problems", message: "You can restart the app or try later ", preferredStyle: .alert)
                    alert.show()
                    print("getFullCoinCapList 4")
                    group.leave()
                }
            }
        }
    }
    
//    var dict1 = [String : Int]()
    func getCoinGeckoData(id: String, symbol : String, group: DispatchGroup, complition : @escaping (GeckoSymbol)->()) {
        DispatchQueue.global().async(group : group) {
            print(DataSingleton.shared.dict1, symbol.uppercased(), id)
            if DataSingleton.shared.dict1[symbol.uppercased()]! < 10 {
                group.enter()
                NetworkRequestManager.request(url: "https://api.coingecko.com/api/v3/coins/\(id)?localization=false&tickers=false&market_data=true&community_data=true&developer_data=false&sparkline=false") { data, response, error in
                    guard let stocksData = data, error == nil, response != nil else {
                        print("getCoinGeckoData 1", id)
                        DataSingleton.shared.dict1[symbol.uppercased()]! += 1
                        self.getCoinGeckoData(id: id, symbol: symbol, group: group, complition : complition);
                        group.leave();
                        return}
                    
                    do {
                        guard let stocks = try GeckoSymbol.decode(from: stocksData) else {
                            print("getCoinGeckoData 2", id)
                            DataSingleton.shared.dict1[symbol.uppercased()]! += 1
                            self.getCoinGeckoData(id: id, symbol: symbol, group: group, complition : complition);
                            group.leave();
                            return}
                    
                        complition(stocks)
                        group.leave()
                        
                    } catch let error as NSError {
                        print("getCoinGeckoData 3")
                        print(error.localizedDescription)
                    }
                }
            } else {
                print("To many requests for", id)
                complition(GeckoSymbol(id: id, symbol: symbol, name: id.uppercased(), geckoSymbolDescription: nil, links: nil, image: nil, marketCapRank: nil, coingeckoRank: nil, marketData: nil, communityData: nil))
            }
        }
    }
    
    
    
    func putCoinGeckoData(array : inout [Crypto], group: DispatchGroup, otherArray : [Crypto]) {
        // GROUP 2
        DispatchGroups.shared.groupOne.wait()
        DispatchGroups.shared.groupTwo.wait()
        print("POPOPOPOPO", DataSingleton.shared.coinGecoList.count)
        if DataSingleton.shared.coinGecoList.count != 0 {
            for elemA in array {
                DispatchQueue.global().async(group: group) {
                    DispatchGroups.shared.groupOne.wait()
                    group.enter()
                    let symbol = elemA.symbolOfCrypto
                    
                    for elemB in otherArray {
                        if elemB.symbolOfCrypto == symbol && !elemB.price!.isEmpty {
                            print("IF",symbol, otherArray.count)
                            elemA.image = elemB.image
                            elemA.imageString = elemB.imageString
                            elemA.nameOfCrypto = elemB.nameOfCrypto
                            elemA.price = elemB.price
                            elemA.percentages?.priceChangePercentage24H = elemB.percentages?.priceChangePercentage24H
                            elemA.percentages?.priceChangePercentage30D = elemB.percentages?.priceChangePercentage30D
                            elemA.percentages?.priceChangePercentage7D = elemB.percentages?.priceChangePercentage7D
                            elemA.percentages?.priceChangePercentage1Y = elemB.percentages?.priceChangePercentage1Y
                            elemA.change = elemB.change
                            elemA.descriptionOfCrypto = elemB.descriptionOfCrypto
                            elemA.links = elemB.links
                            elemA.id = elemB.id
                            elemA.marketDataArray = elemB.marketDataArray
                            elemA.communityDataArray = elemB.communityDataArray
                            group.leave()
                            return
                        }
                    }
                    print("XDXDXD", symbol)
                    var indexOfSymbol: Int?
                    var symbolCoinGecko = String()
                    var idCoinGecko = String()
                    
                    DispatchQueue.global().sync {
                        indexOfSymbol = DataSingleton.shared.coinGecoList.firstIndex(where: { $0.symbol?.lowercased() == symbol.lowercased() })
                        //                        indexOfSymbol = self.binarySearchFoCoinGeckoList(key: symbol, list: self.coinGecoList)
                        idCoinGecko = DataSingleton.shared.coinGecoList[indexOfSymbol!].id!
                        symbolCoinGecko = DataSingleton.shared.coinGecoList[indexOfSymbol!].symbol!
                    }
                    
                    self.getCoinGeckoData(id: idCoinGecko, symbol: symbolCoinGecko, group: group) { (stocks) in
                        if let stringUrl = stocks.image?.large {
                            self.obtainImage(StringUrl: stringUrl, group: group) { image in
                                elemA.image = image
                                elemA.imageString = (stocks.image?.large)!
                                
                            }
                        }
                        elemA.nameOfCrypto = stocks.name
                        if let price = stocks.marketData?.currentPrice?["usd"] {
                            elemA.price = String(price)
                        }
                        if let priceChangePercentage24H = stocks.marketData?.priceChangePercentage24H {
                            let roundedValue = round(priceChangePercentage24H * 100) / 100.0
                            elemA.percentages?.priceChangePercentage24H = String(roundedValue)
                        }
                        if let priceChangePercentage30D = stocks.marketData?.priceChangePercentage30D {
                            let roundedValue = round(priceChangePercentage30D * 100) / 100.0
                            elemA.percentages?.priceChangePercentage30D = String(roundedValue)
                        }
                        if let priceChangePercentage7D = stocks.marketData?.priceChangePercentage7D {
                            let roundedValue = round(priceChangePercentage7D * 100) / 100.0
                            elemA.percentages?.priceChangePercentage7D = String(roundedValue)
                        }
                        if let priceChangePercentage1Y = stocks.marketData?.priceChangePercentage1Y {
                            let roundedValue = round(priceChangePercentage1Y * 100) / 100.0
                            elemA.percentages?.priceChangePercentage1Y = String(roundedValue)
                        }
                        if let priceChange24H = stocks.marketData?.priceChange24H {
                            elemA.change = String(priceChange24H)
                        }
                        
                        elemA.descriptionOfCrypto = stocks.geckoSymbolDescription?.en
                        elemA.links = stocks.links
                        elemA.id = stocks.id
                        
                        
                        if let marketData = stocks.marketData {
                            elemA.marketDataArray = MarketDataArray(marketData: marketData)
                        }
                        if let communityData = stocks.communityData {
                            elemA.communityDataArray = CommunityDataArray(communityData: communityData)
                        }
                        group.leave()
                    }
                }
            }
        }
    }
    
    func obtainImage(StringUrl : String, group : DispatchGroup, complition : @escaping ((UIImage) -> Void) ) {
        
        DispatchQueue.global().async(group : group) {
            if let cachedImage = DataSingleton.shared.imageCache.object(forKey: StringUrl as NSString) {
                complition(cachedImage)
            } else {
                guard let url = URL(string: StringUrl) else {return}
                group.enter()
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, response != nil, error == nil else {return}
                    guard let image = UIImage(data: data) else {return}
                    DataSingleton.shared.imageCache.setObject(image, forKey: StringUrl as NSString)
                    complition(image)
                    group.leave()
                    
                }.resume()
            }
        }
    }
    
    func collectionViewLoad(group : DispatchGroup) {
        
        // GROUP 3
        DispatchGroups.shared.groupOne.wait()
        DispatchQueue.global().async(group : group) {
            print("POPAL BLYAT")
            for index in 0..<20 {
                group.enter()
                var elemOfCoinCap : [String : String?]!
                //                DispatchQueue.global().sync {
                if DataSingleton.shared.coinCapDict.count != 0 {
                    elemOfCoinCap = DataSingleton.shared.coinCapDict[index]
                    let symbol = elemOfCoinCap["symbol"]!!
                    
                    if symbol == "USDT" || symbol == "USDC" ||  symbol == "WBTC" {group.leave(); continue }
                    
                    let crypto = Crypto(symbolOfCrypto: symbol, id: elemOfCoinCap["id"]!!)
                    DataSingleton.shared.collectionViewArray.append(crypto)
                    DataSingleton.shared.collectionViewSymbols.append(crypto.symbolOfCrypto.uppercased())
                    DataSingleton.shared.dict1[symbol] = 0
                    DataSingleton.shared.websocketArray.append(crypto.symbolOfCrypto.uppercased())
                    group.leave()
                }
            }
        }
    }
    
    
    func updateUI(collectionViews: [UICollectionView]){
        DispatchGroups.shared.groupOne.wait()
        DispatchGroups.shared.groupTwo.wait()
        //        groupThree.wait()
        DispatchQueue.main.async {
            for i in collectionViews {
                i.reloadData()
            }
        }
    }
    func recoursiveUpdateUI(collectionViews: [UICollectionView]){
        updateUI(collectionViews: collectionViews)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.recoursiveUpdateUI(collectionViews: collectionViews)
        }
    }
//    let groupSetupSections = DispatchGroup()
    
    func setupSections() {
        DispatchGroups.shared.groupOne.wait()
        //        groupTwo.wait()
        //        groupThree.wait()
        
        DispatchQueue.global().async(group : DispatchGroups.shared.groupSetupSections, flags: .barrier) {
            
            let carousel = SectionOfCrypto(type: "carousel", title: "Top (by Market Cap)", items: DataSingleton.shared.collectionViewArray)
            let table = SectionOfCrypto(type: "table", title: "Hot (by 24H Volume)", items: DataSingleton.shared.results)
            DataSingleton.shared.sections = [carousel,table]
            
        }
        
    }
    
//    // WEBSOCKET
//    
//    let webSocketTask = URLSession(configuration: .default).webSocketTask(with: URL(string: "wss://ws.finnhub.io?token=c12ev3748v6oi252n1fg")!)
//    
//    func webSocket(symbols : [String], symbolsF : [String]) {
//        DispatchQueue.global().async {
//            
//            let set = Set(symbols).union(Set(symbolsF))
//            
//            for symbol in set {
//                let symbolForFinHub = "BINANCE:\(symbol)USDT"
//                let message = URLSessionWebSocketTask.Message.string("{\"type\":\"subscribe\",\"symbol\":\"\(symbolForFinHub)\"}")
//                
//                
//                self.webSocketTask.send(message) { error in
//                    if let error = error {
//                        print("WebSocket couldn’t send message because: \(error)")
//                    }
//                }
//            }
//            
//            self.webSocketTask.resume()
//            self.ping()
//            
//        }
//    }
//    func webSocket2(symbols: [String]) {
//        self.groupOne.wait()
//        self.groupTwo.wait()
//        DispatchQueue.global().async {
//            let set = Set(symbols)
//            for symbol in set {
//                let symbolForFinHub = "BINANCE:\(symbol)USDT"
//                let message = URLSessionWebSocketTask.Message.string("{\"type\":\"subscribe\",\"symbol\":\"\(symbolForFinHub)\"}")
//                
//                
//                self.webSocketTask.send(message) { error in
//                    if let error = error {
//                        print("WebSocket couldn’t send message because: \(error)")
//                    }
//                }
//            }
//            
//            self.webSocketTask.resume()
//            self.ping()
//        }
//    }
//    
//    
//    func ping() {
//        DispatchQueue.global().async(qos: .utility) {
//            self.webSocketTask.sendPing { error in
//                if let error = error {
//                    print("Error when sending PING \(error)")
//                } else {
//                    print("Web Socket connection is alive")
//                    DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
//                        self.ping()
//                    }
//                }
//            }
//        }
//    }
//    
//    
//    func receiveMessage(tableView : [UITableView], collectionView : [UICollectionView]) {
//        self.groupOne.wait()
//        self.groupTwo.wait()
//        DispatchQueue.global().async {
//            self.webSocketTask.receive { [weak self] result in
//                guard let self = self else {return}
//                switch result {
//                case .failure(let error):
//                    print("Error in receiving message: \(error)")
//                case .success(let message):
//                    switch message {
//                    case .string(let text):
//                        if let data: Data = text.data(using: .utf8) {
//                            if let tickData = try? WebSocketData.decode(from: data)?.data {
//                                self.putDataFromWebSocket(tickData: tickData, array: DataSingleton.shared.collectionViewArray)
//                                self.putDataFromWebSocket(tickData: tickData, array: DataSingleton.shared.results)
//                                self.putDataFromWebSocket(tickData: tickData, array: DataSingleton.shared.resultsF, isFavorite: true)
//                            }
//                        }
//                        
//                    case .data(let data):
//                        print("Received data: \(data)")
//                    @unknown default:
//                        fatalError()
//                    }
//                    self.receiveMessage(tableView: tableView, collectionView: collectionView)
//                    
//                }
//            }
//        }
//    }
//    
//    
//    func putDataFromWebSocket (tickData : [Datum], array : [Crypto], isFavorite : Bool = false) {
//        for itemA in tickData {
//            for (indexB,itemB) in array.enumerated() {
//                let itemBForFinHub = "BINANCE:\(itemB.symbolOfCrypto.uppercased())USDT"
//                if itemA.s == itemBForFinHub {
//                    DispatchQueue.global().async(flags: .barrier) {
//                        array[indexB].price = itemA.p.toString()
//                    }
//                }
//            }
//        }
//    }
    
    
    
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
    
    //    func binarySearchFoCoinGeckoList(key : String, list : [GeckoListElement]) -> Int? {
    //
    //        var low = 0
    //        var high = list.count - 1
    //
    //        while low <= high {
    //            let mid = low + (high - low) / 2
    //            if key.lowercased() < list[mid].symbol!.lowercased() {
    //                high = mid - 1
    //            } else if key.lowercased() > list[mid].symbol!.lowercased() {
    //                low = mid + 1
    //            } else {
    //                return mid
    //            }
    //        }
    //        return nil
    //    }
    
    
}
