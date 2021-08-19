//
//  MarketDataCell.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 21.07.2021.
//

import UIKit

class MarketDataCell: UITableViewCell {
    
    static var reuseId: String = "MarketDataCell"
    
    let name = UILabel()
    let value = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
        name.translatesAutoresizingMaskIntoConstraints = false
        value.translatesAutoresizingMaskIntoConstraints = false
        setupConstraints()
    }
    func configure (with marketData: MarketDataElem) {
        name.text = marketData.name
        name.textColor = .white
        name.font = UIFont(name: "avenir", size: 14)
        
        value.text = marketData.value
        value.textColor = .white
        value.font = UIFont(name: "avenir", size: 14)
        
    }
    func setupConstraints() {
        addSubview(name)
        addSubview(value)
        name.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        name.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        name.trailingAnchor.constraint(lessThanOrEqualTo: value.leadingAnchor).isActive = true
        name.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        name.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 5).isActive = true
        
        value.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        value.leadingAnchor.constraint(greaterThanOrEqualTo: name.trailingAnchor).isActive = true
        value.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        value.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        name.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 5).isActive = true
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
