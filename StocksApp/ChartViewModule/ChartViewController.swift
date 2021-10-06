//
//  ChartViewController.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 06.04.2021.
//

import UIKit
import Charts
//import CoreData
import SafariServices

protocol ChartViewControllerProtocol : UIViewController {
    
    func reloadCommunityDataTableView()
    func reloadMarketDataTableView()
//    func increaseScrollViewBottom (for number : CGFloat)
//    func setupDetailInfo()
    func updateContentViewFrame(contentViewFrameChange : CGFloat, detailInfoViewFrameChange : CGFloat, scrollViewChange : CGFloat)
    func navigationBarSetup()
    func setData(dataSet: LineChartDataSet, xAxisValueFormatter: ChartViewPresenter.MyXAxisFormatter)
    func lineChartViewSetup()
    func updateData()
}

class ChartViewController: UIViewController {
    
    var presenter : ChartViewPresenterProtocol!
    
    var scrollView = UIScrollView()
    private let contentView = UIView()
    
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
    var marketDataTableView = UITableView()
    var communityDataTableView = UITableView()
    private var contentViewFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 1470)
    private var detailInfoViewFrame = CGRect(x: 15, y: 600, width: UIScreen.main.bounds.size.width - 30, height: 870)
    
    func setupScrollView(){
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(chartAndPriceView)
        contentView.addSubview(detailInfoView)
        contentView.backgroundColor = UIColor(hexString: "#4158B7")
        detailInfoView.frame = detailInfoViewFrame
        
        chartAndPriceView.frame = CGRect(x:0.0, y: 0.0, width: view.frame.size.width, height: 600)
        contentView.frame = contentViewFrame
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 83)
        scrollView.backgroundColor = UIColor(hexString: "#4158B7")
        scrollView.contentSize = CGSize(width: self.view.bounds.size.width, height: chartAndPriceView.frame.height + detailInfoView.frame.height)
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
    
    let descriptionLabel : UILabel = {
        let textView = UILabel()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.masksToBounds = true
        textView.numberOfLines = 7
        textView.lineBreakMode = .byTruncatingTail
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = .white
        textView.sizeToFit()
        return textView
    }()
    
    private var computedDiffPrice : String {
        get {
            return diffPriceOfCrypto.text ?? ""
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
    
    @objc
    private func dayChartButtonLoad() {
        presenter.removeValues()
        DispatchQueue.main.async {
            self.dayChartButton.backgroundColor = UIColor(red: 0.324, green: 0.424, blue: 0.854, alpha: 1)
            self.weekChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.monthChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.yearChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            if let idOfCrypto = self.presenter.labels[KeysOfLabels.idOfCrypto.rawValue] {
                self.presenter.chartLoad(idOfCrypto: idOfCrypto, interval: Interval.day)
            }
            if let percent = self.presenter.percentages.priceChangePercentage24H {
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

    @objc
    private func weekChartButtonLoad() {
        presenter.removeValues()
        DispatchQueue.main.async {
            self.dayChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.weekChartButton.backgroundColor = UIColor(red: 0.324, green: 0.424, blue: 0.854, alpha: 1)
            self.monthChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.yearChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            if let idOfCrypto = self.presenter.labels[KeysOfLabels.idOfCrypto.rawValue] {
                self.presenter.chartLoad(idOfCrypto: idOfCrypto, interval: Interval.week)
            }
            if let percent = self.presenter.percentages.priceChangePercentage7D {
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
    
    @objc
    private func monthChartButtonLoad() {
        presenter.removeValues()
        DispatchQueue.main.async {
            self.dayChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.weekChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.monthChartButton.backgroundColor = UIColor(red: 0.324, green: 0.424, blue: 0.854, alpha: 1)
            self.yearChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            if let idOfCrypto = self.presenter.labels[KeysOfLabels.idOfCrypto.rawValue] {
                self.presenter.chartLoad(idOfCrypto: idOfCrypto, interval: Interval.month)
            }
            if let percent = self.presenter.percentages.priceChangePercentage30D {
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
    
    @objc
    private func yearChartButtonLoad() {
        presenter.removeValues()
        DispatchQueue.main.async {
            self.dayChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.weekChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.monthChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.yearChartButton.backgroundColor = UIColor(red: 0.324, green: 0.424, blue: 0.854, alpha: 1)
            if let idOfCrypto = self.presenter.labels[KeysOfLabels.idOfCrypto.rawValue] {
                self.presenter.chartLoad(idOfCrypto: idOfCrypto, interval: Interval.year)
            }
            if let percent = self.presenter.percentages.priceChangePercentage1Y {
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
    
    
    private var count = 0
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if count < 3 {
            setupScrollView()
        }
        count += 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
        setupChartAndPriceView()
        setupDetailInfo()
        navigationBarSetup()
        lineChartViewSetup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        updateData()
//        setupChartAndPriceView()
//        setupDetailInfo()
//        navigationBarSetup()
        presenter.chartLoad(idOfCrypto: presenter.labels[KeysOfLabels.idOfCrypto.rawValue]!, interval: Interval.day)
        
//        lineChartViewSetup()
        
        marketDataTableView.register(MarketDataCell.self, forCellReuseIdentifier: "MarketDataCell")
        marketDataTableView.delegate = self
        marketDataTableView.dataSource = self
        communityDataTableView.register(MarketDataCell.self, forCellReuseIdentifier: "MarketDataCell")
        communityDataTableView.delegate = self
        communityDataTableView.dataSource = self
        scrollView.delegate = self
        
    }
    
//    private func setupChartAndPriceView(){
//        chartAndPriceView.addSubview(priceOfCrypto)
//        
//        priceOfCrypto.centerXAnchor.constraint(equalTo: chartAndPriceView.centerXAnchor).isActive = true
//        priceOfCrypto.topAnchor.constraint(equalTo: chartAndPriceView.topAnchor, constant: 20).isActive = true
//        
//        chartAndPriceView.addSubview(diffPriceOfCrypto)
//        diffPriceOfCrypto.centerXAnchor.constraint(equalTo: chartAndPriceView.centerXAnchor).isActive = true
//        diffPriceOfCrypto.topAnchor.constraint(equalTo: priceOfCrypto.bottomAnchor, constant: 5).isActive = true
//        
//        let buttonsView = UIView()
//        buttonsView.layer.cornerRadius = 7
//        buttonsView.layer.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1).cgColor
//        buttonsView.translatesAutoresizingMaskIntoConstraints = false
//        
//        chartAndPriceView.addSubview(buttonsView)
//        buttonsView.centerXAnchor.constraint(equalTo: chartAndPriceView.centerXAnchor).isActive = true
//        buttonsView.bottomAnchor.constraint(equalTo: chartAndPriceView.bottomAnchor).isActive = true
//        buttonsView.heightAnchor.constraint(equalToConstant: 32).isActive = true
//        buttonsView.widthAnchor.constraint(equalTo: chartAndPriceView.widthAnchor, constant: -20).isActive = true
//        
//        buttonsView.addSubview(dayChartButton)
//        dayChartButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor, constant: 3).isActive = true
//        dayChartButton.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: 3).isActive = true
//        dayChartButton.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.size.width - 46) / 4).isActive = true
//        dayChartButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
//        
//        buttonsView.addSubview(weekChartButton)
//        weekChartButton.leadingAnchor.constraint(equalTo: dayChartButton.trailingAnchor, constant: 5).isActive = true
//        weekChartButton.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: 3).isActive = true
//        weekChartButton.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.size.width - 46) / 4).isActive = true
//        weekChartButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
//        
//        buttonsView.addSubview(monthChartButton)
//        monthChartButton.leadingAnchor.constraint(equalTo: weekChartButton.trailingAnchor, constant: 5).isActive = true
//        monthChartButton.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: 3).isActive = true
//        monthChartButton.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.size.width - 46) / 4).isActive = true
//        monthChartButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
//        
//        buttonsView.addSubview(yearChartButton)
//        yearChartButton.leadingAnchor.constraint(equalTo: monthChartButton.trailingAnchor, constant: 5).isActive = true
//        yearChartButton.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: 3).isActive = true
//        yearChartButton.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.size.width - 46) / 4).isActive = true
//        yearChartButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
//        
//        
//        chartAndPriceView.addSubview(lineChartView)
//        lineChartView.centerXAnchor.constraint(equalTo: chartAndPriceView.centerXAnchor).isActive = true
//        lineChartView.topAnchor.constraint(equalTo: diffPriceOfCrypto.bottomAnchor, constant: 10).isActive = true
//        lineChartView.widthAnchor.constraint(equalTo: chartAndPriceView.widthAnchor, constant: -20).isActive = true
//        lineChartView.bottomAnchor.constraint(equalTo: buttonsView.topAnchor, constant: -5).isActive = true
//    }
    
    
//    func setupDetailInfo() {
//        let title = UILabel(); title.text = "Description"; title.textColor = .white; title.font = UIFont(name: "avenir", size: 22)
//        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
//        let image = UIImage(systemName: "chevron.down", withConfiguration: imageConfig)
//        
//        let button : UIButton = {
//            let button = UIButton(type: .custom)
//            button.translatesAutoresizingMaskIntoConstraints = false
//            button.widthAnchor.constraint(equalToConstant: 60).isActive = true
//            button.heightAnchor.constraint(equalToConstant: 60).isActive = true
//            button.imageView?.contentMode = .scaleAspectFit
//            button.imageView?.tintColor = .white
//            button.setImage(image, for: .normal)
//            
//            button.addTarget(self,
//                             action: #selector(loadMore),
//                             for: .touchUpInside)
//            return button
//        }()
//        
//        let headerStack = UIStackView(arrangedSubviews: [title,button])
//        headerStack.axis = .horizontal
//        headerStack.setCustomSpacing(10, after: title)
//        headerStack.alignment = .fill
//        headerStack.translatesAutoresizingMaskIntoConstraints = false
//        
//        marketDataTableView.backgroundColor = UIColor(hexString: "#4158B7")
//        communityDataTableView.backgroundColor = UIColor(hexString: "#4158B7")
//        detailInfoView.addSubview(marketDataTableView)
//        detailInfoView.addSubview(communityDataTableView)
//        detailInfoView.addSubview(headerStack)
//        detailInfoView.addSubview(descriptionLabel)
//        
//        
//        let marketDatatitle = UILabel(); marketDatatitle.text = "Market data"; marketDatatitle.textColor = .white
//        marketDatatitle.font = UIFont(name: "avenir", size: 22)
//        marketDatatitle.translatesAutoresizingMaskIntoConstraints = false
//        detailInfoView.addSubview(marketDatatitle)
//        
//        marketDatatitle.topAnchor.constraint(equalTo: detailInfoView.topAnchor, constant: 29).isActive = true
//        marketDatatitle.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor).isActive = true
//        
//        marketDataTableView.translatesAutoresizingMaskIntoConstraints = false
//        marketDataTableView.topAnchor.constraint(equalTo: marketDatatitle.bottomAnchor, constant: 10).isActive = true
//        marketDataTableView.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor).isActive = true
//        marketDataTableView.heightAnchor.constraint(equalToConstant: 250).isActive = true
//        
//        headerStack.topAnchor.constraint(equalTo: marketDataTableView.bottomAnchor, constant: 18).isActive = true
//        headerStack.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor).isActive = true
//        headerStack.heightAnchor.constraint(equalToConstant: 40).isActive = true
//        
//        let communityDatatitle = UILabel(); communityDatatitle.text = "Community data"; communityDatatitle.textColor = .white
//        communityDatatitle.font = UIFont(name: "avenir", size: 22)
//        communityDatatitle.translatesAutoresizingMaskIntoConstraints = false
//        detailInfoView.addSubview(communityDatatitle)
//        
//        descriptionLabel.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 14).isActive = true
//        descriptionLabel.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor).isActive = true
//        descriptionLabel.bottomAnchor.constraint(equalTo: communityDatatitle.topAnchor, constant: -18).isActive = true
//        
//        communityDatatitle.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor).isActive = true
//        communityDatatitle.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor).isActive = true
//        communityDatatitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        communityDatatitle.bottomAnchor.constraint(equalTo: communityDataTableView.topAnchor).isActive = true
//        
//        communityDataTableView.translatesAutoresizingMaskIntoConstraints = false
//        communityDataTableView.topAnchor.constraint(equalTo: communityDatatitle.bottomAnchor).isActive = true
//        communityDataTableView.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor).isActive = true
//        communityDataTableView.heightAnchor.constraint(equalToConstant: 130).isActive = true
//        
//        var arrangedSubviews : [UIView] = []
//        if presenter.labels[KeysOfLabels.redditUrl.rawValue] == "" || presenter.labels[KeysOfLabels.redditUrl.rawValue]!.isEmpty || presenter.labels[KeysOfLabels.redditUrl.rawValue] == "https://reddit.com" {
//            arrangedSubviews = [onSiteButton]
//        } else if presenter.labels[KeysOfLabels.siteUrl.rawValue] == "" || presenter.labels[KeysOfLabels.siteUrl.rawValue]!.isEmpty {
//            arrangedSubviews = [onRedditButton]
//        } else {
//            arrangedSubviews = [onRedditButton, onSiteButton]
//        }
//        
//        let buttonsStack = UIStackView(arrangedSubviews: arrangedSubviews)
//        buttonsStack.axis = .vertical
//        buttonsStack.distribution = .fillEqually
//        buttonsStack.spacing = 11
//        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
//        
//        detailInfoView.addSubview(buttonsStack)
//        buttonsStack.topAnchor.constraint(equalTo: communityDataTableView.bottomAnchor, constant: 10).isActive = true
//        buttonsStack.centerXAnchor.constraint(equalTo: detailInfoView.centerXAnchor).isActive = true
//        buttonsStack.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor, constant: -2).isActive = true
//        
//        if buttonsStack.arrangedSubviews.count == 1 {
//            buttonsStack.heightAnchor.constraint(equalToConstant: 56).isActive = true
//            scrollView.contentInset.bottom -= 67
//        } else if buttonsStack.arrangedSubviews.count == 2 {
//            buttonsStack.heightAnchor.constraint(equalToConstant: 123).isActive = true
//            //            scrollView.contentInset.bottom += 123
//        } else {
//            buttonsStack.heightAnchor.constraint(equalToConstant: 0).isActive = true
//            scrollView.contentInset.bottom -= 123
//        }
//    }
    
    @objc
    private func onReddit() {
        guard let redditUrl = presenter.labels[KeysOfLabels.redditUrl.rawValue] else {return}
        guard let url = URL(string: redditUrl) else {return}
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    @objc
    private func onSite() {
        guard let siteUrl = presenter.labels[KeysOfLabels.siteUrl.rawValue] else {return}
        guard let url = URL(string: siteUrl) else {return}
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    
    
    private var clickBool = true
    private var constHeightOfTextLabel = CGFloat()
    
    @objc
    func loadMore() {
        
        if clickBool == true {
            descriptionLabel.numberOfLines = 0
            descriptionLabel.lineBreakMode = .byWordWrapping
            constHeightOfTextLabel = descriptionLabel.frame.height
            let height = descriptionLabel.systemLayoutSizeFitting(CGSize(width: descriptionLabel.frame.width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
            scrollView.contentInset.bottom += (height - descriptionLabel.frame.height)
            contentViewFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: contentViewFrame.height + height - constHeightOfTextLabel)
            contentView.frame = contentViewFrame
            detailInfoViewFrame = CGRect(x: 15, y: 600, width: UIScreen.main.bounds.size.width - 30, height: detailInfoViewFrame.height + height - constHeightOfTextLabel)
            detailInfoView.frame = detailInfoViewFrame
            
            for elem in detailInfoView.subviews {
                if let stack = elem as? UIStackView {
                    for button in stack.arrangedSubviews {
                        if let button = button as? UIButton  {
                            let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
                            if button.imageView?.image == UIImage(systemName: "chevron.down", withConfiguration: imageConfig) {
                                //                            let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
                                button.setImage(UIImage(systemName: "chevron.up", withConfiguration: imageConfig), for: .normal)
                            }
                        }
                    }
                }
            }
            
            
        } else {
            descriptionLabel.numberOfLines = 7
            descriptionLabel.lineBreakMode = .byTruncatingTail
            scrollView.contentInset.bottom -= descriptionLabel.frame.height
            scrollView.contentInset.bottom += constHeightOfTextLabel
            scrollView.contentOffset = CGPoint(x: 0, y: 500)
            
            for elem in detailInfoView.subviews {
                if let stack = elem as? UIStackView {
                    for button in stack.arrangedSubviews {
                        if let button = button as? UIButton  {
                            let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
                            if button.imageView?.image == UIImage(systemName: "chevron.up", withConfiguration: imageConfig) {
                                //                            let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
                                button.setImage(UIImage(systemName: "chevron.down", withConfiguration: imageConfig), for: .normal)
                            }
                        }
                    }
                }
            }
            
        }
        clickBool.toggle()
    }
    

}

extension ChartViewController : ChartViewControllerProtocol {
//    func increaseScrollViewBottom (for number : CGFloat) {
//        scrollView.contentInset.bottom += number
//    }
    func reloadMarketDataTableView() {
        marketDataTableView.reloadData()
    }
    func reloadCommunityDataTableView() {
        communityDataTableView.reloadData()
    }
    func updateData() {
        DispatchQueue.main.async { [self] in
            nameOfCrypto.text = presenter.labels[KeysOfLabels.symbolOfCurrentCrypto.rawValue]
            descriptionLabel.text = presenter.labels[KeysOfLabels.descriptionLabel.rawValue]
            computedDiffPrice = presenter.percentages.priceChangePercentage24H!
            priceOfCrypto.text?.removeAll()
            priceOfCrypto.text?.append("$")
            priceOfCrypto.text?.append(presenter.labels[KeysOfLabels.priceOfCrypto.rawValue] ?? "Name of crypto")
        }
    }
    
    func updateContentViewFrame(contentViewFrameChange : CGFloat, detailInfoViewFrameChange : CGFloat, scrollViewChange : CGFloat) {
        self.contentViewFrame.size.height -= contentViewFrameChange
        self.detailInfoViewFrame.size.height -= detailInfoViewFrameChange
        self.scrollView.contentInset.bottom -= scrollViewChange
    }
    
    func navigationBarSetup() {
        DispatchQueue.main.async { [self] in
            let image : UIImage
            if presenter.bool {
                image = UIImage(systemName: "heart.fill") ?? UIImage()
            } else {
                image = UIImage(systemName: "heart") ?? UIImage()
            }
            let butt = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(saveTapped))
            
            navigationItem.rightBarButtonItem = butt
            navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 0.969, green: 0.576, blue: 0.102, alpha: 1)
            navigationController?.navigationBar.tintColor = .white
            
            
            let logoAndTitle = UIView()
            
            let label : UILabel = {
                let label = UILabel()
                label.text = " \(self.nameOfCrypto.text ?? "")"
                label.textColor = .white
                label.sizeToFit()
                label.center = logoAndTitle.center
                label.textAlignment = NSTextAlignment.center
                return label
            }()
            
            let logo : UIImageView = {
                let logo = UIImageView()
                logo.image = presenter.image
                let imageAspect = logo.image!.size.width/logo.image!.size.height
                logo.frame = CGRect(x: label.frame.origin.x-label.frame.size.height*imageAspect, y: label.frame.origin.y, width: label.frame.size.height*imageAspect, height: label.frame.size.height)
                logo.contentMode = UIView.ContentMode.scaleAspectFit
                logo.layer.cornerRadius = logo.frame.height/2
                logo.clipsToBounds = true
                return logo
            }()
            
            logoAndTitle.addSubview(label)
            logoAndTitle.addSubview(logo)
            navigationItem.titleView = logoAndTitle
        }
    }
    @objc
    private func saveTapped() {
        presenter.saveTapped()
    }
}

extension ChartViewController : ChartViewDelegate {
    
    func lineChartViewSetup() {
        lineChartView.backgroundColor = UIColor(hexString: "#4158B7")
        lineChartView.leftAxis.enabled = false
        lineChartView.xAxis.setLabelCount(5, force: false)
        lineChartView.rightAxis.setLabelCount(8, force: false)
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelTextColor = .white
        lineChartView.rightAxis.labelTextColor = .white
        lineChartView.animate(xAxisDuration: 0.8)
        
    }
    
    
    func setData(dataSet: LineChartDataSet, xAxisValueFormatter: ChartViewPresenter.MyXAxisFormatter) {
        dataSet.label = ""
        dataSet.drawCirclesEnabled = false
        dataSet.mode = .linear
        dataSet.lineWidth = 1
        dataSet.setColor(UIColor(hexString: "F7931A"))
        dataSet.fill = Fill(color: UIColor(hexString: "#202F72"))
        dataSet.fillAlpha = 0.7
        dataSet.drawFilledEnabled = true
        dataSet.drawVerticalHighlightIndicatorEnabled = false
        dataSet.highlightColor = diffPriceOfCrypto.textColor
        let data = LineChartData(dataSet: dataSet)
        data.setDrawValues(false)
        lineChartView.data = data
        lineChartView.xAxis.valueFormatter = xAxisValueFormatter
        
    }
}


extension ChartViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == marketDataTableView {
            return presenter.marketData.count
        } else {
            return presenter.communityData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MarketDataCell.reuseId, for: indexPath) as? MarketDataCell else {return UITableViewCell()}
        if tableView == marketDataTableView {
            let marketDataElem = presenter.marketData[indexPath.row]
            cell.configure(with: marketDataElem)
        } else {
            let communityDataElem = presenter.communityData[indexPath.row]
            cell.configure(with: communityDataElem)
        }
        cell.backgroundColor = UIColor(hexString: "#4158B7")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

