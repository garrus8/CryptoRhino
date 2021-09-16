//
//  NetworkManager.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 13.05.2021.
//

import Foundation


protocol NetworkRequest {
    static func request(url : String, complition : @escaping (Data?, URLResponse?, Error?) -> ())
}

class NetworkRequestManager : NetworkRequest {
    
    static func request (url : String, complition : @escaping (Data?, URLResponse?, Error?) -> ()) {
        let request = NSMutableURLRequest(
            url: NSURL(string: url)! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
//        group.enter()
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let stocksData = data, error == nil, response != nil else {return}
            complition(stocksData,response,error)
        }.resume()
    }
    
//    private func decodeJSON<T: Decodable>(type: T.Type, from: Data?) -> T? {
//        let decoder = JSONDecoder()
//        guard let data = from, let response = try? decoder.decode(type.self, from: data) else { return nil }
//        return response
//    }
    
    
    
}
