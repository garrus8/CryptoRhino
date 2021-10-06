//
//  ChartViewPresenter.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 15.09.2021.
//

import UIKit
import CoreData
import Charts

protocol ChartViewPresenterProtocol : AnyObject {
    var labels: [String : String] {get}
    var bool: Bool {get}
    var marketData : [MarketDataElem] {get}
    var communityData : [MarketDataElem] {get}
    var image : UIImage {get}
    var percentages: Persentages {get}
    func removeValues()
    func saveTapped()
    func chartLoad(idOfCrypto: String, interval: Interval)
}
//enum Interval : String {
//    case day; case week; case month; case year
//}
//enum KeysOfLabels : String {
//    case symbolOfCurrentCrypto; case descriptionLabel; case nameOfCrypto; case computedDiffPrice; case priceOfCrypto; case idOfCrypto; case symbolOfTicker; case redditUrl; case siteUrl; case imageString
//}

class ChartViewPresenter : ChartViewPresenterProtocol {
    weak var view : ChartViewControllerProtocol!
    var crypto = Crypto(symbolOfCrypto: "", price: "", change: "", nameOfCrypto: "", descriptionOfCrypto: "", id: "", percentages: Persentages(), image: UIImage(named: "pngwing.com") ?? UIImage())
    
    var percentages = Persentages()
    var bool = false
    var marketData = [MarketDataElem]()
    var communityData = [MarketDataElem]()
    var values: [ChartDataEntry] = []
    var image = UIImage()
    let imageOfHeart = UIImage(systemName: "heart")
    let imageOfHeartFill = UIImage(systemName: "heart.fill")
    var networkManager : NetworkManagerForChartProtocol!
    var coreDataManager : CoreDataManagerForChartProtocol!
//    weak var websocketManager : WebSocketManager!
    var labels = [String:String]()
    
    init(crypto : Crypto, view : ChartViewControllerProtocol,
         networkManager : NetworkManagerForChartProtocol,
         coreDataManager : CoreDataManagerForChartProtocol) {
        self.view = view
        self.crypto = crypto
        self.networkManager = networkManager
        self.coreDataManager = coreDataManager
//        self.websocketManager = websocketManager
        load()
        isFavorite()
        checkAndLoad()
    }
    deinit {
        print("DEINIT")
    }
    
    func removeValues() {
        values.removeAll()
    }

    func load() {
        
        labels[KeysOfLabels.symbolOfCurrentCrypto.rawValue] = crypto.symbolOfCrypto
        
        if let descriptionCheck = crypto.descriptionOfCrypto?.html2String {
            labels[KeysOfLabels.descriptionLabel.rawValue] = descriptionCheck
        } else {
            labels[KeysOfLabels.descriptionLabel.rawValue] = ""
        }
        
        if let nameOfCryptoCheck = crypto.nameOfCrypto {
            labels[KeysOfLabels.nameOfCrypto.rawValue] = nameOfCryptoCheck
        } else {
            labels[KeysOfLabels.nameOfCrypto.rawValue] = ""
        }
        if let percentagesCheck = crypto.percentages {
            percentages = percentagesCheck
        }
        
        if let percent = self.percentages.priceChangePercentage24H {
            labels[KeysOfLabels.computedDiffPrice.rawValue] = percent
        } else {
            labels[KeysOfLabels.computedDiffPrice.rawValue] = ""
        }
        
        if let priceOfCryptoCheck = crypto.price {
            labels[KeysOfLabels.priceOfCrypto.rawValue] = priceOfCryptoCheck
        } else {
            labels[KeysOfLabels.priceOfCrypto.rawValue] = "Price of crypto"
        }
        if let cryptoId = crypto.id {
            labels[KeysOfLabels.idOfCrypto.rawValue] = cryptoId
        }
        if let symbolOfTickerCheck = crypto.symbolOfTicker {
            labels[KeysOfLabels.symbolOfTicker.rawValue] = symbolOfTickerCheck
        } else {
            labels[KeysOfLabels.symbolOfTicker.rawValue] = ""
        }
        image = crypto.image ?? UIImage(named: "pngwing.com") ?? UIImage()
        
        if let marketDataChek = crypto.marketDataArray?.array {
            marketData = marketDataChek
        }
        
        if let communityDataChek = crypto.communityDataArray?.array {
            communityData = communityDataChek
        }
        
        if let redditLink = crypto.links?.subredditURL {
            labels[KeysOfLabels.redditUrl.rawValue] = redditLink
        } else {
            labels[KeysOfLabels.redditUrl.rawValue] = ""
        }
        if let siteLink = crypto.links?.homepage?.first {
            labels[KeysOfLabels.siteUrl.rawValue] = siteLink
        } else {
            labels[KeysOfLabels.siteUrl.rawValue] = ""
        }
    }
    
    func checkAndLoad() {
    if labels[KeysOfLabels.priceOfCrypto.rawValue] == "Price of crypto" {
        DispatchQueue.global().async {
            DataSingleton.shared.dict1[(self.labels[KeysOfLabels.symbolOfCurrentCrypto.rawValue]?.uppercased())!] = 0
            
            guard let id = self.labels[KeysOfLabels.idOfCrypto.rawValue], let symbol = self.labels[KeysOfLabels.symbolOfCurrentCrypto.rawValue]
            else {return}
            
            self.networkManager.getCoinGeckoData(id: id,
                                                   symbol: symbol,
                                                   group: DispatchGroups.shared.groupOne) { (stocks) in
                
                if let stringUrl = stocks.image?.large {
                    self.networkManager.obtainImage(StringUrl: stringUrl, group: DispatchGroup()) { image in
                        self.image = image
                        self.labels[KeysOfLabels.imageString.rawValue] = stocks.image?.large
                        self.view.navigationBarSetup()
                    }
                }
                DispatchQueue.main.async {
                    self.labels[KeysOfLabels.descriptionLabel.rawValue] = stocks.geckoSymbolDescription?.en?.html2String
                    
                    if self.labels[KeysOfLabels.descriptionLabel.rawValue] == nil || self.labels[KeysOfLabels.descriptionLabel.rawValue] == "" {
                        self.view.updateContentViewFrame(contentViewFrameChange: 50,
                                                    detailInfoViewFrameChange: 50,
                                                    scrollViewChange: 50)
                    } else if self.labels[KeysOfLabels.descriptionLabel.rawValue]!.count / 45 < 7 {
                        let height = CGFloat((7 - (self.labels[KeysOfLabels.descriptionLabel.rawValue]!.count / 45)) * 10)
                        self.view.updateContentViewFrame(contentViewFrameChange: height,
                                                    detailInfoViewFrameChange: height,
                                                    scrollViewChange: height)
                    }
                    
                    if let redditUrl = stocks.links?.subredditURL {
                        self.labels[KeysOfLabels.redditUrl.rawValue] = redditUrl
                    }
                    if let siteUrl = stocks.links?.homepage?.first {
                        self.labels[KeysOfLabels.siteUrl.rawValue] = siteUrl
                    }
                    
                    
                    if let marketData = stocks.marketData {
                        if let percent30D = marketData.priceChangePercentage30D {
                            self.labels[KeysOfLabels.computedDiffPrice.rawValue] = String(percent30D)
                        }
                        
                        self.percentages = Persentages(priceChangePercentage24H: String(marketData.priceChangePercentage24H ?? 0),
                                                       priceChangePercentage7D: String(marketData.priceChangePercentage7D ?? 0),
                                                       priceChangePercentage30D: String(marketData.priceChangePercentage30D ?? 0),
                                                       priceChangePercentage1Y: String(marketData.priceChangePercentage1Y ?? 0))
                        
                        if let currentPriceInUSD = marketData.currentPrice?["usd"] {
                            self.labels[KeysOfLabels.priceOfCrypto.rawValue] = String(currentPriceInUSD)
                        }
                    }
                    if let marketData = stocks.marketData {
                        self.marketData = MarketDataArray(marketData: marketData).array
                        self.view.reloadMarketDataTableView()
//                        self.view.marketDataTableView.reloadData()
                    }
                    if let communityData = stocks.communityData {
                        self.communityData = CommunityDataArray(communityData: communityData).array
                        self.view.reloadCommunityDataTableView()
//                        self.view.communityDataTableView.reloadData()
                    }
                    self.view.updateData()
//                    self.view.setupDetailInfo()
//                    self.view.increaseScrollViewBottom(for: 67)
//                    self.view.scrollView.contentInset.bottom += 67
                    
                }
            }
        }
    } else {
        if self.labels[KeysOfLabels.descriptionLabel.rawValue] == nil || self.labels[KeysOfLabels.descriptionLabel.rawValue] == "" {
            self.view.updateContentViewFrame(contentViewFrameChange: 50,
                                        detailInfoViewFrameChange: 50,
                                        scrollViewChange: 50)
        }  else if self.labels[KeysOfLabels.descriptionLabel.rawValue]!.count / 45 < 7 {
            let height = CGFloat((7 - (self.labels[KeysOfLabels.descriptionLabel.rawValue]!.count / 45)) * 10)
            self.view.updateContentViewFrame(contentViewFrameChange: height,
                                        detailInfoViewFrameChange: height,
                                        scrollViewChange: height)
        }
    }
}
    func isFavorite() {
        for i in DataSingleton.shared.favorites {
            if let symbol = i.symbol {
                if labels[KeysOfLabels.symbolOfCurrentCrypto.rawValue] == symbol {
                    bool = true
                }
            }
        }
    }
    private func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    func saveTapped() {
        if bool == true {
            view.navigationItem.rightBarButtonItem?.image = imageOfHeart
            let context = self.getContext()
            let favoriteSymbol = labels[KeysOfLabels.symbolOfCurrentCrypto.rawValue]
            
            for i in DataSingleton.shared.favorites {
                if i.symbol == favoriteSymbol {
                    context.delete(i)
                    
                }
            }
            for (index,j) in DataSingleton.shared.resultsF.enumerated() {
                if j.symbolOfCrypto == favoriteSymbol {
                    DataSingleton.shared.resultsF.remove(at: index)
                }
            }
            
            do {
                try context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        } else {
            view.navigationItem.rightBarButtonItem?.image = imageOfHeartFill
            
            let context = self.getContext()
            let favoriteSymbol = labels[KeysOfLabels.symbolOfCurrentCrypto.rawValue]
            let favoriteTicker = labels[KeysOfLabels.symbolOfTicker.rawValue]
            let object = Favorites(context: context)
            object.symbol = favoriteSymbol
            object.symbolOfTicker = favoriteTicker
            object.name = labels[KeysOfLabels.nameOfCrypto.rawValue]
            object.descrtiption = labels[KeysOfLabels.descriptionLabel.rawValue]
            object.date = Date()
            
            
            do {
                try context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            DataSingleton.shared.favorites.insert(object, at: 0)
            coreDataManager.addData(object: object)
//            websocketManager.webSocket(symbols: DataSingleton.shared.symbols, symbolsF: DataSingleton.shared.symbolsF)

        }
        bool.toggle()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
    }

    func chartLoad(idOfCrypto: String, interval: Interval) {
        
        DispatchQueue.global().async {
            
            let nowUnix = Int(NSDate().timeIntervalSince1970)
            var prevValue = Int()
            var dateFormat = String()
            
            switch interval {
            case .day:
                dateFormat = "HH:mm"
                prevValue = Int((Calendar.current.date(byAdding: .day, value: -1, to: Date()))!.timeIntervalSince1970)
            case .week:
                dateFormat = "E HH:mm"
                prevValue = Int((Calendar.current.date(byAdding: .day, value: -7, to: Date()))!.timeIntervalSince1970)
            case .month:
                dateFormat = "MMM d"
                prevValue = Int((Calendar.current.date(byAdding: .month, value: -1, to: Date()))!.timeIntervalSince1970)
            case .year:
                dateFormat = "dd.MM.yy"
                prevValue = Int((Calendar.current.date(byAdding: .year, value: -1, to: Date()))!.timeIntervalSince1970)
            }

            NetworkRequestManager.request(url: "https://api.coingecko.com/api/v3/coins/\(idOfCrypto)/market_chart/range?vs_currency=usd&from=\(prevValue)&to=\(nowUnix)") { data, response, error in
                guard let stocksData = data, error == nil, response != nil else {
                    print("ХЫЧ ХЫЧ");
                    self.chartLoad(idOfCrypto: idOfCrypto, interval: interval);
                    return}
                
                do {
                    guard let stocks = try CoinGeckoPrice.decode(from: stocksData) else {return}
                    guard let prices = stocks.prices else {return}
                    for i in prices {
                        let chartData = ChartDataEntry(x: i[0], y: i[1])
                        self.values.append(chartData)
                    }
                    DispatchQueue.main.async {
                        let xAxisValueFormatter = MyXAxisFormatter(dateFormat: dateFormat)
                        let dataSet = LineChartDataSet(entries: self.values)
                        self.view.setData(dataSet: dataSet, xAxisValueFormatter: xAxisValueFormatter)
//                        self.lineChartView.xAxis.valueFormatter = MyXAxisFormatter(dateFormat: dateFormat)
                        self.view.lineChartViewSetup()
                    }
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
    }
    class MyXAxisFormatter : NSObject, IAxisValueFormatter {
        var dateFormat : String
        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            let date = Date(timeIntervalSince1970: TimeInterval(value) / 1000)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormat
            let dateString = dateFormatter.string(from: date)
            return dateString
        }
        init(dateFormat: String) {
            self.dateFormat = dateFormat
        }
    }
}
