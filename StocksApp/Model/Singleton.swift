//
//  Singleton.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 17.09.2021.
//

import UIKit


class DataSingleton {
    
var sections = [SectionOfCrypto]()
var searchSections = [SectionOfCrypto]()
var imageCache = NSCache<NSString,UIImage>()
var results = [Crypto]()
var symbols = [String]()
var coinGecoList = [GeckoListElement]()
var favorites = [Favorites]()
var resultsF = [Crypto]()
var symbolsF = [String]()
var fullBinanceList = GeckoList()
var topList = [TopSearchItem]()
var coinCapDict = [[String: String?]]()
var dict = [String : [Crypto]]()
var dict1 = [String : Int]()
var collectionViewSymbols = [String]()
var collectionViewArray = [Crypto]()
var websocketArray = [String]()

static let shared = DataSingleton()
private init() {}

}
