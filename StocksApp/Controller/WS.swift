//
//  WS.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 04.03.2021.
//

import Foundation
class WSManager {
    let finHubToken = Constants.finHubToken
    let webSocketTask = URLSession(configuration: .default).webSocketTask(with: URL(string: "wss://ws.finnhub.io?token=c0vndt748v6t383lk63g")!)
    func webSocket() {
        let message = URLSessionWebSocketTask.Message.string("{'type':'subscribe', 'symbol': 'AAPL'}")
        webSocketTask.send(message) { error in
            if let error = error {
                print("WebSocket couldn’t send message because: \(error)")
            }
        }
        webSocketTask.resume()
    }
    
    func receiveMessage() {
        webSocketTask.receive { result in
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received string: \(text)")
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    fatalError()
                }
                
                self.receiveMessage()
            }
        }
    }
}
