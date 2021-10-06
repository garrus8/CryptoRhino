////
////  DetailInfoView.swift
////  StocksApp
////
////  Created by Григорий Толкачев on 28.09.2021.
////
//
//import UIKit
//
//class DetailInfoView: UIView {
//    
//    var viewController : ChartViewController!
//    
//    private var marketDataTableView = UITableView()
//    private var communityDataTableView = UITableView()
//    private let descriptionLabel : UILabel = {
//        let textView = UILabel()
//        textView.translatesAutoresizingMaskIntoConstraints = false
//        textView.layer.masksToBounds = true
//        textView.numberOfLines = 7
//        textView.lineBreakMode = .byTruncatingTail
//        textView.font = UIFont.systemFont(ofSize: 14)
//        textView.textColor = .white
//        textView.sizeToFit()
//        return textView
//    }()
//    private let onRedditButton : UIButton = {
//        let button = UIButton(type: .custom)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.backgroundColor = UIColor(red: 0.969, green: 0.576, blue: 0.102, alpha: 1)
//        button.layer.cornerRadius = 14
//        button.setTitleColor(.white, for: .normal)
//        button.setTitle("Reddit", for: .normal)
////        button.addTarget(self,
////                         action: #selector(onReddit),
////                         for: .touchUpInside)
//        return button
//    }()
//    private let onSiteButton : UIButton = {
//        let button = UIButton(type: .custom)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.backgroundColor = .clear
//        button.layer.cornerRadius = 14
//        button.layer.borderWidth = 2
//        button.layer.borderColor = UIColor(red: 0.969, green: 0.576, blue: 0.102, alpha: 1).cgColor
//        button.setTitleColor(UIColor(red: 0.969, green: 0.576, blue: 0.102, alpha: 1), for: .normal)
//        button.setTitle("Website", for: .normal)
////        button.addTarget(self,
////                         action: #selector(onSite),
////                         for: .touchUpInside)
//        return button
//    }()
//    
//    init(view : ChartViewController) {
//        super.init(frame: CGRect(x: 15, y: 600, width: UIScreen.main.bounds.size.width - 30, height: 870))
//        self.viewController = view
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
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
////            button.addTarget(self,
////                             action: #selector(loadMore),
////                             for: .touchUpInside)
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
//        addSubview(marketDataTableView)
//        addSubview(communityDataTableView)
//        addSubview(headerStack)
//        addSubview(descriptionLabel)
//        
//        
//        let marketDatatitle = UILabel(); marketDatatitle.text = "Market data"; marketDatatitle.textColor = .white
//        marketDatatitle.font = UIFont(name: "avenir", size: 22)
//        marketDatatitle.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(marketDatatitle)
//        
//        marketDatatitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 29).isActive = true
//        marketDatatitle.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
//        
//        marketDataTableView.translatesAutoresizingMaskIntoConstraints = false
//        marketDataTableView.topAnchor.constraint(equalTo: marketDatatitle.bottomAnchor, constant: 10).isActive = true
//        marketDataTableView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
//        marketDataTableView.heightAnchor.constraint(equalToConstant: 250).isActive = true
//        
//        headerStack.topAnchor.constraint(equalTo: marketDataTableView.bottomAnchor, constant: 18).isActive = true
//        headerStack.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
//        headerStack.heightAnchor.constraint(equalToConstant: 40).isActive = true
//        
//        let communityDatatitle = UILabel(); communityDatatitle.text = "Community data"; communityDatatitle.textColor = .white
//        communityDatatitle.font = UIFont(name: "avenir", size: 22)
//        communityDatatitle.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(communityDatatitle)
//        
//        descriptionLabel.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 14).isActive = true
//        descriptionLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
//        descriptionLabel.bottomAnchor.constraint(equalTo: communityDatatitle.topAnchor, constant: -18).isActive = true
//        
//        communityDatatitle.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor).isActive = true
//        communityDatatitle.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
//        communityDatatitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        communityDatatitle.bottomAnchor.constraint(equalTo: communityDataTableView.topAnchor).isActive = true
//        
//        communityDataTableView.translatesAutoresizingMaskIntoConstraints = false
//        communityDataTableView.topAnchor.constraint(equalTo: communityDatatitle.bottomAnchor).isActive = true
//        communityDataTableView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
//        communityDataTableView.heightAnchor.constraint(equalToConstant: 130).isActive = true
//        
//        var arrangedSubviews : [UIView] = []
//        if viewController.presenter.labels[KeysOfLabels.redditUrl.rawValue] == "" || viewController.presenter.labels[KeysOfLabels.redditUrl.rawValue]!.isEmpty || viewController.presenter.labels[KeysOfLabels.redditUrl.rawValue] == "https://reddit.com" {
//            arrangedSubviews = [onSiteButton]
//        } else if viewController.presenter.labels[KeysOfLabels.siteUrl.rawValue] == "" || viewController.presenter.labels[KeysOfLabels.siteUrl.rawValue]!.isEmpty {
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
//        addSubview(buttonsStack)
//        buttonsStack.topAnchor.constraint(equalTo: communityDataTableView.bottomAnchor, constant: 10).isActive = true
//        buttonsStack.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        buttonsStack.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -2).isActive = true
//        
//        if buttonsStack.arrangedSubviews.count == 1 {
//            buttonsStack.heightAnchor.constraint(equalToConstant: 56).isActive = true
//            viewController.scrollView.contentInset.bottom -= 67
//        } else if buttonsStack.arrangedSubviews.count == 2 {
//            buttonsStack.heightAnchor.constraint(equalToConstant: 123).isActive = true
//            //            scrollView.contentInset.bottom += 123
//        } else {
//            buttonsStack.heightAnchor.constraint(equalToConstant: 0).isActive = true
//            viewController.scrollView.contentInset.bottom -= 123
//        }
//    }
//}
