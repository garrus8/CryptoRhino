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
    var labels : [String : String] {get}
    var priceDict : [String : Double] {get}
    var bool : Bool {get}
    var marketData : [MarketDataElem] {get}
    var communityData : [MarketDataElem] {get}
    var image : UIImage {get}
    var percentages: Persentages {get}
    func removeValues()
    func saveTapped()
    func chartLoad(idOfCrypto: String, interval: Interval)
    func converterFromCrypto(first : Double, price : Double?) -> String
    func converterToCrypto(second : Double, price : Double?) -> String
}

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
    var labels = [String : String]()
    var priceDict = [String : Double]()
    
    init(crypto : Crypto, view : ChartViewControllerProtocol,
         networkManager : NetworkManagerForChartProtocol,
         coreDataManager : CoreDataManagerForChartProtocol) {
        self.view = view
        self.crypto = crypto
        self.networkManager = networkManager
        self.coreDataManager = coreDataManager
        load()
        checkAndLoad()
        isFavorite()
        DispatchQueue.main.async {
            self.view.activityIndicator.startAnimating()
            self.view.activityIndicator.isHidden = false
        }
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
        if let priceOfCryptoCheck = crypto.priceLabel {
            labels[KeysOfLabels.priceOfCrypto.rawValue] = priceOfCryptoCheck
        } else {
            labels[KeysOfLabels.priceOfCrypto.rawValue] = "Price of crypto"
        }
        if let priceDict = crypto.pricesDict {
            self.priceDict = priceDict
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

    
    func converterFromCrypto(first : Double = 1, price : Double?) -> String {
        guard let price = price else {return ""}
        let convertedValue = first * price
        return convertedValue.toString()
    }
    
    func converterToCrypto(second : Double, price : Double?) -> String {
        guard let price = price else {return ""}
        let convertedValue = second / price
        return convertedValue.toString()
    }
    
    
    func checkAndLoad() {
    if labels[KeysOfLabels.priceOfCrypto.rawValue] == "Price of crypto" {
        DispatchQueue.global().async {
            if let symbolOfCurrentCrypto = self.labels[KeysOfLabels.symbolOfCurrentCrypto.rawValue]?.uppercased() {
                DataSingleton.shared.dict1[symbolOfCurrentCrypto] = 0
            }
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
                        self.view.updateContentViewFrame(contentViewFrameChange: 60,
                                                    detailInfoViewFrameChange: 60,
                                                    scrollViewChange: 60, isIncrement: false)
                    } else if self.labels[KeysOfLabels.descriptionLabel.rawValue]!.count / 45 < 7 {
                        let height = CGFloat((7 - (self.labels[KeysOfLabels.descriptionLabel.rawValue]!.count / 45)) * 10)
                        self.view.updateContentViewFrame(contentViewFrameChange: height,
                                                    detailInfoViewFrameChange: height,
                                                    scrollViewChange: height, isIncrement: false)
                    }
                    
                    if let priceDict = stocks.marketData?.currentPrice {
                        self.priceDict = priceDict
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
                        
                        if let priceChangePercentage24H = stocks.marketData?.priceChangePercentage24H {
                            let roundedValue = round(priceChangePercentage24H * 100) / 100.0
                            self.percentages.priceChangePercentage24H = String(roundedValue)
                        }
                        if let priceChangePercentage30D = stocks.marketData?.priceChangePercentage30D {
                            let roundedValue = round(priceChangePercentage30D * 100) / 100.0
                            self.percentages.priceChangePercentage30D = String(roundedValue)
                        }
                        if let priceChangePercentage7D = stocks.marketData?.priceChangePercentage7D {
                            let roundedValue = round(priceChangePercentage7D * 100) / 100.0
                            self.percentages.priceChangePercentage7D = String(roundedValue)
                        }
                        if let priceChangePercentage1Y = stocks.marketData?.priceChangePercentage1Y {
                            let roundedValue = round(priceChangePercentage1Y * 100) / 100.0
                            self.percentages.priceChangePercentage1Y = String(roundedValue)
                        }
                        if let currentPriceInUSD = marketData.currentPrice?["usd"] {
                            self.labels[KeysOfLabels.priceOfCrypto.rawValue] = currentPriceInUSD.toString()
                        }
                    }
                    if let marketData = stocks.marketData {
                        self.marketData = MarketDataArray(marketData: marketData).array
                        self.view.reloadMarketDataTableView()

                    }
                    if let communityData = stocks.communityData {
                        self.communityData = CommunityDataArray(communityData: communityData).array
                        self.view.reloadCommunityDataTableView()
                    }
                    self.view.updateContentViewFrame(contentViewFrameChange: 40, detailInfoViewFrameChange: 40, scrollViewChange: 40, isIncrement: true)
                    self.view.updateData()
                }
            }
        }
    } else {
        if self.labels[KeysOfLabels.descriptionLabel.rawValue] == nil || self.labels[KeysOfLabels.descriptionLabel.rawValue] == "" {
            self.view.updateContentViewFrame(contentViewFrameChange: 60,
                                             detailInfoViewFrameChange: 60,
                                             scrollViewChange: 60, isIncrement: false)
        }
        guard let descriptionLabel = self.labels[KeysOfLabels.descriptionLabel.rawValue] else {return}
        if descriptionLabel.count / 45 < 7 && descriptionLabel != "" {
            let height = CGFloat((7 - (descriptionLabel.count / 40)) * 10)
            self.view.updateContentViewFrame(contentViewFrameChange: height,
                                             detailInfoViewFrameChange: height,
                                             scrollViewChange: height, isIncrement: false)
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
                guard let date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {break}
                prevValue = Int(date.timeIntervalSince1970)
            case .week:
                dateFormat = "E"
                guard let date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else {break}
                prevValue = Int(date.timeIntervalSince1970)
            case .month:
                dateFormat = "MMM d"
                guard let date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) else {break}
                prevValue = Int(date.timeIntervalSince1970)
            case .year:
                dateFormat = "MMM d"
                guard let date = Calendar.current.date(byAdding: .year, value: -1, to: Date()) else {break}
                prevValue = Int(date.timeIntervalSince1970)
            }
            NetworkRequestManager.request(url: "https://api.coingecko.com/api/v3/coins/\(idOfCrypto)/market_chart/range?vs_currency=usd&from=\(prevValue)&to=\(nowUnix)") { data, response, error in
                guard let stocksData = data, error == nil, response != nil else {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                        self.chartLoad(idOfCrypto: idOfCrypto, interval: interval)
                    }
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
                        self.view.lineChartViewSetup()
                        self.view.activityIndicator.stopAnimating()
                        self.view.activityIndicator.isHidden = true
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
