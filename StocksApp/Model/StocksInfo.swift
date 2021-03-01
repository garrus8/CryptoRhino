//
//  StocksInfo.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 25.02.2021.
//

import Foundation

struct StocksInfo {
    let name : String
    let symbol : String
    let price : Double
    var priceString : String {
        return "\(price)"
    }
    let change : Double
    var changeString : String {
        return "\(change)"
    }
  
   
    
    init?(stocksData : StocksData) {
        name = stocksData.quotes.first!.shortName
        symbol = stocksData.quotes.first!.symbol
        price = stocksData.quotes.first!.regularMarketPrice
        change = stocksData.quotes.first!.regularMarketChange

    }
}
