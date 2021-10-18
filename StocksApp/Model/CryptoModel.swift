//
//  CryptoModel.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 15.10.2021.
//

import UIKit

class Crypto : Hashable, Equatable {
    
    var symbolOfCrypto : String
    var priceLabel : String?
    var pricesDict : [String : Double]?
    var change : String?
    var nameOfCrypto : String?
    var descriptionOfCrypto : String?
    var symbolOfTicker : String?
    var id : String?
    var percentages : Persentages?
    var rank : Int?
    var image : UIImage?
    var imageString : String?
    var marketDataArray : MarketDataArray?
    var communityDataArray : CommunityDataArray?
    var links : Links?

// Main init
    init(symbolOfCrypto : String, price : String, change: String, nameOfCrypto: String?, descriptionOfCrypto: String?, id : String?, percentages : Persentages?, image : UIImage) {
        self.symbolOfCrypto = symbolOfCrypto
        self.priceLabel = price
        self.change = change
        self.nameOfCrypto = nameOfCrypto
        self.descriptionOfCrypto = descriptionOfCrypto
        self.id = id
        self.percentages = percentages
        self.image = image
        self.pricesDict = [String : Double]()
    }
    
    init(symbolOfCrypto : String) {
        self.symbolOfCrypto = symbolOfCrypto
    }
    
    init(symbolOfCrypto : String, id : String) {
        
        self.symbolOfCrypto = symbolOfCrypto
        self.priceLabel = ""
        self.change = ""
        self.nameOfCrypto = ""
        self.descriptionOfCrypto = ""
        self.id = id
        self.percentages = Persentages()
    }
    
    init(symbolOfCrypto: String, nameOfCrypto: String, descriptionOfCrypto: String, image : UIImage, percentages : Persentages?) {
        self.symbolOfCrypto = symbolOfCrypto
        self.nameOfCrypto = nameOfCrypto
        self.descriptionOfCrypto = descriptionOfCrypto
        self.image = image
        self.percentages = percentages
        
    }
    init(symbolOfCrypto : String, nameOfCrypto: String?, id : String?, rank : Int = 101) {
        self.symbolOfCrypto = symbolOfCrypto
        self.nameOfCrypto = nameOfCrypto
        self.id = id
        self.rank = rank
    }
    
    static func == (lhs: Crypto, rhs: Crypto) -> Bool {
        lhs.symbolOfCrypto == rhs.symbolOfCrypto
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(symbolOfCrypto)
    }
}
