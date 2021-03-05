//
//  DirectStockData.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 02.03.2021.
//

import Foundation

struct DirectStockData: Codable {
    
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


    enum CodingKeys: String, CodingKey {
        case regularMarketChange, regularMarketPrice, shortName, symbol
    }

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
