//
//  ContentViewForChartView.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 29.07.2021.
//

import UIKit

class ContentViewForChartView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        self.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
//        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
//        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
//        contentView.heightAnchor.constraint(equalToConstant: 1400).isActive = true
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1400)
    }
}

