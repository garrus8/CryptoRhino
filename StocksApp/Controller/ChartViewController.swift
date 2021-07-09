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
    var crypto = Crypto(symbolOfCrypto: "", price: "", change: "", nameOfCrypto: "", descriptionOfCrypto: "", symbolOfTicker: "", id: "", percent: "")
    
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

        symbolOfCurrentCrypto = crypto.symbolOfCrypto
        textTest = crypto.descriptionOfCrypto ?? ""
        nameOfCrypto.text = crypto.nameOfCrypto ?? ""
        diffPriceOfCrypto.text = crypto.percent ?? ""
        priceOfCrypto.text = crypto.price ?? ""
        idOfCrypto = crypto.id ?? ""
        symbolOfTicker = crypto.symbolOfTicker ?? ""

        chartLoad(symbol: symbolOfCurrentCrypto, interval: "day")
        lineChartViewSetup()
        navigationBarSetup()
        
//        diffPriceOfCrypto.text = diffPriceOfCryptoText
//        priceOfCrypto.text = priceOfCryptoText
//        nameOfCrypto.text = nameOfCryptoText

        if textTest.isEmpty {
            DispatchQueue.global().async {
                NetworkManager.shared.getCoinGeckoData(symbol: self.idOfCrypto, group: NetworkManager.shared.groupOne) { (stocks) in
                    DispatchQueue.main.async {
                        self.textView.text = stocks.geckoSymbolDescription?.en
                        self.tableView.reloadData()
                    }
                }
            }
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
            object.name = nameOfCrypto.text
            object.descrtiption = textView.text
            object.date = Date()
            
            
            do {
                try context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            NetworkManager.shared.favorites.insert(object, at: 0)
            NetworkManager.shared.addData(object: object)
            
//            NetworkManager.shared.coinCap2(arrayOfResults: NetworkManager.shared.resultsF, elems: NetworkManager.shared.coinCapDict)
            NetworkManager.shared.webSocket(symbols: NetworkManager.shared.symbols, symbolsF: NetworkManager.shared.symbolsF)

        }
        bool.toggle()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
  
    }

    @IBAction func dayChartButton(_ sender: Any) {
        values.removeAll()
        chartLoad(symbol: symbolOfCurrentCrypto, interval: "day")
    }
    @IBAction func monthChartButton(_ sender: Any) {
        values.removeAll()
        chartLoad(symbol: symbolOfCurrentCrypto, interval: "month")
    }
    @IBAction func yearChartButton(_ sender: Any) {
        values.removeAll()
        chartLoad(symbol: symbolOfCurrentCrypto, interval: "year")
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
    
    
    func chartLoad(symbol : String, interval : String) {
        
        DispatchQueue.global().async {
            NetworkManager.shared.getFinHubData(symbol: symbol, interval: interval, group: NetworkManager.shared.groupTwo) { (dict) in
                let stocks = dict["stocks"] as! GetData
                let dateFormat = dict["dateFormat"] as! String
                
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
                    self.priceOfCrypto.text = String(stockLast)
                    self.setData()
                    self.lineChartView.xAxis.valueFormatter = MyXAxisFormatter(dateFormat: dateFormat)
                    self.lineChartViewSetup()
                }
            }
        }
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
