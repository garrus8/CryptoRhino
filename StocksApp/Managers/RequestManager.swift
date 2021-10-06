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

final class NetworkRequestManager : NetworkRequest {
    
    static func request (url : String, complition : @escaping (Data?, URLResponse?, Error?) -> ()) {
        let request = NSMutableURLRequest(
            url: NSURL(string: url)! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let stocksData = data, error == nil, response != nil else {return}
            complition(stocksData,response,error)
        }.resume()
    }
}
