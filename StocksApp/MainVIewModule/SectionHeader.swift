//
//  SectionHeader.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 22.06.2021.
//

import UIKit

class SectionHeader : UICollectionReusableView {
    
    let title = UILabel()
    static let reuseId = "SectionHeader"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customize()
        constraints()
    }
    
    func customize() {
        title.textColor = .black
        title.font = UIFont(name: "AvenirNext-DemiBold", size: 22)
        title.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func constraints() {
        addSubview(title)
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor),
            title.bottomAnchor.constraint(equalTo: bottomAnchor),
            title.trailingAnchor.constraint(equalTo: trailingAnchor),
            title.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
