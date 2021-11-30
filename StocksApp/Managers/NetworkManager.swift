//
//  WebSocketManager.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 25.02.2021.
//
import Foundation
import UIKit

protocol NetworkManagerMainProtocol {
    func getTopOfCrypto(group : DispatchGroup)
    func getTopSearch(group : DispatchGroup)
    func getFullListOfCoinGecko(group : DispatchGroup, waitingGroup : DispatchGroup)
    func getFullCoinCapList(group : DispatchGroup)
    func getCoinGeckoData(id: String, symbol : String, group: DispatchGroup, complition : @escaping (GeckoSymbol)->())
    func putCoinGeckoData(array : inout [Crypto], group: DispatchGroup, otherArray : [Crypto])
    func obtainImage(StringUrl : String, group : DispatchGroup, complition : @escaping ((UIImage) -> Void))
    func carouselDataLoad(group : DispatchGroup)
    func setupSections()
    
}
protocol NetworkManagerForChartProtocol {
    func getCoinGeckoData(id: String, symbol : String, group: DispatchGroup, complition : @escaping (GeckoSymbol)->())
    func obtainImage(StringUrl : String, group : DispatchGroup, complition : @escaping ((UIImage) -> Void))
}

protocol NetworkManagerForNewsProtocol {
    func obtainImage(StringUrl : String, group : DispatchGroup, complition : @escaping ((UIImage) -> Void))
}

protocol NetworkManagerForCoreDataProtocol {
    func putCoinGeckoData(array : inout [Crypto], group: DispatchGroup, otherArray : [Crypto])
}

class NetworkManager {
    
    private let queue = DispatchQueue(label: "queue", qos: .userInitiated)
    private var countTopOfCrypto = 0
    
    func getTopOfCrypto(group : DispatchGroup) {
        DispatchQueue.global().async(group: group) {
            if self.countTopOfCrypto < 10 {
                group.enter()
                NetworkRequestManager.request(url: Urls.topOfCrypto.rawValue) { data, response, error in
                    guard let stocksData = data, error == nil, response != nil else {
                        self.countTopOfCrypto += 1;
                        self.getTopOfCrypto(group: group);
                        group.leave();
                        return}
                    
                    do {
                        guard let stocksData = try (Toplist.decode(from: stocksData))?.data else {
                            self.countTopOfCrypto += 1;
                            self.getTopOfCrypto(group: group);
                            group.leave();
                            return}
                        
                        for i in 0..<(stocksData.count) {
                            group.enter()
                            let elem = stocksData[i]
                            guard let cryptoCompareName = elem.coinInfo?.name else {return}
                            
                            if !DataSingleton.shared.blackList.contains(cryptoCompareName) {
                                guard let cryptoCompareFullName = elem.coinInfo?.fullName else {return}
                                let crypto = Crypto(symbolOfCrypto: cryptoCompareName, price: "", change: "", nameOfCrypto: cryptoCompareFullName, descriptionOfCrypto: nil, id: "", percentages: Persentages(), image: UIImage(named: "pngwing.com")!)
                                self.queue.async(group : group, flags : .barrier) {
                                    DataSingleton.shared.dict1[cryptoCompareName] = 0
                                    DataSingleton.shared.results.append(crypto)
                                    DataSingleton.shared.websocketArray.append(cryptoCompareName)
                                    DataSingleton.shared.symbols.append(cryptoCompareName.uppercased())
                                }
                            }
                            group.leave()
                        }
                        group.leave()
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            } else {
                DispatchQueue.main.async() {
                    group.enter()
                    let alert = UIAlertController(title: "Sorry, you have exceeded our API request limit", message: "Try in one minute", preferredStyle: .alert)
                    alert.show()
                    group.leave()
                }
            }
        }
    }
    
    func getTopSearch(group : DispatchGroup) {
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
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private var countOfFullListCoinGecko = 0
    
    func getFullListOfCoinGecko(group : DispatchGroup, waitingGroup : DispatchGroup) {
        DispatchQueue.global().async(group: group) {
            if self.countOfFullListCoinGecko < 10 {
                group.enter()
                NetworkRequestManager.request(url: Urls.fullListOfCoinGecko.rawValue) { data, response, error in
                    guard let stocksData = data, error == nil, response != nil else {
                        self.countOfFullListCoinGecko += 1;
                        self.getFullListOfCoinGecko(group : group, waitingGroup : waitingGroup);
                        group.leave();
                        return}
                    
                    do {
                        guard let stocks = try GeckoList.decode(from: stocksData) else {
                            self.countOfFullListCoinGecko += 1;
                            self.getFullListOfCoinGecko(group : group, waitingGroup : waitingGroup);
                            group.leave();
                            return}
                        
                        DispatchQueue.global().async(group : group, flags: .barrier) {
                            DataSingleton.shared.coinGecoList = stocks
                            self.quickSortForCoinGecko(&DataSingleton.shared.coinGecoList, start: 0, end: DataSingleton.shared.coinGecoList.count)
//                            DataSingleton.shared.coinGecoList.removeAll{ $0.id!.contains("binance-peg")}
                            DataSingleton.shared.coinGecoList.removeAll{ elem in
                                guard let id = elem.id else {return false}
                                return id.contains("binance-peg")
                            }
                            waitingGroup.wait()
                            for (index,geckoElem) in DataSingleton.shared.coinGecoList.enumerated() {
                                var elem = GeckoListElement(id: geckoElem.id, symbol: geckoElem.symbol?.uppercased(), name: geckoElem.name, rank: 101)
                                for capElem in DataSingleton.shared.coinCapDict {
                                    if let symbolOfCapElem = capElem["symbol"] {
                                        if symbolOfCapElem == geckoElem.symbol?.uppercased() {
                                            if let rankOfCapElem = capElem["rank"] {
                                                if let rankOfCapElem = rankOfCapElem {
                                                    elem.rank = Int(rankOfCapElem)
                                                    DataSingleton.shared.coinGecoList[index].rank = Int(rankOfCapElem)
                                                }
                                            }
                                        }
                                    }
                                }
                                DataSingleton.shared.fullBinanceList.append(elem)
                            }
                            DataSingleton.shared.fullBinanceList.sort{$0.rank ?? 101 < $1.rank ?? 101}
                            group.leave()
                        }
                        
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            } else {
                DispatchQueue.main.async() {
                    group.enter()
                    let alert = UIAlertController(title: "Sorry, you have exceeded our API request limit", message: "Try in one minute", preferredStyle: .alert)
                    alert.show()
                    group.leave()
                }
            }
        }
    }
    
    private var countOfCoinCap = 0
    
    func getFullCoinCapList(group : DispatchGroup) {
        DispatchQueue.global().async(group: group) {
            if self.countOfCoinCap < 10 {
                group.enter()
                NetworkRequestManager.request(url: Urls.fullCoinCapList.rawValue) { data, response, error in
                    guard let stocksData = data, error == nil, response != nil else {
                        self.countOfCoinCap += 1
                        self.getFullCoinCapList(group: group);
                        group.leave();
                        return}
                    
                    do {
                        guard let elems = try FullCoinCapList.decode(from: stocksData) else {
                            self.countOfCoinCap += 1
                            self.getFullCoinCapList(group: group);
                            group.leave()
                            return}
                        
                        if let data = elems.data {
                            DataSingleton.shared.coinCapDict = data
                        }
                        group.leave()
                        
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            } else {
                DispatchQueue.main.async() {
                    group.enter()
                    let alert = UIAlertController(title: "Sorry, you have exceeded our API request limit", message: "Try in one minute", preferredStyle: .alert)
                    alert.show()
                    group.leave()
                }
            }
        }
    }
    
    func getCoinGeckoData(id: String, symbol : String, group: DispatchGroup, complition : @escaping (GeckoSymbol)->()) {
        DispatchQueue.global().async(group : group) {
            guard DataSingleton.shared.dict1[symbol.uppercased()] != nil else {return}
            if DataSingleton.shared.dict1[symbol.uppercased()]! < 3 {
                NetworkRequestManager.request(url: "https://api.coingecko.com/api/v3/coins/\(id)?localization=false&tickers=false&market_data=true&community_data=true&developer_data=false&sparkline=false") { data, response, error in
                    guard let stocksData = data, error == nil, response != nil else {
                        DataSingleton.shared.dict1[symbol.uppercased()]! += 1
                        self.getCoinGeckoData(id: id, symbol: symbol, group: group, complition : complition);
                        return}
                    
                    do {
                        guard let stocks = try GeckoSymbol.decode(from: stocksData) else {
                            DataSingleton.shared.dict1[symbol.uppercased()]! += 1
                            self.getCoinGeckoData(id: id, symbol: symbol, group: group, complition : complition);
                            return}
                        
                        complition(stocks)
                        
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            } else {
                complition(GeckoSymbol(id: id, symbol: symbol, name: id.uppercased(), geckoSymbolDescription: nil, links: nil, image: nil, marketCapRank: nil, coingeckoRank: nil, marketData: nil, communityData: nil))
            }
        }
    }
    
    
    
    func putCoinGeckoData(array : inout [Crypto], group: DispatchGroup, otherArray : [Crypto]) {
        DispatchGroups.shared.groupOne.wait()
        DispatchGroups.shared.groupTwo.wait()
        
        if DataSingleton.shared.coinGecoList.count != 0 {
            for elemA in array {
                DispatchQueue.global().async(group: group) {
                    DispatchGroups.shared.groupOne.wait()
                    group.enter()
                    let symbol = elemA.symbolOfCrypto
                    for elemB in otherArray {
                        guard let priceLabel = elemB.priceLabel else {return}
                        if elemB.symbolOfCrypto == symbol && !priceLabel.isEmpty {
                            elemA.image = elemB.image
                            elemA.imageString = elemB.imageString
                            elemA.nameOfCrypto = elemB.nameOfCrypto
                            elemA.priceLabel = elemB.priceLabel
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

                    var indexOfSymbol: Int?
                    var symbolCoinGecko = String()
                    var idCoinGecko = String()
                    
                    DispatchQueue.global().sync {
                        indexOfSymbol = DataSingleton.shared.coinGecoList.firstIndex(where: { $0.symbol?.lowercased() == symbol.lowercased() })
                        if let indexOfSymbol = indexOfSymbol {
                            if let id = DataSingleton.shared.coinGecoList[indexOfSymbol].id {
                                idCoinGecko = id
                            }
                            if let symbol = DataSingleton.shared.coinGecoList[indexOfSymbol].symbol {
                                symbolCoinGecko = symbol
                            }
                        }
                    }
                    self.getCoinGeckoData(id: idCoinGecko, symbol: symbolCoinGecko, group: group) { (stocks) in
                        if let stringUrl = stocks.image?.large {
                            self.obtainImage(StringUrl: stringUrl, group: group) { image in
                                elemA.image = image
                                elemA.imageString = stocks.image?.large
                            }
                        }
                        elemA.nameOfCrypto = stocks.name
                        if let priceDict = stocks.marketData?.currentPrice {
                            elemA.pricesDict = priceDict
                        }
                        if let price = stocks.marketData?.currentPrice?["usd"] {
                            elemA.priceLabel = price.toString()
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
    
    
    func obtainImage(StringUrl : String, group : DispatchGroup, complition : @escaping ((UIImage) -> Void)) {
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
    
    func carouselDataLoad(group : DispatchGroup) {
        DispatchGroups.shared.groupOne.wait()
        DispatchQueue.global().async(group : group) {
            for index in 0..<15 {
                group.enter()
                var elemOfCoinCap : [String : String?]
                if DataSingleton.shared.coinCapDict.count != 0 {
                    elemOfCoinCap = DataSingleton.shared.coinCapDict[index]
                    guard let symbol = elemOfCoinCap["symbol"] else {return}
                    guard let checkedSymbol = symbol else {return}
                    
                    if DataSingleton.shared.blackList.contains(checkedSymbol) {group.leave(); continue }
                    let crypto = Crypto(symbolOfCrypto: checkedSymbol, id: (elemOfCoinCap["id"] ?? "") ?? "")
                    DataSingleton.shared.collectionViewArray.append(crypto)
                    DataSingleton.shared.collectionViewSymbols.append(crypto.symbolOfCrypto.uppercased())
                    DataSingleton.shared.dict1[checkedSymbol] = 0
                    DataSingleton.shared.websocketArray.append(crypto.symbolOfCrypto.uppercased())
                    group.leave()
                }
            }
        }
    }
    
    func setupSections() {
        DispatchGroups.shared.groupOne.wait()
        DispatchQueue.global().async(group : DispatchGroups.shared.groupSetupSections, flags: .barrier) {
            let carousel = SectionOfCrypto(type: "carousel", title: "Top by Market Cap", items: DataSingleton.shared.collectionViewArray)
            let table = SectionOfCrypto(type: "table", title: "Hot by 24H Volume", items: DataSingleton.shared.results)
            DataSingleton.shared.sections = [carousel,table]
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
            guard let lowSymbol = list[low].symbol, let highSymbol = list[high].symbol, let pivotSymbol = pivot.symbol else {return}
            if lowSymbol < pivotSymbol {
                low += 1
                continue
            }
            if highSymbol > pivotSymbol {
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
}

extension NetworkManager : NetworkManagerMainProtocol, NetworkManagerForChartProtocol, NetworkManagerForNewsProtocol, NetworkManagerForCoreDataProtocol {}
