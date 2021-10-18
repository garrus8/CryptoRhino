//
//  SearchViewModel.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 15.09.2021.
//

import UIKit

struct GeckoListElement: Codable {
    
    var id, symbol, name : String?
    var rank : Int?
}

typealias GeckoList = [GeckoListElement]

struct TopSearchItem {
    
    let id: String
    let name, symbol: String
    let large: UIImage
}
