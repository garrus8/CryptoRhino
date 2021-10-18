//
//  HeaderCollectionReusableView.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 30.08.2021.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
    
    static let id = "HeaderCollectionReusableView"
    
    private let label : UILabel = {
        let label = UILabel()
        label.text = "Trending search"
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 22)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
    }
    func changeText(str : String) {
        label.text = str
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
        label.frame = CGRect(x: 20, y: Int(bounds.minY) + 10, width: Int(bounds.width), height: Int(bounds.height))
    }
}
