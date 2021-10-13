//
//  NetworkManager.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 17.09.2021.
//

import Foundation

protocol WebSocketProtocol {
    func webSocket (symbols: [String])
    func receiveMessage()
}
// WEBSOCKET
final class WebSocketManager : WebSocketProtocol {
    
//    private let webSocketTask = URLSession(configuration: .default).webSocketTask(with: URL(string: Urls.webSocket.rawValue)!)
    private let webSocketTask = URLSession(configuration: .default).webSocketTask(with: URL(string: FinHubApiRandomizer.api)!)
    
    func webSocket (symbols: [String]) {
        DispatchGroups.shared.groupOne.wait()
        DispatchGroups.shared.groupTwo.wait()
        DispatchQueue.global().async {
            print("123123123123--___----__", FinHubApiRandomizer.api)
            let set = Set(symbols)
            for symbol in set {
                let symbolForFinHub = "BINANCE:\(symbol)USDT"
                let message = URLSessionWebSocketTask.Message.string("{\"type\":\"subscribe\",\"symbol\":\"\(symbolForFinHub)\"}")
                
                self.webSocketTask.send(message) { error in
                    if let error = error {
                        print("WebSocket couldn’t send message because: \(error)")
                    }
                }
            }
            self.webSocketTask.resume()
            self.ping()
        }
    }
    
    
    private func ping() {
        DispatchQueue.global().async(qos: .utility) {
            self.webSocketTask.sendPing { error in
                if let error = error {
                    print("Error when sending PING \(error)")
                } else {
                    print("Web Socket connection is alive")
                    DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                        self.ping()
                    }
                }
            }
        }
    }
    
    
    func receiveMessage() {
        DispatchGroups.shared.groupOne.wait()
        DispatchGroups.shared.groupTwo.wait()
        
        DispatchQueue.global().async {
            self.webSocketTask.receive { [weak self] result in
                guard let self = self else {return}
                switch result {
                case .failure(let error):
                    print("Error in receiving message: \(error)")
                case .success(let message):
                    switch message {
                    case .string(let text):
                        if let data: Data = text.data(using: .utf8) {
                            if let tickData = try? WebSocketData.decode(from: data)?.data {
                                self.putDataFromWebSocket(tickData: tickData, array: DataSingleton.shared.collectionViewArray)
                                self.putDataFromWebSocket(tickData: tickData, array: DataSingleton.shared.results)
                                self.putDataFromWebSocket(tickData: tickData, array: DataSingleton.shared.resultsF, isFavorite: true)
                            }
                        }
                        
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
    
    
    private func putDataFromWebSocket (tickData : [Datum], array : [Crypto], isFavorite : Bool = false) {
        for itemA in tickData {
            for (indexB,itemB) in array.enumerated() {
                let itemBForFinHub = "BINANCE:\(itemB.symbolOfCrypto.uppercased())USDT"
                if itemA.s == itemBForFinHub {
                    DispatchQueue.global().async(flags: .barrier) {
                        array[indexB].priceLabel = itemA.p.toString()
                    }
                }
            }
        }
    }
}
