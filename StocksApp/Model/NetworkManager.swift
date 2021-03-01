//
//  NetworkManager.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 25.02.2021.
//

import Foundation

class NetworkManager {
    
    let mboumToken = Constants.mboumToken
    
//        func fetchFirst(completionHandler: @escaping (StocksInfo) -> Void) {
//            let request = NSMutableURLRequest(
//                url: NSURL(string: "https://mboum.com/api/v1/co/collections/?list=day_gainers&start=1")! as URL,
//                cachePolicy: .useProtocolCachePolicy,
//                timeoutInterval: 10.0)
//            request.httpMethod = "GET"
//            request.allHTTPHeaderFields = mboumToken
//
//            let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
//                guard let data = data else {
//                    print(String(describing: error))
//                    return
//                }
//
//                if let stocksInfo = self.parseJSON(withData: data) {
//                    print(stocksInfo)
//                }
//
//            })
//
//            dataTask.resume()
//
//        }
//
//        func parseJSON (withData data : Data) -> StocksInfo? {
//
//            do {
//                let stocksData = try JSONDecoder().decode(StocksData.self, from: data)
//
//                guard let stocksInfo = StocksInfo(stocksData: stocksData) else {return nil}
//
//                return stocksInfo
//
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
//            return nil
//        }
    
    
    
    
    
}
