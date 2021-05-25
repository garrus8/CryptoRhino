//
//  ChartViewController.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 06.04.2021.
//

import UIKit
import Charts
import CoreData

class ChartViewController: UIViewController, ChartViewDelegate {
    
    let finHubToken = Constants.finHubToken
    var values: [ChartDataEntry] = []
    var textTest = String()
    var symbolOfCurrentCrypto = String()
    var symbolOfTicker = String()
    let tableView = UITableView()
    var idOfCrypto = String()
    let imageOfHeart = UIImage(systemName: "heart")
    let imageOfHeartFill = UIImage(systemName: "heart.fill")
    var bool = false
    var diffPriceOfCryptoText = String()
    var priceOfCryptoText = String()
    var nameOfCryptoText = String()

    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var nameOfCrypto: UILabel!
    @IBOutlet weak var priceOfCrypto: UILabel!
    @IBOutlet weak var diffPriceOfCrypto: UILabel!
    
    private func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    @IBAction func favoritesButton(_ sender: Any) {
        let context = self.getContext()
        let favoriteSymbol = symbolOfCurrentCrypto
        let favoriteTicker = symbolOfTicker
        let object = Favorites(context: context)
        object.symbol = favoriteSymbol
        object.symbolOfTicker = favoriteTicker
        
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        getData()
        print(idOfCrypto)
        json(symbol: symbolOfTicker, interval: "day")
        lineChartViewSetup()
        navigationBarSetup()
        if priceOfCryptoText.isEmpty {
//            NetworkManager.shared.getFinHubData2(symbol: symbolOfCurrentCrypto) { (arr) in
//                DispatchQueue.main.async {
//                    self.priceOfCrypto.text = String(arr.first!)
//                    self.diffPriceOfCrypto.text = {
//                        return String((arr.first! - arr[1]) / arr[1])
//                    }()
//                }
//                
//                
//            }
            
            NetworkManager.shared.getFinHubData(symbol: symbolOfCurrentCrypto) { (stocks) in
                DispatchQueue.main.async {
                    guard let stockLast = stocks?.c?.last else {return}
                    guard let stockFirst = stocks?.c?.first else {return}
                    
                    self.priceOfCrypto.text = String(stockLast)
                    self.diffPriceOfCrypto.text = {
                        return String((stockLast - stockFirst) / stockFirst)
                    }()
                }
            }
                
            }
        
        diffPriceOfCrypto.text = diffPriceOfCryptoText
        priceOfCrypto.text = priceOfCryptoText
        nameOfCrypto.text = nameOfCryptoText

        
        if textTest.isEmpty {
            self.getCoinGeckoData2(symbol: idOfCrypto)
        } else {
            textView.text = textTest
        }

        
        

    }
    
  
    
    private func navigationBarSetup() {
      
        let butt = UIBarButtonItem(image: imageOfHeart, style: .done, target: self, action: #selector(saveTapped))
        for i in NetworkManager.shared.favorites {
            if let symbol = i.symbol {
                if symbolOfCurrentCrypto == symbol {
                    bool = true
                    butt.image = imageOfHeartFill
                }
            }
        }
        navigationItem.rightBarButtonItem = butt
        
//        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        navigationItem.backBarButtonItem?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    @objc func saveTapped() {
        if bool == true {
            navigationItem.rightBarButtonItem?.image = imageOfHeart
            
            let context = self.getContext()
            let favoriteSymbol = symbolOfCurrentCrypto
            
            for i in NetworkManager.shared.favorites {
                if i.symbol == favoriteSymbol {
                    context.delete(i)
                    
                }
            }
            for (index,j) in NetworkManager.shared.resultsF.enumerated() {
                if j.symbolOfCrypto == favoriteSymbol {
                    NetworkManager.shared.resultsF.remove(at: index)
                }
            }
            
            do {
                try context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        } else {
            navigationItem.rightBarButtonItem?.image = imageOfHeartFill
            
            let context = self.getContext()
            let favoriteSymbol = symbolOfCurrentCrypto
            let favoriteTicker = symbolOfTicker
            let object = Favorites(context: context)
            object.symbol = favoriteSymbol
            object.symbolOfTicker = favoriteTicker
            object.date = Date()
            
            
            do {
                try context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            NetworkManager.shared.getData()
//            NetworkManager.shared.test(tableView: [self.tableView])
            NetworkManager.shared.test2(array: &NetworkManager.shared.resultsF)
            NetworkManager.shared.webSocket(symbols: NetworkManager.shared.symbols, symbolsF: NetworkManager.shared.symbolsF)

        }
        bool.toggle()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
  
    }
   
    @IBAction func dayChartButton(_ sender: Any) {
        values.removeAll()
        json(symbol: symbolOfTicker, interval: "day")
    }
    @IBAction func monthChartButton(_ sender: Any) {
        values.removeAll()
        json(symbol: symbolOfTicker, interval: "month")
    }
    @IBAction func yearChartButton(_ sender: Any) {
        values.removeAll()
        json(symbol: symbolOfTicker, interval: "year")
    }
    
    @IBOutlet weak var textView: UITextView!
    
    private func lineChartViewSetup() {
        lineChartView.backgroundColor = .systemGray
        lineChartView.leftAxis.enabled = false
        lineChartView.xAxis.setLabelCount(5, force: false)
        lineChartView.rightAxis.setLabelCount(8, force: false)
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.animate(xAxisDuration: 0.8)
        
    }
    

    
    func getCoinGeckoData2(symbol: String) {
        
            let request = NSMutableURLRequest(
                url: NSURL(string: "https://api.coingecko.com/api/v3/coins/\(symbol)?localization=false&tickers=false&market_data=false&community_data=true&developer_data=false&sparkline=false")! as URL,
                cachePolicy: .useProtocolCachePolicy,
                timeoutInterval: 10.0)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                guard let stocksData = data, error == nil, response != nil else {return}
                do {
                    let stocks = try GeckoSymbol.decode(from: stocksData)
                    
                    DispatchQueue.main.async {
                        self.textView.text = stocks?.geckoSymbolDescription?.en
                        
                        self.tableView.reloadData()
                    }
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }.resume()
        
    }
    
    func json(symbol:String, interval : String){
        
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
            url: NSURL(string: "https://finnhub.io/api/v1/crypto/candle?symbol=\(symbol)&resolution=\(resolution)&from=\(prevValue)&to=\(nextMinuteUnix)&token=c12ev3748v6oi252n1fg")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = finHubToken
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let stocksData = data, error == nil, response != nil else {return}
            
            do {
                guard let stocks = try GetData.decode(from: stocksData) else {return}
                guard let stocksC = stocks.c else {return}
                
                for (indexC,elemC) in stocksC.enumerated() {
                    let elemT = stocks.t![indexC]
                    let chartData = ChartDataEntry(x: Double(elemT), y: elemC)
                    self.values.append(chartData)
                    
                }
                
                guard let stockLast = stocksC.last else {return}
                guard let stockFirst = stocksC.first else {return}
                
                DispatchQueue.main.async {
                    self.diffPriceOfCrypto.text = {
                        return String((stockLast - stockFirst) / stockFirst * 100)
                    }()
                    self.setData()
                    self.lineChartView.xAxis.valueFormatter = MyXAxisFormatter(dateFormat: dateFormat)
                    self.lineChartViewSetup()
                }
                
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }.resume()
        
    }
    
    func setData() {
        let set1 = LineChartDataSet(entries: values)
        set1.drawCirclesEnabled = false
        set1.mode = .linear
        set1.lineWidth = 2
        set1.setColor(.cyan)
        set1.fill = Fill(color: .cyan)
        set1.fillAlpha = 0.5
        set1.drawFilledEnabled = true
        set1.drawVerticalHighlightIndicatorEnabled = false
        set1.highlightColor = .red
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        lineChartView.data = data
        
    }
    
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    
}

class MyXAxisFormatter : IAxisValueFormatter {
//    let chartVC = ChartViewController()
    var dateFormat = "MMM d"
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let dateString = dateFormatter.string(from: date)
        return dateString
        
    }
    init(dateFormat: String) {
        self.dateFormat = dateFormat
    }
    
}
