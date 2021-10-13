//
//  ExtensionsForChartView.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 08.10.2021.
//

import UIKit


extension UITextField {
    func addBottomBorder(){
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
        bottomLine.backgroundColor = UIColor(red: 0.388, green: 0.486, blue: 0.887, alpha: 1).cgColor
        borderStyle = .none
        layer.addSublayer(bottomLine)
    }
}
