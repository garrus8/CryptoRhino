//
//  DataManager.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 25.02.2021.
//

import Foundation
import UIKit


struct CoinGeckoPrice: Codable {
    let prices, marketCaps, totalVolumes: [[Double]]?

    enum CodingKeys: String, CodingKey {
        case prices
        case marketCaps = "market_caps"
        case totalVolumes = "total_volumes"
    }
}


//class SectionOfCrypto : Hashable, Equatable {
//    
//    static func == (lhs: SectionOfCrypto, rhs: SectionOfCrypto) -> Bool {
//        lhs.type == rhs.type
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(type)
//    }
//        
//    var type: String
//    var title : String
//    var items : [Crypto]
//    
//    init(type : String, title : String, items : [Crypto]) {
//        self.type = type
//        self.title = title
//        self.items = items
//    }
//}

//class SearchSectionOfCrypto : Hashable, Equatable {
//    
//    static func == (lhs: SearchSectionOfCrypto, rhs: SearchSectionOfCrypto) -> Bool {
//        lhs.type == rhs.type
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(type)
//    }
//        
//    var type: String
//    var items : GeckoListElement
//    
//    init(type : String, title : String, items : GeckoListElement) {
//        self.type = type
//        self.items = items
//    }
//}

class Crypto : Hashable, Equatable {
    
    static func == (lhs: Crypto, rhs: Crypto) -> Bool {
        lhs.symbolOfCrypto == rhs.symbolOfCrypto
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(symbolOfCrypto)
    }
    
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
//        self.image = nil
//        self.marketDataArray = nil
//        self.communityDataArray = nil
//        self.links = nil

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
    deinit {
        print("DEINIT CRYPTO")
    }
}

//struct Persentages {
//    var priceChangePercentage24H : String?
//    var priceChangePercentage7D : String?
//    var priceChangePercentage30D : String?
//    var priceChangePercentage1Y : String?
//    
//    init() {
//         priceChangePercentage24H = ""
//         priceChangePercentage7D = ""
//         priceChangePercentage30D = ""
//         priceChangePercentage1Y = ""
//    }
//    init (priceChangePercentage24H: String, priceChangePercentage7D : String, priceChangePercentage30D : String, priceChangePercentage1Y : String) {
//        self.priceChangePercentage24H = priceChangePercentage24H
//        self.priceChangePercentage7D = priceChangePercentage7D
//        self.priceChangePercentage30D = priceChangePercentage30D
//        self.priceChangePercentage1Y = priceChangePercentage1Y
//    }
//}

struct FullCoinCapList: Codable {
    let data: [[String: String?]]?
}

// JSON1
struct GetData: Decodable {
    let c : [Double]?
    let t : [Int]?
}
//WEBSOCKETS
struct WebSocketData : Decodable {
    let data: [Datum]
    
}

struct Datum : Decodable  {
    let p: Double
    var s: String

}
//TOPLIST
struct Toplist : Decodable {
    let data : [ToplistData]?
    
    enum CodingKeys: String, CodingKey {
           case data = "Data"
       }
   }


struct ToplistData : Decodable {
    let coinInfo: CoinInfo?
    enum CodingKeys: String, CodingKey {
           case coinInfo = "CoinInfo"
       }
}

struct CoinInfo : Decodable {
    let id, name, fullName, coinInfoInternal: String?
    let imageURL, url, algorithm, proofType: String?
    let rating: Rating?
    let netHashesPerSecond: Double?
    let blockNumber: Int?
    let blockTime, blockReward: Double?
    let assetLaunchDate: String?
    let maxSupply: Double?
    let type: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case fullName = "FullName"
        case coinInfoInternal = "Internal"
        case imageURL = "ImageUrl"
        case url = "Url"
        case algorithm = "Algorithm"
        case proofType = "ProofType"
        case rating = "Rating"
        case netHashesPerSecond = "NetHashesPerSecond"
        case blockNumber = "BlockNumber"
        case blockTime = "BlockTime"
        case blockReward = "BlockReward"
        case assetLaunchDate = "AssetLaunchDate"
        case maxSupply = "MaxSupply"
        case type = "Type"
    }
}



struct Rating: Codable {
    let weiss: Weiss?
    
    enum CodingKeys: String, CodingKey {
        case weiss = "Weiss"
    }
}
struct Weiss: Codable {
    let rating, technologyAdoptionRating, marketPerformanceRating: String?
    
    enum CodingKeys: String, CodingKey {
        case rating = "Rating"
        case technologyAdoptionRating = "TechnologyAdoptionRating"
        case marketPerformanceRating = "MarketPerformanceRating"
    }
}


////NEWS
//struct News: Codable {
//    let data: [NewsData]?
//
//    enum CodingKeys: String, CodingKey {
//        case data = "Data"
//
//    }
//}
//struct NewsData: Codable {
//    let id: String?
//    let guid: String?
//    let publishedOn: Int?
//    let imageurl: String?
//    let title: String?
//    let url: String?
//    let source, body, tags, categories: String?
//    let upvotes, downvotes: String?
//    let lang: Lang?
//    let sourceInfo: SourceInfo?
//
//    enum CodingKeys: String, CodingKey {
//        case id, guid
//        case publishedOn = "published_on"
//        case imageurl, title, url, source, body, tags, categories, upvotes, downvotes, lang
//        case sourceInfo = "source_info"
//    }
//}
//
//enum Lang: String, Codable {
//    case en = "EN"
//}
//
//struct SourceInfo: Codable {
//    let name: String?
//    let lang: Lang?
//    let img: String?
//}

//// CoinGecko
//struct GeckoListElement: Codable {
//    var id, symbol, name : String?
//    var rank : Int?
//}
//
//typealias GeckoList = [GeckoListElement]


//// MARK: - GeckoSymbol
struct GeckoSymbol: Decodable {
    let id: String?
    let symbol, name: String?
    let geckoSymbolDescription: Description?
    let links: Links?
    let image: Image?
    let marketCapRank, coingeckoRank: Int?
    let marketData: MarketData?
    let communityData: CommunityData?

    enum CodingKeys: String, CodingKey {
        case id,symbol, name
        case geckoSymbolDescription = "description"
        case links, image
        case marketCapRank = "market_cap_rank"
        case coingeckoRank = "coingecko_rank"
        case marketData = "market_data"
        case communityData = "community_data"
    }
}



// MARK: - Description
struct Description: Codable {
    let en: String?
}


// MARK: - Image
struct Image: Codable {
    let thumb, small, large: String?
}

// MARK: - Links
struct Links: Codable {
    let homepage : [String]?
    let subredditURL: String?

    enum CodingKeys: String, CodingKey {
        case homepage
        case subredditURL = "subreddit_url"
    }
}

// MARK: - TopSearch
struct TopSearch: Decodable {
    let coins: [Coin]
}

// MARK: - Coin
struct Coin: Decodable {
    let item: Item
}

// MARK: - Item
struct Item: Decodable {
    let id: String
    let name, symbol: String
    let large: String

    enum CodingKeys: String, CodingKey {
        case id
        case name, symbol
        case large
    }
}

extension Decodable {
    static func decode(with decoder: JSONDecoder = JSONDecoder(), from data: Data) throws -> Self? {
        do {
            let newdata = try decoder.decode(Self.self, from: data)
            return newdata
        } catch {
            print("decodable model error", error.localizedDescription)
            return nil
        }
    }
}



