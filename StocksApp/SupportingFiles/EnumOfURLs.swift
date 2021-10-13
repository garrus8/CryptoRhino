//
//  EnumOfURLs.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 15.09.2021.
//

import Foundation

enum Urls : String {
    case news = "https://min-api.cryptocompare.com/data/v2/news/?lang=EN&api_key=a5004f964bbd78cf22e98243f51abbd051354a00fc78576635af0af749f10b78"
    case topOfCrypto = "https://min-api.cryptocompare.com/data/top/totalvolfull?limit=15&tsym=USD&api_key=a5004f964bbd78cf22e98243f51abbd051354a00fc78576635af0af749f10b78"
    case topSearch = "https://api.coingecko.com/api/v3/search/trending"
    case fullListOfCoinGecko = "https://api.coingecko.com/api/v3/coins/list"
    case fullCoinCapList = "https://api.coincap.io/v2/assets?limit=1000"
//    case webSocket = "wss://ws.finnhub.io?token=c12ev3748v6oi252n1fg"
}

class FinHubApiRandomizer {
    static var api : String {
        let urls = ["wss://ws.finnhub.io?token=c12ev3748v6oi252n1fg",
                    "wss://ws.finnhub.io?token=c5fda7iad3ib660r4i8g",
                    "wss://ws.finnhub.io?token=c5fdhjaad3ib660r4lq0"]
        let randomIndex = Int.random(in: 0..<urls.count)
        return urls[randomIndex]
    }
}
