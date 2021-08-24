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
    var percentages = Persentages()
    
    // UI
    let scrollView = UIScrollView()
    let contentView = UIView()
    let chartAndPriceView : UIView = {
        let chart = UIView()
        chart.backgroundColor = UIColor(hexString: "#4158B7")
        return chart
    }()
    let detailInfoView : UIView = {
        let view = UIView()
        return view
    }()
    let lineChartView : LineChartView = {
        var chart = LineChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        return chart
    }()
    let marketDataTableView = UITableView()
    let communityDataTableView = UITableView()
    var contentViewFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 1500)
    var detailInfoViewFrame = CGRect(x: 15, y: 600, width: UIScreen.main.bounds.size.width - 30, height: 940)
    
    func setupScrollView(){
//        contentView.translatesAutoresizingMaskIntoConstraints = false
        chartAndPriceView.frame = CGRect(x:0.0, y:0.0, width: view.frame.size.width, height: 600)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(chartAndPriceView)
        contentView.backgroundColor = UIColor(hexString: "#4158B7")
        

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
        scrollView.backgroundColor = UIColor(hexString: "#4158B7")
        scrollView.contentSize = CGSize(width: self.view.bounds.size.width, height: chartAndPriceView.frame.height + detailInfoView.frame.height)

        
        }
    var count = 0
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        label.font = UIFont(name: "avenir", size: 30)
        label.sizeToFit()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let diffPriceOfCrypto: UILabel = {
        let label = UILabel()
        label.text = "diffPriceOfCrypto"
        label.numberOfLines = 0
        label.font = UIFont(name: "avenir", size: 15)
        label.sizeToFit()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var computedDiffPrice : String {
        get {
            return diffPriceOfCrypto.text!
        }
        set(newValue) {
            if newValue.hasPrefix("-") {
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = UIImage(systemName: "arrowtriangle.down.fill")?.withTintColor(.red)
                
                let fullString = NSMutableAttributedString()
                fullString.append(NSAttributedString(attachment: imageAttachment))
                
                var copyOfNewValue = newValue
                copyOfNewValue.removeFirst()
                fullString.append(NSAttributedString(string: " \(copyOfNewValue)%"))
                
                diffPriceOfCrypto.attributedText = fullString
                diffPriceOfCrypto.textColor = UIColor(hexString: "#CC2B73")
            } else {
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = UIImage(systemName: "arrowtriangle.up.fill")?.withTintColor(.green)
                
                let fullString = NSMutableAttributedString()
                fullString.append(NSAttributedString(attachment: imageAttachment))
                fullString.append(NSAttributedString(string: " \(newValue)%"))
                
                diffPriceOfCrypto.attributedText = fullString
                diffPriceOfCrypto.textColor = UIColor.green
            }
        }
    }
    
    var dayChartButton : UIButton = {
        let button = UIButton(setTitle: "day")
        button.addTarget(self,
                         action: #selector(dayChartButtonLoad),
                         for: .touchUpInside)
        button.layer.cornerRadius = 4
        button.backgroundColor = UIColor(red: 0.324, green: 0.424, blue: 0.854, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    @objc func dayChartButtonLoad() {
        values.removeAll()
        DispatchQueue.main.async {
            self.dayChartButton.backgroundColor = UIColor(red: 0.324, green: 0.424, blue: 0.854, alpha: 1)
            self.weekChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.monthChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.yearChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.chartLoad(idOfCrypto: self.idOfCrypto, interval: "day")
//            self.diffPriceOfCrypto.text = self.percentages.priceChangePercentage24H
            if let percent = self.percentages.priceChangePercentage24H {
            self.computedDiffPrice = percent
            }
            
        }
        
    }
    var weekChartButton : UIButton = {
        let button = UIButton(setTitle: "week")
        button.addTarget(self,
                         action: #selector(weekChartButtonLoad),
                         for: .touchUpInside)
        button.layer.cornerRadius = 4
        button.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    @objc func weekChartButtonLoad() {
        values.removeAll()
        DispatchQueue.main.async {
            self.dayChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.weekChartButton.backgroundColor = UIColor(red: 0.324, green: 0.424, blue: 0.854, alpha: 1)
            self.monthChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.yearChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.chartLoad(idOfCrypto: self.idOfCrypto, interval: "week")
//            self.diffPriceOfCrypto.text = self.percentages.priceChangePercentage24H
            if let percent = self.percentages.priceChangePercentage7D {
            self.computedDiffPrice = percent
            }
        }
        
    }
    var monthChartButton : UIButton = {
        let button = UIButton(setTitle: "month")
        button.addTarget(self,
                         action: #selector(monthChartButtonLoad),
                         for: .touchUpInside)
        button.layer.cornerRadius = 4
        button.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    @objc func monthChartButtonLoad() {
        values.removeAll()
        DispatchQueue.main.async {
            self.dayChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.weekChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.monthChartButton.backgroundColor = UIColor(red: 0.324, green: 0.424, blue: 0.854, alpha: 1)
            self.yearChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.chartLoad(idOfCrypto: self.idOfCrypto, interval: "month")
//            self.diffPriceOfCrypto.text = self.percentages.priceChangePercentage30D
            if let percent = self.percentages.priceChangePercentage30D {
            self.computedDiffPrice = percent
            }
        }
    }
    var yearChartButton : UIButton = {
        let button = UIButton(setTitle: "year")
        button.addTarget(self,
                         action: #selector(yearChartButtonLoad),
                         for: .touchUpInside)
        button.layer.cornerRadius = 4
        button.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    @objc func yearChartButtonLoad() {
        values.removeAll()
        DispatchQueue.main.async {
            self.dayChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.weekChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.monthChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.yearChartButton.backgroundColor = UIColor(red: 0.324, green: 0.424, blue: 0.854, alpha: 1)
            self.chartLoad(idOfCrypto: self.idOfCrypto, interval: "year")
//            self.diffPriceOfCrypto.text = self.percentages.priceChangePercentage1Y
            if let percent = self.percentages.priceChangePercentage1Y {
            self.computedDiffPrice = percent
            }
        }
    }
    
    let onRedditButton : UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.969, green: 0.576, blue: 0.102, alpha: 1)
        button.layer.cornerRadius = 14
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Reddit", for: .normal)
        button.addTarget(self,
                         action: #selector(onReddit),
                         for: .touchUpInside)
        return button
    }()
    let onSiteButton : UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor(red: 0.969, green: 0.576, blue: 0.102, alpha: 1).cgColor
        button.setTitleColor(UIColor(red: 0.969, green: 0.576, blue: 0.102, alpha: 1), for: .normal)
        button.setTitle("Website", for: .normal)
        button.addTarget(self,
                         action: #selector(onSite),
                         for: .touchUpInside)
        return button
    }()

 
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
        

        
        let buttonsView = UIView()
        buttonsView.layer.cornerRadius = 7
        buttonsView.layer.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1).cgColor
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        
        chartAndPriceView.addSubview(buttonsView)
        buttonsView.centerXAnchor.constraint(equalTo: chartAndPriceView.centerXAnchor).isActive = true
        buttonsView.bottomAnchor.constraint(equalTo: chartAndPriceView.bottomAnchor).isActive = true
        buttonsView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        buttonsView.widthAnchor.constraint(equalTo: chartAndPriceView.widthAnchor, constant: -20).isActive = true
        
        buttonsView.addSubview(dayChartButton)
        dayChartButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor, constant: 3).isActive = true
        dayChartButton.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: 3).isActive = true
        dayChartButton.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.size.width - 46) / 4).isActive = true
        dayChartButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        buttonsView.addSubview(weekChartButton)
        weekChartButton.leadingAnchor.constraint(equalTo: dayChartButton.trailingAnchor, constant: 5).isActive = true
        weekChartButton.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: 3).isActive = true
        weekChartButton.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.size.width - 46) / 4).isActive = true
        weekChartButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        buttonsView.addSubview(monthChartButton)
        monthChartButton.leadingAnchor.constraint(equalTo: weekChartButton.trailingAnchor, constant: 5).isActive = true
        monthChartButton.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: 3).isActive = true
        monthChartButton.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.size.width - 46) / 4).isActive = true
        monthChartButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        buttonsView.addSubview(yearChartButton)
        yearChartButton.leadingAnchor.constraint(equalTo: monthChartButton.trailingAnchor, constant: 5).isActive = true
        yearChartButton.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: 3).isActive = true
        yearChartButton.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.size.width - 46) / 4).isActive = true
        yearChartButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        
//        chartAndPriceView.addSubview(ButtonsStackView)
//        ButtonsStackView.centerXAnchor.constraint(equalTo: chartAndPriceView.centerXAnchor).isActive = true
//        ButtonsStackView.bottomAnchor.constraint(equalTo: chartAndPriceView.bottomAnchor).isActive = true
//        ButtonsStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        ButtonsStackView.widthAnchor.constraint(equalTo: chartAndPriceView.widthAnchor, constant: -20).isActive = true
        
        chartAndPriceView.addSubview(lineChartView)
        lineChartView.centerXAnchor.constraint(equalTo: chartAndPriceView.centerXAnchor).isActive = true
        lineChartView.topAnchor.constraint(equalTo: diffPriceOfCrypto.bottomAnchor, constant: 10).isActive = true
        lineChartView.widthAnchor.constraint(equalTo: chartAndPriceView.widthAnchor, constant: -20).isActive = true
        lineChartView.bottomAnchor.constraint(equalTo: buttonsView.topAnchor, constant: -5).isActive = true
       }

    
    func setupDetailInfo() {
        let title = UILabel(); title.text = "Description"; title.textColor = .white; title.font = UIFont(name: "avenir", size: 22)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
        let image = UIImage(systemName: "chevron.down", withConfiguration: imageConfig)
        let button : UIButton = {
            let button = UIButton(type: .custom)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: 60).isActive = true
            button.heightAnchor.constraint(equalToConstant: 60).isActive = true
            button.imageView?.contentMode = .scaleAspectFit
            button.imageView?.tintColor = .white
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
        
        marketDataTableView.backgroundColor = UIColor(hexString: "#4158B7")
        communityDataTableView.backgroundColor = UIColor(hexString: "#4158B7")
        detailInfoView.addSubview(marketDataTableView)
        detailInfoView.addSubview(communityDataTableView)
        detailInfoView.addSubview(headerStack)
        detailInfoView.addSubview(textView)
        
        let marketDatatitle = UILabel(); marketDatatitle.text = "marketDataTableView"; marketDatatitle.textColor = .white
        marketDatatitle.font = UIFont(name: "avenir", size: 22)
        marketDatatitle.translatesAutoresizingMaskIntoConstraints = false
        detailInfoView.addSubview(marketDatatitle)
   
        
        marketDatatitle.topAnchor.constraint(equalTo: detailInfoView.topAnchor, constant: 29).isActive = true
        marketDatatitle.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor).isActive = true

        marketDataTableView.translatesAutoresizingMaskIntoConstraints = false
        marketDataTableView.topAnchor.constraint(equalTo: marketDatatitle.bottomAnchor, constant: 10).isActive = true
        marketDataTableView.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor).isActive = true
        marketDataTableView.heightAnchor.constraint(equalToConstant: 250).isActive = true

        headerStack.topAnchor.constraint(equalTo: marketDataTableView.bottomAnchor, constant: 18).isActive = true
        headerStack.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor).isActive = true
        headerStack.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        let communityDatatitle = UILabel(); communityDatatitle.text = "communityDatatitle"; communityDatatitle.textColor = .white
        communityDatatitle.font = UIFont(name: "avenir", size: 22)
        communityDatatitle.translatesAutoresizingMaskIntoConstraints = false
        detailInfoView.addSubview(communityDatatitle)

        textView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 14).isActive = true
        textView.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: communityDatatitle.topAnchor, constant: -18).isActive = true
       
        communityDatatitle.topAnchor.constraint(equalTo: textView.bottomAnchor).isActive = true
        communityDatatitle.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor).isActive = true
        communityDatatitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
        communityDatatitle.bottomAnchor.constraint(equalTo: communityDataTableView.topAnchor).isActive = true
        

        communityDataTableView.translatesAutoresizingMaskIntoConstraints = false
        communityDataTableView.topAnchor.constraint(equalTo: communityDatatitle.bottomAnchor).isActive = true
        communityDataTableView.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor).isActive = true
        communityDataTableView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        
        var arrangedSubviews : [UIView] = []
        if redditUrl == "" || redditUrl.isEmpty || redditUrl == "https://reddit.com" {
            arrangedSubviews = [onSiteButton]
        } else if siteUrl == "" || siteUrl.isEmpty {
            arrangedSubviews = [onRedditButton]
        } else {
            arrangedSubviews = [onRedditButton, onSiteButton]
        }
        
        let buttonsStack = UIStackView(arrangedSubviews: arrangedSubviews)
        buttonsStack.axis = .vertical
        buttonsStack.distribution = .fillEqually
        buttonsStack.spacing = 11
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false

        detailInfoView.addSubview(buttonsStack)
        buttonsStack.topAnchor.constraint(equalTo: communityDataTableView.bottomAnchor, constant: 10).isActive = true
        buttonsStack.centerXAnchor.constraint(equalTo: detailInfoView.centerXAnchor).isActive = true
        buttonsStack.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor, constant: -2).isActive = true
        
        if buttonsStack.arrangedSubviews.count == 1 {
            buttonsStack.heightAnchor.constraint(equalToConstant: 56).isActive = true
            scrollView.contentInset.bottom -= 67
        } else if buttonsStack.arrangedSubviews.count == 2 {
        buttonsStack.heightAnchor.constraint(equalToConstant: 123).isActive = true
        } else {
            buttonsStack.heightAnchor.constraint(equalToConstant: 0).isActive = true
            scrollView.contentInset.bottom -= 123
        }
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
            scrollView.contentInset.bottom += (height - textView.frame.height)
            contentViewFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: contentViewFrame.height + height - constHeightOfTextLabel)
            contentView.frame = contentViewFrame
            detailInfoViewFrame = CGRect(x: 15, y: 600, width: UIScreen.main.bounds.size.width - 30, height: detailInfoViewFrame.height + height - constHeightOfTextLabel)
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
    

    let textView : UILabel = {
        let textView = UILabel()
        textView.translatesAutoresizingMaskIntoConstraints = false
//        textView.layer.cornerRadius = 15
        textView.layer.masksToBounds = true
        textView.numberOfLines = 7
        textView.lineBreakMode = .byTruncatingTail
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = .white
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
        if let textTestCheck = crypto.descriptionOfCrypto?.html2String {
            textView.text = textTestCheck
        }
        
        if let nameOfCryptoCheck = crypto.nameOfCrypto {
        nameOfCrypto.text = nameOfCryptoCheck
        }
        if let percentagesCheck = crypto.percentages {
            percentages = percentagesCheck
        }

//        diffPriceOfCrypto.text = percentages.priceChangePercentage24H
        if let percent = self.percentages.priceChangePercentage24H {
        self.computedDiffPrice = percent
        }
        
        if let priceOfCryptoCheck = crypto.price {
        priceOfCrypto.text?.removeAll()
        priceOfCrypto.text?.append("$")
        priceOfCrypto.text?.append(priceOfCryptoCheck)
        }
        idOfCrypto = crypto.id!
        
        if let symbolOfTickerCheck = crypto.symbolOfTicker {
        symbolOfTicker = symbolOfTickerCheck
        }
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
        navigationBarSetup()
        chartLoad(idOfCrypto: idOfCrypto, interval: "day")
        
        lineChartViewSetup()
        marketDataTableView.register(MarketDataCell.self, forCellReuseIdentifier: "MarketDataCell")
        marketDataTableView.delegate = self
        marketDataTableView.dataSource = self
        communityDataTableView.register(MarketDataCell.self, forCellReuseIdentifier: "MarketDataCell")
        communityDataTableView.delegate = self
        communityDataTableView.dataSource = self
        scrollView.delegate = self
   
        
        if priceOfCrypto.text == "priceOfCrypto" {
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
                        
                        if self.textView.text == nil || self.textView.text == "" {
                            self.contentViewFrame.size.height -= 50
                            self.detailInfoViewFrame.size.height -= 50
                            self.scrollView.contentInset.bottom -= 50
                        } else if self.textView.text!.count / 45 < 7 {
                            let height = CGFloat((7 - (self.textView.text!.count / 45)) * 10)
                            print("HEIGHT", height)
                            self.contentViewFrame.size.height -= height
                            self.detailInfoViewFrame.size.height -= height
                            self.scrollView.contentInset.bottom -= height
                            
                        }
                        
                        if let redditUrl = stocks.links?.subredditURL {
                        self.redditUrl = redditUrl
                        }
                        if let siteUrl = stocks.links?.homepage?.first {
                        self.siteUrl = siteUrl
                        }
                        self.diffPriceOfCrypto.text = String((stocks.marketData?.priceChangePercentage30D)!)
                        self.percentages = Persentages(priceChangePercentage24H: String((stocks.marketData?.priceChangePercentage24H)!),
                                                      priceChangePercentage7D: String((stocks.marketData?.priceChangePercentage7D)!),
                                                      priceChangePercentage30D: String((stocks.marketData?.priceChangePercentage30D)!),
                                                      priceChangePercentage1Y: String((stocks.marketData?.priceChangePercentage1Y)!))
            
                        
                        self.priceOfCrypto.text = String((stocks.marketData?.currentPrice?["usd"])!)
                        
                        if let marketData = stocks.marketData {
                            self.marketData = MarketDataArray(marketData: marketData).array
                            self.marketDataTableView.reloadData()
                        }
                        if let communityData = stocks.communityData {
                        self.communityData = CommunityDataArray(communityData: communityData).array
                        self.communityDataTableView.reloadData()
                        }
                        self.setupDetailInfo()
                        self.scrollView.contentInset.bottom += 67
                        
                    }
                }
            }
        } else {
            if self.textView.text == nil || self.textView.text == "" {
                self.contentViewFrame.size.height -= 50
                self.detailInfoViewFrame.size.height -= 50
                self.scrollView.contentInset.bottom -= 50
            }
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
            navigationController?.navigationBar.backItem?.title = ""
            navigationController?.navigationBar.barTintColor = UIColor(hexString: "#202F72")
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
//            navigationItem.title = nameOfCrypto.text
//            navigationController?.navigationBar.topItem?.title = nameOfCrypto.text
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.rightBarButtonItem = butt
            navigationItem.rightBarButtonItem?.tintColor = .white
            navigationController!.navigationBar.tintColor = .white
            
            
        let logoAndTitle = UIView()
        
        let label : UILabel = {
            let label = UILabel()
            label.text = self.nameOfCrypto.text
            label.textColor = .white
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
        lineChartView.backgroundColor = UIColor(hexString: "#4158B7")
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
            
            let nowUnix = Int(NSDate().timeIntervalSince1970)
            var prevValue = Int()
            var dateFormat = String()
            
            switch interval {
            case "day":
                dateFormat = "HH:mm"
                prevValue = Int((Calendar.current.date(byAdding: .day, value: -1, to: Date()))!.timeIntervalSince1970)
            case "week":
                dateFormat = "E HH:mm"
                prevValue = Int((Calendar.current.date(byAdding: .day, value: -7, to: Date()))!.timeIntervalSince1970)
            case "month":
                dateFormat = "MMM d"
                prevValue = Int((Calendar.current.date(byAdding: .month, value: -1, to: Date()))!.timeIntervalSince1970)
            case "year":
                dateFormat = "dd.MM.yy"
                prevValue = Int((Calendar.current.date(byAdding: .year, value: -1, to: Date()))!.timeIntervalSince1970)
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
                print("RESPONSE" ,response)
                do {
                    guard let stocks = try CoinGeckoPrice.decode(from: stocksData) else {return}
                    print("DATA", stocks)
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
        cell.backgroundColor = UIColor(hexString: "#4158B7")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
