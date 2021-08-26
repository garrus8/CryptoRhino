//
//  DataManager.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 25.02.2021.
//

import Foundation
import UIKit


//class Crypto {
//    var symbolOfCrypto : String
//    var index : Double
//    var closePrice : Double
//    var nameOfCrypto : String?
//    var descriptionOfCrypto : String?
//    var symbolOfTicker : String?
//    var id : String?
//    var percentString : String?
//
//    var diffPrice : Double {
//        return index - closePrice
//    }
//    var percent : Double {
//        return (index - closePrice) / closePrice * 100
//    }
//
//
//    init(symbolOfCrypto : String, index : Double, closePrice: Double, nameOfCrypto: String?, descriptionOfCrypto: String?, symbolOfTicker : String?, id : String?, percentString : String?) {
//        self.symbolOfCrypto = symbolOfCrypto
//        self.index = index
//        self.closePrice = closePrice
//        self.nameOfCrypto = nameOfCrypto
//        self.descriptionOfCrypto = descriptionOfCrypto
//        self.symbolOfTicker = symbolOfTicker
//        self.id = id
//        self.percentString = percentString
//
//    }
//}
struct CoinGeckoPrice: Codable {
    let prices, marketCaps, totalVolumes: [[Double]]?

    enum CodingKeys: String, CodingKey {
        case prices
        case marketCaps = "market_caps"
        case totalVolumes = "total_volumes"
    }
}


class SectionOfCrypto : Hashable, Equatable {
    
    static func == (lhs: SectionOfCrypto, rhs: SectionOfCrypto) -> Bool {
        lhs.type == rhs.type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
        
    var type: String
    var title : String
    var items : [Crypto]
    
    init(type : String, title : String, items : [Crypto]) {
        self.type = type
        self.title = title
        self.items = items
    }
}

class SearchSectionOfCrypto : Hashable, Equatable {
    
    static func == (lhs: SearchSectionOfCrypto, rhs: SearchSectionOfCrypto) -> Bool {
        lhs.type == rhs.type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
        
    var type: String
    var items : FullBinanceList
    
    init(type : String, title : String, items : FullBinanceList) {
        self.type = type
        self.items = items
    }
}

class Crypto : Hashable, Equatable {
    
    static func == (lhs: Crypto, rhs: Crypto) -> Bool {
        lhs.symbolOfCrypto == rhs.symbolOfCrypto
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(symbolOfCrypto)
    }
    
    
    var symbolOfCrypto : String
    var price : String?
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
    init(symbolOfCrypto : String, price : String, change: String, nameOfCrypto: String?, descriptionOfCrypto: String?, symbolOfTicker : String?, id : String?, percentages : Persentages?, image : UIImage) {
        
        self.symbolOfCrypto = symbolOfCrypto
        self.price = price
        self.change = change
        self.nameOfCrypto = nameOfCrypto
        self.descriptionOfCrypto = descriptionOfCrypto
        self.symbolOfTicker = symbolOfTicker
        self.id = id
        self.percentages = percentages
        self.image = image
        self.marketDataArray = nil
        self.communityDataArray = nil
        self.links = nil

    }
    init(symbolOfCrypto : String, id : String) {
        
        self.symbolOfCrypto = symbolOfCrypto
        self.price = ""
        self.change = ""
        self.nameOfCrypto = ""
        self.descriptionOfCrypto = ""
        self.symbolOfTicker = ""
        self.id = id
        self.percentages = Persentages()
        self.image = nil
        self.marketDataArray = nil
        self.communityDataArray = nil
        self.links = nil

    }
    
    init(symbolOfCrypto: String, nameOfCrypto: String, descriptionOfCrypto: String, symbolOfTicker: String, image : UIImage, percentages : Persentages?) {
        self.symbolOfCrypto = symbolOfCrypto
        self.nameOfCrypto = nameOfCrypto
        self.descriptionOfCrypto = descriptionOfCrypto
        self.symbolOfTicker = symbolOfTicker
        self.image = image
        self.percentages = percentages
        
    }
    init(symbolOfCrypto : String, nameOfCrypto: String?,symbolOfTicker: String, id : String?, rank : Int = 101) {
        self.symbolOfCrypto = symbolOfCrypto
        self.nameOfCrypto = nameOfCrypto
        self.id = id
        self.rank = rank
        self.symbolOfTicker = symbolOfTicker
    }
    deinit {
        print("DEINIT CRYPTO")
    }
}

struct Persentages {
    var priceChangePercentage24H : String?
    var priceChangePercentage7D : String?
    var priceChangePercentage30D : String?
    var priceChangePercentage1Y : String?
    
    init() {
         priceChangePercentage24H = ""
         priceChangePercentage7D = ""
         priceChangePercentage30D = ""
         priceChangePercentage1Y = ""
    }
    init (priceChangePercentage24H: String, priceChangePercentage7D : String, priceChangePercentage30D : String, priceChangePercentage1Y : String) {
        self.priceChangePercentage24H = priceChangePercentage24H
        self.priceChangePercentage7D = priceChangePercentage7D
        self.priceChangePercentage30D = priceChangePercentage30D
        self.priceChangePercentage1Y = priceChangePercentage1Y
    }
}

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

// MARK: - FullBinanceListElement


struct FullBinanceListElement: Codable, Hashable {
    var fullBinanceListDescription, displaySymbol, symbol, id: String?
    var rank : Int?

    enum CodingKeys: String, CodingKey {
        case fullBinanceListDescription = "description"
        case displaySymbol, symbol
    }
}

typealias FullBinanceList = [FullBinanceListElement]

//NEWS
struct News: Codable {
    let data: [NewsData]?

    enum CodingKeys: String, CodingKey {
        case data = "Data"

    }
}
struct NewsData: Codable {
    let id: String?
    let guid: String?
    let publishedOn: Int?
    let imageurl: String?
    let title: String?
    let url: String?
    let source, body, tags, categories: String?
    let upvotes, downvotes: String?
    let lang: Lang?
    let sourceInfo: SourceInfo?

    enum CodingKeys: String, CodingKey {
        case id, guid
        case publishedOn = "published_on"
        case imageurl, title, url, source, body, tags, categories, upvotes, downvotes, lang
        case sourceInfo = "source_info"
    }
}

enum Lang: String, Codable {
    case en = "EN"
}

struct SourceInfo: Codable {
    let name: String?
    let lang: Lang?
    let img: String?
}

// CoinGecko
struct GeckoListElement: Codable {
    var id, symbol, name : String?
    var rank : Int?
}

typealias GeckoList = [GeckoListElement]

//// MARK: - GeckoSymbol
//struct GeckoSymbol: Codable {
//    let name: String?
//    let blockTimeInMinutes: Int?
//    let links: Links?
//    let image: Image?
//    let genesisDate: String?
//    let sentimentVotesUpPercentage, sentimentVotesDownPercentage: Double?
//    let icoData: IcoData?
//    let marketCapRank, coingeckoRank: Int?
//    let coingeckoScore, developerScore, communityScore, liquidityScore: Double?
//    let publicInterestScore: Double?
//    let communityData: CommunityData?
//
//    enum CodingKeys: String, CodingKey {
//        case name
//        case blockTimeInMinutes = "block_time_in_minutes"
//        case links, image
//        case genesisDate = "genesis_date"
//        case sentimentVotesUpPercentage = "sentiment_votes_up_percentage"
//        case sentimentVotesDownPercentage = "sentiment_votes_down_percentage"
//        case icoData = "ico_data"
//        case marketCapRank = "market_cap_rank"
//        case coingeckoRank = "coingecko_rank"
//        case coingeckoScore = "coingecko_score"
//        case developerScore = "developer_score"
//        case communityScore = "community_score"
//        case liquidityScore = "liquidity_score"
//        case publicInterestScore = "public_interest_score"
//        case communityData = "community_data"
//    }
//}
//
//// MARK: - CommunityData
//struct CommunityData: Codable {
//    let twitterFollowers: Int?
//    let redditAveragePosts48H, redditAverageComments48H: Double?
//    let redditSubscribers, telegramChannelUserCount: Int?
//
//    enum CodingKeys: String, CodingKey {
//        case twitterFollowers = "twitter_followers"
//        case redditAveragePosts48H = "reddit_average_posts_48h"
//        case redditAverageComments48H = "reddit_average_comments_48h"
//        case redditSubscribers = "reddit_subscribers"
//        case telegramChannelUserCount = "telegram_channel_user_count"
//    }
//}
//
//// MARK: - IcoData
//struct IcoData: Codable {
//    let icoStartDate, icoEndDate, totalRaisedCurrency, totalRaised: String?
//
//    enum CodingKeys: String, CodingKey {
//        case icoStartDate = "ico_start_date"
//        case icoEndDate = "ico_end_date"
//        case totalRaisedCurrency = "total_raised_currency"
//        case totalRaised = "total_raised"
//    }
//}
//
//// MARK: - Image
//struct Image: Codable {
//    let thumb, small, large: String?
//}
//
//// MARK: - Links
//struct Links: Codable {
//    let homepage, blockchainSite: [String]?
//    let telegramChannelIdentifier: String?
//    let subredditURL: String?
//
//    enum CodingKeys: String, CodingKey {
//        case homepage
//        case blockchainSite = "blockchain_site"
//        case telegramChannelIdentifier = "telegram_channel_identifier"
//        case subredditURL = "subreddit_url"
//    }
//}


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



// MARK: - CommunityData
struct CommunityData: Decodable {
    let twitterFollowers: Int?
    let redditAveragePosts48H, redditAverageComments48H: Double?
    let redditSubscribers : Int?

    enum CodingKeys: String, CodingKey {
        case twitterFollowers = "twitter_followers"
        case redditAveragePosts48H = "reddit_average_posts_48h"
        case redditAverageComments48H = "reddit_average_comments_48h"
        case redditSubscribers = "reddit_subscribers"
    }
}
struct CommunityDataArray {
    let array : [MarketDataElem]
    init(communityData : CommunityData) {
        let twitterFollowers = String(communityData.twitterFollowers ?? 0)
        let redditAveragePosts48H = String(communityData.redditAveragePosts48H ?? 0)
        let redditAverageComments48H = String(communityData.redditAverageComments48H ?? 0)
        let redditSubscribers = String(communityData.redditSubscribers ?? 0)
        let array = [
            MarketDataElem(name: "twitterFollowers", value: twitterFollowers),
            MarketDataElem(name: "redditAveragePosts48H", value: redditAveragePosts48H),
            MarketDataElem(name: "redditAverageComments48H", value: redditAverageComments48H),
            MarketDataElem(name: "redditSubscribers", value: redditSubscribers)
        ]
        self.array = array
    }
}


struct MarketData: Decodable {
    let currentPrice: [String: Double]?
    let priceChange24H, priceChangePercentage24H, priceChangePercentage7D, priceChangePercentage30D, priceChangePercentage1Y : Double?
    let marketCap: [String: Double]?
    let marketCapRank: Int?
    let totalVolume, high24H, low24H: [String: Double]?
    let marketCapChangePercentage24H: Double?
    let maxSupply, circulatingSupply: Double?

     enum CodingKeys: String, CodingKey {
        case currentPrice = "current_price"
        case priceChange24H = "price_change_24h"
        case priceChangePercentage24H = "price_change_percentage_24h"
        case priceChangePercentage7D = "price_change_percentage_7d"
        case priceChangePercentage30D = "price_change_percentage_30d"
        case priceChangePercentage1Y = "price_change_percentage_1y"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case totalVolume = "total_volume"
        case high24H = "high_24h"
        case low24H = "low_24h"
        case marketCapChangePercentage24H = "market_cap_change_percentage_24h"
        case maxSupply = "max_supply"
        case circulatingSupply = "circulating_supply"

     }
    
}


struct MarketDataArray {
    let array : [MarketDataElem]
    init(marketData : MarketData) {
        let marketCap = marketData.marketCap?["usd"]?.formattedWithSeparator
        let marketCapRank = marketData.marketCapRank?.formattedWithSeparator
        let totalVolume = marketData.totalVolume?["usd"]?.formattedWithSeparator
        let high24H = marketData.high24H?["usd"]?.formattedWithSeparator
        let low24H = marketData.low24H?["usd"]?.formattedWithSeparator
        let marketCapChangePercentage24H = marketData.marketCapChangePercentage24H?.formattedWithSeparator
        let maxSupply = marketData.maxSupply?.formattedWithSeparator
        let circulatingSupply = marketData.circulatingSupply?.formattedWithSeparator
        let array = [
            MarketDataElem(name: "marketCap", value: "$\(marketCap ?? "")"),
            MarketDataElem(name: "marketCapRank", value: marketCapRank ?? ""),
            MarketDataElem(name: "totalVolume", value: "$\(totalVolume ?? "")"),
            MarketDataElem(name: "high24H", value:"$\(high24H ?? "")"),
            MarketDataElem(name: "low24H", value: "$\(low24H ?? "")"),
            MarketDataElem(name: "marketCapChangePercentage24H", value: "\(marketCapChangePercentage24H ?? "")%"),
            MarketDataElem(name: "maxSupply", value: "$\(maxSupply ?? "")"),
            MarketDataElem(name: "circulatingSupply", value: "$\(circulatingSupply ?? "")")
        ]
//        let marketCap = String(marketData.marketCap?["usd"] ?? 0)
//        let marketCapRank = String(marketData.marketCapRank ?? 0)
//        let totalVolume = String(marketData.totalVolume?["usd"] ?? 0)
//        let high24H = String(marketData.high24H?["usd"] ?? 0)
//        let low24H = String(marketData.low24H?["usd"] ?? 0)
//        let marketCapChangePercentage24H = String(marketData.marketCapChangePercentage24H ?? 0)
//        let maxSupply = String(marketData.maxSupply ?? 0)
//        let circulatingSupply = String(marketData.circulatingSupply ?? 0)
//        let array = [
//            MarketDataElem(name: "marketCap", value: marketCap),
//            MarketDataElem(name: "marketCapRank", value: marketCapRank),
//            MarketDataElem(name: "totalVolume", value: totalVolume),
//            MarketDataElem(name: "high24H", value: high24H),
//            MarketDataElem(name: "low24H", value: low24H),
//            MarketDataElem(name: "marketCapChangePercentage24H", value: marketCapChangePercentage24H),
//            MarketDataElem(name: "maxSupply", value: maxSupply),
//            MarketDataElem(name: "circulatingSupply", value: circulatingSupply)
//        ]
        self.array = array
    }
}

struct MarketDataElem {
    let name : String
    let value : String
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

//struct SearchElement {
//    var name : String?
//    var symbol : String?
//}



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
    static func decodeArray(with decoder: JSONDecoder = JSONDecoder(), from data: Data) throws -> [Self]{
        do {
            let newdata = try decoder.decode([Self].self, from: data)
            return newdata
        } catch {
            print("decodable model error", error.localizedDescription)
            return []
        }
    }
}

