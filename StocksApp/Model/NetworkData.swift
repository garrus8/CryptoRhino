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

struct FullCoinCapList: Codable {
    
    let data: [[String: String?]]?
}


struct GetData: Decodable {
    
    let c : [Double]?
    let t : [Int]?
}

struct WebSocketData : Decodable {
    
    let data: [Datum]
    
}

struct Datum : Decodable  {
    
    let p: Double
    var s: String

}

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

struct Description: Codable {
    
    let en: String?
}

struct Image: Codable {
    
    let thumb, small, large: String?
}

struct Links: Codable {
    
    let homepage : [String]?
    let subredditURL: String?

    enum CodingKeys: String, CodingKey {
        case homepage
        case subredditURL = "subreddit_url"
    }
}

struct TopSearch: Decodable {
    
    let coins: [Coin]
}

struct Coin: Decodable {
    
    let item: Item
}

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



