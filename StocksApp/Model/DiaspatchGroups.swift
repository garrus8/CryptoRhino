//
//  DiaspatchGroups.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 17.09.2021.
//

import Foundation

class DispatchGroups {
    let groupOne = DispatchGroup()
    let groupTwo = DispatchGroup()
    let groupThree = DispatchGroup()
    let groupFour = DispatchGroup()
    let groupSetupSections = DispatchGroup()
    
    static let shared = DispatchGroups()
    private init() {}
}
