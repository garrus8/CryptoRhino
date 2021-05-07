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

    
    @IBOutlet weak var lineChartView: LineChartView!
    
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
    
    @IBAction func deleteFromFavorites(_ sender: Any) {
        
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        json(symbol: symbolOfTicker, interval: "day")
        lineChartViewSetup()
        

        
        if textTest.isEmpty {
            self.getCoinGeckoData2(symbol: idOfCrypto)
        } else {
            textView.text = textTest
        }
        

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
        let prevMonthUnix = Int((Calendar.current.date(byAdding: .day, value: -20, to: Date()))!.timeIntervalSince1970)
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
            url: NSURL(string: "https://finnhub.io/api/v1/crypto/candle?symbol=\(symbol)&resolution=\(resolution)&from=\(prevValue)&to=\(nextMinuteUnix)&token=sandbox_c0vndt748v6t383lk640")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = finHubToken
        
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let stocksData = data, error == nil, response != nil else {return}
            
            do {
                let stocks = try GetData.decode(from: stocksData)
                
                for (indexC,elemC) in stocks!.c!.enumerated() {
                    let elemT = stocks!.t![indexC]
                    let chartData = ChartDataEntry(x: Double(elemT), y: elemC)
                    self.values.append(chartData)
                    
                }
                
                DispatchQueue.main.async {
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
