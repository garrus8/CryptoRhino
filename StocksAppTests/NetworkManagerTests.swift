//
//  NetworkManagerTests.swift
//  StocksAppTests
//
//  Created by Григорий Толкачев on 05.10.2021.
//

import XCTest
@testable import StocksApp

class NetworkManagerTests: XCTestCase {
    
    var sut : NetworkManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = NetworkManager()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}


