//
//  DataManager.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 25.02.2021.
//

import Foundation

struct StocksData : Codable {
    let quotes: [Quote]
    
    init(quotes : [Quote]) {
        self.quotes = quotes
    }
}

struct Quote : Codable {
    let shortName : String
    let symbol : String
    let regularMarketPrice : Double
    let regularMarketChange : Double
    
    init(shortName : String, symbol : String, regularMarketPrice : Double, regularMarketChange : Double ) {
        self.shortName = shortName
        self.symbol = symbol
        self.regularMarketPrice = regularMarketPrice
        self.regularMarketChange = regularMarketChange
    }
    
}


