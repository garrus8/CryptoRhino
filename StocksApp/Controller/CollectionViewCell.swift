//
//  CollectionViewCell.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 18.05.2021.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameOfElelm: UILabel!
    @IBOutlet weak var index: UILabel!
    var textViewTest = String()
    var percent = String()
    var symbolOfCrypto = String()
    var symbolOfTicker = String()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // IMAGE = nil
    }
    
    func update(item : Crypto) {
        self.nameOfElelm.text = item.nameOfCrypto
        self.index.text = String(item.index)
        self.textViewTest = item.descriptionOfCrypto!
        self.percent = String(item.percent)
        self.symbolOfCrypto = item.symbolOfCrypto
        self.symbolOfTicker = "BINANCE:\(item.symbolOfCrypto)USDT"
        
    }
    
}
