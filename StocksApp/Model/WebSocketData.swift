//
//  DataManager.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 25.02.2021.
//

import Foundation

struct WebSocketData : Decodable {
    let data: [Datum]?
    
}

struct Datum: Decodable {
    let p: Double?
    let s: String?
    
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
