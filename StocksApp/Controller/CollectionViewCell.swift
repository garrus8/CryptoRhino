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
    
    func update(item : Crypto) {
        self.nameOfElelm.text = item.nameOfCrypto
        self.index.text = String(item.index)
    }
    
}
