//
//  ChartViewController.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 06.04.2021.
//

import UIKit
import Charts
import CoreData
import SafariServices

class ChartViewController: UIViewController, ChartViewDelegate {
    
    
    let finHubToken = Constants.finHubToken
    var values: [ChartDataEntry] = []
    var textTest = String()
    var image = UIImage()
    var imageString = String()
    var symbolOfCurrentCrypto = String()
    var symbolOfTicker = String()
    var marketData = [MarketDataElem]()
    var communityData = [MarketDataElem]()
    var idOfCrypto = String()
    let imageOfHeart = UIImage(systemName: "heart")
    let imageOfHeartFill = UIImage(systemName: "heart.fill")
    var bool = false
    var diffPriceOfCryptoText = String()
    var priceOfCryptoText = String()
    var nameOfCryptoText = String()
    var crypto = Crypto(symbolOfCrypto: "", price: "", change: "", nameOfCrypto: "", descriptionOfCrypto: "", symbolOfTicker: "", id: "", percentages: nil, image: UIImage(named: "pngwing.com")!)
    var redditUrl = String()
    var siteUrl = String()
    
    // UI
    let scrollView = UIScrollView()
    let contentView = UIView()
    let chartAndPriceView = UIView()
    let detailInfoView = UIView()
    let lineChartView : LineChartView = {
        var chart = LineChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        return chart
    }()
    let marketDataTableView = UITableView()
    let communityDataTableView = UITableView()
    var contentViewFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 1400)
    var detailInfoViewFrame = CGRect(x: 0, y: 500, width: UIScreen.main.bounds.size.width, height: 900)
    
    func setupScrollView(){
//        contentView.translatesAutoresizingMaskIntoConstraints = false
        chartAndPriceView.frame = CGRect(x:0.0, y:0.0, width: view.frame.size.width, height: 500)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(chartAndPriceView)
        
        

//        contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
//        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
//        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
//        contentView.heightAnchor.constraint(equalToConstant: 1400).isActive = true
        
        contentView.frame = contentViewFrame

        
        contentView.addSubview(detailInfoView)
//        detailInfoView.translatesAutoresizingMaskIntoConstraints = false
//        detailInfoView.topAnchor.constraint(equalTo: chartAndPriceView.bottomAnchor).isActive = true
//        detailInfoView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
//        detailInfoView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -20).isActive = true
//        detailInfoView.heightAnchor.constraint(equalToConstant: 900).isActive = true
        
        detailInfoView.frame = detailInfoViewFrame
        
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 50)
        scrollView.contentSize = CGSize(width: self.view.bounds.size.width, height: chartAndPriceView.frame.height + detailInfoView.frame.height)

        
        }
    var count = 0
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("viewDidLayoutSubviews")
        if count < 3 {
        setupScrollView()
        }
        count += 1
        print(contentView.frame.height)
    }
    
    
    let nameOfCrypto: UILabel = {
        let label = UILabel()
        label.text = "nameOfCrypto"
        label.numberOfLines = 0
        label.sizeToFit()
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let priceOfCrypto: UILabel = {
        let label = UILabel()
        label.text = "priceOfCrypto"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 30.0)
        label.sizeToFit()
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let diffPriceOfCrypto: UILabel = {
        let label = UILabel()
        label.text = "diffPriceOfCrypto"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 20.0)
        label.sizeToFit()
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    let dayChartButton : UIButton = {
        let button = UIButton(setTitle: "day")
        button.addTarget(self,
                         action: #selector(dayChartButtonLoad),
                         for: .touchUpInside)
        return button
        
    }()
    @objc func dayChartButtonLoad() {
        values.removeAll()
        DispatchQueue.main.async {
            self.chartLoad(idOfCrypto: self.idOfCrypto, interval: "day")
            self.diffPriceOfCrypto.text = self.crypto.percentages?.priceChangePercentage24H
            
        }
        
    }
    let monthChartButton : UIButton = {
        let button = UIButton(setTitle: "month")
        button.addTarget(self,
                         action: #selector(monthChartButtonLoad),
                         for: .touchUpInside)
        return button
        
    }()
    @objc func monthChartButtonLoad() {
        values.removeAll()
        DispatchQueue.main.async {
            self.chartLoad(idOfCrypto: self.idOfCrypto, interval: "month")
            self.diffPriceOfCrypto.text = self.crypto.percentages?.priceChangePercentage30D
        }
    }
    let yearChartButton : UIButton = {
        let button = UIButton(setTitle: "year")
        button.addTarget(self,
                         action: #selector(yearChartButtonLoad),
                         for: .touchUpInside)
        return button
        
    }()
    @objc func yearChartButtonLoad() {
        values.removeAll()
        DispatchQueue.main.async {
            self.chartLoad(idOfCrypto: self.idOfCrypto, interval: "year")
            self.diffPriceOfCrypto.text = self.crypto.percentages?.priceChangePercentage1Y
        }
    }

 
    func setupChartAndPriceView(){
        chartAndPriceView.addSubview(priceOfCrypto)
        
        priceOfCrypto.centerXAnchor.constraint(equalTo: chartAndPriceView.centerXAnchor).isActive = true
        priceOfCrypto.topAnchor.constraint(equalTo: chartAndPriceView.topAnchor).isActive = true
//        nameOfCrypto.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
//        nameOfCrypto.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1/3).isActive = true
        
        chartAndPriceView.addSubview(diffPriceOfCrypto)
        diffPriceOfCrypto.centerXAnchor.constraint(equalTo: chartAndPriceView.centerXAnchor).isActive = true
        diffPriceOfCrypto.topAnchor.constraint(equalTo: priceOfCrypto.bottomAnchor, constant: 5).isActive = true
//        nameOfCrypto.leadingAnchor.constraint(equalTo: nameOfCrypto.trailingAnchor, constant: 5).isActive = true
//        priceOfCrypto.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1/3).isActive = true
//        diffPriceOfCrypto.bottomAnchor.constraint(equalTo: chartAndPriceView.bottomAnchor).isActive = true
        diffPriceOfCrypto.backgroundColor = .red
        
        
        let ButtonsStackView = UIStackView(arrangedSubviews: [dayChartButton,monthChartButton,yearChartButton])
        ButtonsStackView.axis = .horizontal
        ButtonsStackView.distribution = .fillEqually
        ButtonsStackView.alignment = .fill
        ButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        chartAndPriceView.addSubview(ButtonsStackView)
        ButtonsStackView.centerXAnchor.constraint(equalTo: chartAndPriceView.centerXAnchor).isActive = true
        ButtonsStackView.bottomAnchor.constraint(equalTo: chartAndPriceView.bottomAnchor).isActive = true
        ButtonsStackView.widthAnchor.constraint(equalTo: chartAndPriceView.widthAnchor, constant: -20).isActive = true
        
        chartAndPriceView.addSubview(lineChartView)
        lineChartView.centerXAnchor.constraint(equalTo: chartAndPriceView.centerXAnchor).isActive = true
        lineChartView.topAnchor.constraint(equalTo: diffPriceOfCrypto.bottomAnchor, constant: 10).isActive = true
        lineChartView.widthAnchor.constraint(equalTo: chartAndPriceView.widthAnchor, constant: -20).isActive = true
        lineChartView.bottomAnchor.constraint(equalTo: dayChartButton.topAnchor, constant: -5).isActive = true

                
        chartAndPriceView.backgroundColor = .systemGray

       }

    
    func setupDetailInfo() {
        let title = UILabel(); title.text = "Description"
        let image = UIImage(systemName: "arrowtriangle.down.circle")
        let button : UIButton = {
            let button = UIButton(type: .custom)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
            button.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
//            button.backgroundColor = .cyan
            button.setImage(image, for: .normal)
            
//            button.setBackgroundImage(image, for: .normal)
            button.addTarget(self,
                             action: #selector(loadMore),
                             for: .touchUpInside)
//            button.imageView?.contentMode = .scaleAspectFill
            return button
        }()

        let headerStack = UIStackView(arrangedSubviews: [title,button])
        headerStack.axis = .horizontal
//        headerStack.distribution = .equalSpacing
        headerStack.setCustomSpacing(10, after: title)
        headerStack.alignment = .fill
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        
        
        detailInfoView.addSubview(marketDataTableView)
        detailInfoView.addSubview(communityDataTableView)
        detailInfoView.addSubview(headerStack)
        detailInfoView.addSubview(textView)
        
        let marketDatatitle = UILabel(); marketDatatitle.text = "marketDataTableView"; marketDatatitle.translatesAutoresizingMaskIntoConstraints = false
        detailInfoView.addSubview(marketDatatitle)
   
        
        marketDatatitle.topAnchor.constraint(equalTo: detailInfoView.topAnchor, constant: 10).isActive = true
        marketDatatitle.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor).isActive = true

        marketDataTableView.translatesAutoresizingMaskIntoConstraints = false
        marketDataTableView.topAnchor.constraint(equalTo: marketDatatitle.bottomAnchor, constant: 10).isActive = true
        marketDataTableView.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor).isActive = true
        marketDataTableView.heightAnchor.constraint(equalToConstant: 250).isActive = true

        headerStack.topAnchor.constraint(equalTo: marketDataTableView.bottomAnchor, constant: 10).isActive = true
        headerStack.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor).isActive = true
        headerStack.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        let communityDatatitle = UILabel(); communityDatatitle.text = "communityDatatitle"; communityDatatitle.translatesAutoresizingMaskIntoConstraints = false
        detailInfoView.addSubview(communityDatatitle)

        textView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 10).isActive = true
        textView.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: communityDatatitle.topAnchor, constant: -10).isActive = true
        
        communityDatatitle.topAnchor.constraint(equalTo: textView.bottomAnchor).isActive = true
        communityDatatitle.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor).isActive = true
        communityDatatitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
        communityDatatitle.bottomAnchor.constraint(equalTo: communityDataTableView.topAnchor).isActive = true

        communityDataTableView.translatesAutoresizingMaskIntoConstraints = false
        communityDataTableView.topAnchor.constraint(equalTo: communityDatatitle.bottomAnchor).isActive = true
        communityDataTableView.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor).isActive = true
        communityDataTableView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        
        
        
        let onRedditButton : UIButton = {
            let button = UIButton(type: .custom)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = .orange
            button.addTarget(self,
                             action: #selector(onReddit),
                             for: .touchUpInside)
            return button
        }()
        let onRedditButton2 : UIButton = {
            let button = UIButton(type: .custom)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = .blue
            button.addTarget(self,
                             action: #selector(onSite),
                             for: .touchUpInside)
            return button
        }()
        
        var arrangedSubviews : [UIView] = []
        if redditUrl == "" || redditUrl.isEmpty || redditUrl == "https://reddit.com" {
            arrangedSubviews = [onRedditButton2]
        } else if siteUrl == "" || siteUrl.isEmpty {
            arrangedSubviews = [onRedditButton]
        } else {
            arrangedSubviews = [onRedditButton, onRedditButton2]
        }
        
        let buttonsStack = UIStackView(arrangedSubviews: arrangedSubviews)
        buttonsStack.axis = .vertical
        buttonsStack.distribution = .fillEqually
        buttonsStack.spacing = 20
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false

        detailInfoView.addSubview(buttonsStack)
        buttonsStack.topAnchor.constraint(equalTo: communityDataTableView.bottomAnchor, constant: 10).isActive = true
        buttonsStack.centerXAnchor.constraint(equalTo: detailInfoView.centerXAnchor).isActive = true
        buttonsStack.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor, constant: -20).isActive = true
        if buttonsStack.arrangedSubviews.count == 1 {
            buttonsStack.heightAnchor.constraint(equalToConstant: 50).isActive = true
            scrollView.contentInset.bottom -= 50
        } else if buttonsStack.arrangedSubviews.count == 2 {
        buttonsStack.heightAnchor.constraint(equalToConstant: 120).isActive = true
        } else {
            buttonsStack.heightAnchor.constraint(equalToConstant: 0).isActive = true
            scrollView.contentInset.bottom -= 100
        }
        
       
//        buttonsStack.bottomAnchor.constraint(equalTo: detailInfoView.bottomAnchor, constant: 40).isActive = true
        
//        detailInfoView.addSubview(onRedditButton)
//        onRedditButton.topAnchor.constraint(equalTo: communityDataTableView.bottomAnchor).isActive = true
//        onRedditButton.centerXAnchor.constraint(equalTo: detailInfoView.centerXAnchor).isActive = true
//        onRedditButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        onRedditButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
        
    
    }
    
    @objc func onReddit() {
        guard let url = URL(string: redditUrl) else {return}
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    @objc func onSite() {
        guard let url = URL(string: siteUrl) else {return}
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    
    
    var clickBool = true
    var constHeightOfTextLabel = CGFloat()
    @objc func loadMore() {
        if clickBool == true {
            textView.numberOfLines = 0
            textView.lineBreakMode = .byWordWrapping
            constHeightOfTextLabel = textView.frame.height
            let height = textView.systemLayoutSizeFitting(CGSize(width: textView.frame.width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
            scrollView.contentInset.bottom += height - textView.frame.height
//            contentView.heightAnchor.constraint(equalToConstant: 1400).isActive = false
//            detailInfoView.heightAnchor.constraint(equalToConstant: 900).isActive = false
//            contentView.heightAnchor.constraint(equalToConstant: 1400 + height).isActive = true
//            detailInfoView.heightAnchor.constraint(equalToConstant: 900 + height).isActive = true
//            contentView.removeConstraints([
//                detailInfoView.heightAnchor.constraint(equalToConstant: 900)
//            ])
//            detailInfoView.removeConstraints([
//                detailInfoView.heightAnchor.constraint(equalToConstant: 900)
//            ])
//            view.removeConstraint(contentView.heightAnchor.constraint(equalToConstant: 1400))
//            view.removeConstraint(detailInfoView.heightAnchor.constraint(equalToConstant: 900))
//            NSLayoutConstraint.deactivate([
//                contentView.heightAnchor.constraint(equalToConstant: 1400),
//                detailInfoView.heightAnchor.constraint(equalToConstant: 900)
//
//            ])
//            NSLayoutConstraint.activate([
//                contentView.heightAnchor.constraint(equalToConstant: 1400 + height),
//                detailInfoView.heightAnchor.constraint(equalToConstant: 900 + height)
//
//            ])
//
//            contentView.updateConstraints()
//            detailInfoView.updateConstraints()
//            view.updateConstraints()
//            view.updateConstraintsIfNeeded()
//            view.layoutIfNeeded()
//            view.setNeedsLayout()
            contentViewFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 2000)
            contentView.frame = contentViewFrame
            detailInfoViewFrame = CGRect(x: 0, y: 500, width: UIScreen.main.bounds.size.width, height: 1200)
            detailInfoView.frame = detailInfoViewFrame
//            view.layoutIfNeeded()
            
            
        } else {
            textView.numberOfLines = 7
            textView.lineBreakMode = .byTruncatingTail
            scrollView.contentInset.bottom -= textView.frame.height
            scrollView.contentInset.bottom += constHeightOfTextLabel
            scrollView.contentOffset = CGPoint(x: 0, y: 500)
          
        }
        clickBool.toggle()
        
        

    }
    
//    let textView : UITextView = {
//        let textView = UITextView()
//        textView.translatesAutoresizingMaskIntoConstraints = false
////        textView.layer.cornerRadius = 15
//        textView.layer.masksToBounds = true
//        textView.font = UIFont.systemFont(ofSize: 15)
//        textView.isEditable = false
//        textView.sizeToFit()
//        textView.backgroundColor = .systemGray
//        textView.isScrollEnabled = false
//        return textView
//    }()
    let textView : UILabel = {
        let textView = UILabel()
        textView.translatesAutoresizingMaskIntoConstraints = false
//        textView.layer.cornerRadius = 15
        textView.layer.masksToBounds = true
        textView.numberOfLines = 7
        textView.lineBreakMode = .byTruncatingTail
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.sizeToFit()
        return textView
    }()
    
    
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
//        setupScrollView()
        symbolOfCurrentCrypto = crypto.symbolOfCrypto
        textTest = crypto.descriptionOfCrypto?.html2String ?? ""
        nameOfCrypto.text = crypto.nameOfCrypto ?? ""
        diffPriceOfCrypto.text = crypto.percentages?.priceChangePercentage24H ?? ""
        priceOfCrypto.text = crypto.price ?? ""
        idOfCrypto = crypto.id ?? ""
        symbolOfTicker = crypto.symbolOfTicker ?? ""
        image = crypto.image ?? UIImage(named: "pngwing.com")!
        if let marketDataChek = crypto.marketDataArray?.array {
        marketData = marketDataChek
        }
        if let communityDataChek = crypto.communityDataArray?.array {
        communityData = communityDataChek
        }
        if let redditLink = crypto.links?.subredditURL {
            redditUrl = redditLink
        }
        if let siteLink = crypto.links?.homepage?.first {
            siteUrl = siteLink
        }
        setupChartAndPriceView()
        setupDetailInfo()
        
//        chartLoad(symbol: symbolOfCurrentCrypto, interval: "day")
        print("ID", idOfCrypto)
        chartLoad(idOfCrypto: idOfCrypto, interval: "day")
        
        lineChartViewSetup()
        navigationBarSetup()
        marketDataTableView.register(MarketDataCell.self, forCellReuseIdentifier: "MarketDataCell")
        marketDataTableView.delegate = self
        marketDataTableView.dataSource = self
        communityDataTableView.register(MarketDataCell.self, forCellReuseIdentifier: "MarketDataCell")
        communityDataTableView.delegate = self
        communityDataTableView.dataSource = self
        scrollView.delegate = self


        if textTest == "" ||  marketData.isEmpty || communityData.isEmpty || image == UIImage(named: "pngwing.com")!{
            DispatchQueue.global().async {
                NetworkManager.shared.getCoinGeckoData(symbol: self.idOfCrypto, group: NetworkManager.shared.groupOne) { (stocks) in
                        if let stringUrl = stocks.image?.large {
                            NetworkManager.shared.obtainImage(StringUrl: stringUrl, group: DispatchGroup()) { image in
                                self.image = image
                                self.imageString = (stocks.image?.large)!
                                self.navigationBarSetup()
                            }
                        }
                    DispatchQueue.main.async {
                        self.textView.text = stocks.geckoSymbolDescription?.en?.html2String
                        self.redditUrl = (stocks.links?.subredditURL)!
                        self.siteUrl = (stocks.links?.homepage?.first)!
                        guard let marketData = stocks.marketData else {return}
                        self.marketData = MarketDataArray(marketData: marketData).array
                        self.marketDataTableView.reloadData()
                        guard let communityData = stocks.communityData else {return}
                        self.communityData = CommunityDataArray(communityData: communityData).array
                        self.communityDataTableView.reloadData()
                        
                        
                    }
                }
            }
        } else {
            textView.text = textTest
        }
    }
    
  
    
    private func navigationBarSetup() {
        DispatchQueue.main.async { [self] in
    
        let butt = UIBarButtonItem(image: imageOfHeart, style: .done, target: self, action: #selector(saveTapped))
        for i in NetworkManager.shared.favorites {
            if let symbol = i.symbol {
                if symbolOfCurrentCrypto == symbol {
                    bool = true
                    butt.image = imageOfHeartFill
                }
            }
        }
        
            navigationItem.title = nameOfCrypto.text
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.rightBarButtonItem = butt
    
        
        let logoAndTitle = UIView()
        
        let label : UILabel = {
            let label = UILabel()
            label.text = self.nameOfCrypto.text
            label.sizeToFit()
            label.center = logoAndTitle.center
            label.textAlignment = NSTextAlignment.center
            return label
        }()
        
        let logo : UIImageView = {
            let logo = UIImageView()
            logo.image = image
            let imageAspect = logo.image!.size.width/logo.image!.size.height
            logo.frame = CGRect(x: label.frame.origin.x-label.frame.size.height*imageAspect, y: label.frame.origin.y, width: label.frame.size.height*imageAspect, height: label.frame.size.height)
            logo.contentMode = UIView.ContentMode.scaleAspectFit
            return logo
        }()
        
        logoAndTitle.addSubview(label)
        logoAndTitle.addSubview(logo)
        navigationItem.titleView = logoAndTitle
        
        
        
//        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        navigationItem.backBarButtonItem?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
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
    
    
    private func lineChartViewSetup() {
        lineChartView.backgroundColor = .systemGray
        lineChartView.leftAxis.enabled = false
        lineChartView.xAxis.setLabelCount(5, force: false)
        lineChartView.rightAxis.setLabelCount(8, force: false)
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.animate(xAxisDuration: 0.8)
        
    }
    
//
//    func chartLoad(symbol : String, interval : String) {
//
//        DispatchQueue.global().async {
//            NetworkManager.shared.getFinHubData(symbol: symbol, interval: interval, group: NetworkManager.shared.groupTwo) { (dict) in
//                let stocks = dict["stocks"] as! GetData
//                let dateFormat = dict["dateFormat"] as! String
//
//                guard let stocksC = stocks.c else {return}
//                for (indexC,elemC) in stocksC.enumerated() {
//                    let elemT = stocks.t![indexC]
//                    let chartData = ChartDataEntry(x: Double(elemT), y: elemC)
//                    self.values.append(chartData)
//
//                }
//
//                guard let stockLast = stocksC.last else {return}
//                guard let stockFirst = stocksC.first else {return}
//
//                DispatchQueue.main.async {
//                    self.diffPriceOfCrypto.text = {
//                        return String((stockLast - stockFirst) / stockFirst * 100)
//                    }()
//                    self.priceOfCrypto.text = String(stockLast)
//                    self.setData()
//                    self.lineChartView.xAxis.valueFormatter = MyXAxisFormatter(dateFormat: dateFormat)
//                    self.lineChartViewSetup()
//                }
//            }
//        }
//    }
    
    
    func chartLoad(idOfCrypto: String,interval: String){
        
        DispatchQueue.global().async {
            
//            let nextMinuteUnix = Int((Calendar.current.date(byAdding: .minute, value: +1, to: Date()))!.timeIntervalSince1970)
            let nowUnix = Int(NSDate().timeIntervalSince1970)
           
            
            var prevValue = Int()
            var dateFormat = String()
            
            switch interval {
            case "day":
                let prevDayUnix = Int((Calendar.current.date(byAdding: .hour, value: -25, to: Date()))!.timeIntervalSince1970)
                dateFormat = "MM/dd HH:mm"
                prevValue = prevDayUnix
            case "month":
                let prevMonthUnix = Int((Calendar.current.date(byAdding: .day, value: -21, to: Date()))!.timeIntervalSince1970)
                dateFormat = "MMM d"
                prevValue = prevMonthUnix
            case "year":
                let prevYearUnix = Int((Calendar.current.date(byAdding: .month, value: -12, to: Date()))!.timeIntervalSince1970)
                dateFormat = "dd.MM.yy"
                prevValue = prevYearUnix
            case "week":
                let prevWeekUnix = Int((Calendar.current.date(byAdding: .day, value: -7, to: Date()))!.timeIntervalSince1970)
                dateFormat = "dd.MM.yy"
                prevValue = prevWeekUnix
            default:
                print("ПРОБЛЕМА В СВИЧ")
            }
            let request = NSMutableURLRequest(
                url: NSURL(string: "https://api.coingecko.com/api/v3/coins/\(idOfCrypto)/market_chart/range?vs_currency=usd&from=\(prevValue)&to=\(nowUnix)")! as URL,
                cachePolicy: .useProtocolCachePolicy,
                timeoutInterval: 10.0)
            request.httpMethod = "GET"
            
            
            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                guard let stocksData = data, error == nil, response != nil else {return}
                print("THREAD",Thread.current)
                
                do {
                    
                    guard let stocks = try CoinGeckoPrice.decode(from: stocksData) else {return}
                    
                    for i in stocks.prices! {
                        let chartData = ChartDataEntry(x: i[0], y: i[1])
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

extension ChartViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == marketDataTableView {
        return marketData.count
        } else {
            return communityData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MarketDataCell.reuseId, for: indexPath) as? MarketDataCell else {return UITableViewCell()}
        if tableView == marketDataTableView {
            let marketDataElem = marketData[indexPath.row]
            cell.configure(with: marketDataElem)
        } else {
            let communityDataElem = communityData[indexPath.row]
            cell.configure(with: communityDataElem)
        }
        return cell
    }
    
    
}


//// MARK: - SwiftUI
//import SwiftUI
//struct ViewControllerProvider: PreviewProvider {
//    static var previews: some View {
//        ContainerView().edgesIgnoringSafeArea(.all)
//    }
//
//    struct ContainerView: UIViewControllerRepresentable {
//
//        let viewController = ChartViewController()
//
//        func makeUIViewController(context: UIViewControllerRepresentableContext<ViewControllerProvider.ContainerView>) -> ChartViewController {
//            return viewController
//        }
//
//        func updateUIViewController(_ uiViewController: ViewControllerProvider.ContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<ViewControllerProvider.ContainerView>) {
//
//        }
//    }
//}
