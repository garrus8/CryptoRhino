//
//  DetailInfoExtension.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 29.09.2021.
//

import UIKit

extension ChartViewController {
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
            
            button.addTarget(self,
                             action: #selector(loadMore),
                             for: .touchUpInside)
            return button
        }()
        
        let headerStack = UIStackView(arrangedSubviews: [title,button])
        headerStack.axis = .horizontal
        headerStack.setCustomSpacing(10, after: title)
        headerStack.alignment = .fill
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        
        marketDataTableView.backgroundColor = UIColor(hexString: "#4158B7")
        communityDataTableView.backgroundColor = UIColor(hexString: "#4158B7")
        detailInfoView.addSubview(marketDataTableView)
        detailInfoView.addSubview(communityDataTableView)
        detailInfoView.addSubview(headerStack)
        detailInfoView.addSubview(descriptionLabel)
        
        
        let marketDatatitle = UILabel(); marketDatatitle.text = "Market data"; marketDatatitle.textColor = .white
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
        
        let communityDatatitle = UILabel(); communityDatatitle.text = "Community data"; communityDatatitle.textColor = .white
        communityDatatitle.font = UIFont(name: "avenir", size: 22)
        communityDatatitle.translatesAutoresizingMaskIntoConstraints = false
        detailInfoView.addSubview(communityDatatitle)
        
        descriptionLabel.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 14).isActive = true
        descriptionLabel.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: communityDatatitle.topAnchor, constant: -18).isActive = true
        
        communityDatatitle.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor).isActive = true
        communityDatatitle.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor).isActive = true
        communityDatatitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
        communityDatatitle.bottomAnchor.constraint(equalTo: communityDataTableView.topAnchor).isActive = true
        
        communityDataTableView.translatesAutoresizingMaskIntoConstraints = false
        communityDataTableView.topAnchor.constraint(equalTo: communityDatatitle.bottomAnchor).isActive = true
        communityDataTableView.widthAnchor.constraint(equalTo: detailInfoView.widthAnchor).isActive = true
        communityDataTableView.heightAnchor.constraint(equalToConstant: 130).isActive = true
        
        var arrangedSubviews : [UIView] = []
        if presenter.labels[KeysOfLabels.redditUrl.rawValue] == "" || presenter.labels[KeysOfLabels.redditUrl.rawValue]!.isEmpty || presenter.labels[KeysOfLabels.redditUrl.rawValue] == "https://reddit.com" {
            arrangedSubviews = [onSiteButton]
        } else if presenter.labels[KeysOfLabels.siteUrl.rawValue] == "" || presenter.labels[KeysOfLabels.siteUrl.rawValue]!.isEmpty {
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
}
