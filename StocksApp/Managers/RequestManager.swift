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
        guard let nsUrl = NSURL(string: url) else {return}
        let request = NSMutableURLRequest(
            url: nsUrl as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        if url == Urls.fullCoinCapList.rawValue {
            request.setValue( "Bearer ebb5b8d0-64a8-4f93-bc12-c6539115e99b", forHTTPHeaderField: "Authorization")
        }
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let stocksData = data, error == nil, response != nil else {return}
            complition(stocksData,response,error)
        }.resume()
    }
}
