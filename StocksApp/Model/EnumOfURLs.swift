//
//  EnumOfURLs.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 15.09.2021.
//

import Foundation


enum Urls : String {
    case news = "https://min-api.cryptocompare.com/data/v2/news/?lang=EN"
    case topOfCrypto = "https://min-api.cryptocompare.com/data/top/totalvolfull?limit=20&tsym=USD"
    case topSearch = "https://api.coingecko.com/api/v3/search/trending"
    case fullListOfCoinGecko = "https://api.coingecko.com/api/v3/coins/list"
    case fullCoinCapList = "https://api.coincap.io/v2/assets?limit=400"
}

