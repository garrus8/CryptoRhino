//
//  ChartViewPresenter.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 15.09.2021.
//

import UIKit

protocol ChartViewPresenterProtocol : AnyObject {
    
}

class ChartViewPresenter : ChartViewPresenterProtocol {
    var crypto = Crypto(symbolOfCrypto: "", price: "", change: "", nameOfCrypto: "", descriptionOfCrypto: "", id: "", percentages: nil, image: UIImage(named: "pngwing.com")!)
    
    
    func load() {
    
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
    }
}
