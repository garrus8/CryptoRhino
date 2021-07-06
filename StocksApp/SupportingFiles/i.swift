//
//  i.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 24.06.2021.
//

import UIKit

extension UIButton {
    convenience init(cornerRadius : CGFloat) {
        self.init(type : .system)
        self.layer.cornerRadius = cornerRadius
    }
}
