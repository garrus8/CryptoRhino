//
//  ChartViewModel.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 17.09.2021.
//

import Foundation


enum Interval : String {
    case day; case week; case month; case year
}
enum KeysOfLabels : String {
    case symbolOfCurrentCrypto; case descriptionLabel; case nameOfCrypto; case computedDiffPrice; case priceOfCrypto; case idOfCrypto; case symbolOfTicker; case redditUrl; case siteUrl; case imageString
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

        self.array = array
    }
}

struct MarketDataElem {
    let name : String
    let value : String
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
