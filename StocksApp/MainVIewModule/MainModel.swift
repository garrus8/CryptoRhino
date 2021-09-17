//
//  MainViewModel.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 14.09.2021.
//

import Foundation


class SectionOfCrypto : Hashable, Equatable {
    
    static func == (lhs: SectionOfCrypto, rhs: SectionOfCrypto) -> Bool {
        lhs.type == rhs.type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
        
    var type: String
    var title : String
    var items : [Crypto]
    
    init(type : String, title : String, items : [Crypto]) {
        self.type = type
        self.title = title
        self.items = items
    }
}

