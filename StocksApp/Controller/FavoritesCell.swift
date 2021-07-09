//
//  FavoritesCell.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 09.07.2021.
//

import UIKit

class FavoritesCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
     super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(white: 1, alpha: 1)
        setupElements()
        setupConstraints()
        
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        
    }
    static var reuseId: String = "FavoritesCell"
    
    
    var friendImageView = UIImageView()
    var nameOfCrypto = UILabel()
    var symbolOfCrypto = UILabel()
    var price = UILabel()
    var percent = UILabel()
    
    
    func setupElements() {
        nameOfCrypto.translatesAutoresizingMaskIntoConstraints = false
        symbolOfCrypto.translatesAutoresizingMaskIntoConstraints = false
        friendImageView.translatesAutoresizingMaskIntoConstraints = false
        price.translatesAutoresizingMaskIntoConstraints = false
        percent.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configure(with crypto: Crypto) {
        nameOfCrypto.text = crypto.nameOfCrypto
        symbolOfCrypto.text = crypto.symbolOfCrypto
        price.text = crypto.price
        percent.text = crypto.percent
        friendImageView.image = UIImage()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Constraints
extension FavoritesCell {
    func setupConstraints() {
        addSubview(friendImageView)
        addSubview(nameOfCrypto)
        addSubview(symbolOfCrypto)
        addSubview(price)
        addSubview(percent)
        
        // oponentImageView constraints
        friendImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        friendImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        friendImageView.widthAnchor.constraint(equalToConstant: 78).isActive = true
        friendImageView.heightAnchor.constraint(equalToConstant: 78).isActive = true
        
        
        // oponentLabel constraints
        nameOfCrypto.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        nameOfCrypto.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16).isActive = true
//        nameOfCrypto.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 16).isActive = true
        nameOfCrypto.widthAnchor.constraint(equalToConstant: 128).isActive = true
        
        // lastMessageLabel constraints
        symbolOfCrypto.topAnchor.constraint(equalTo: nameOfCrypto.bottomAnchor).isActive = true
        symbolOfCrypto.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16).isActive = true
        symbolOfCrypto.widthAnchor.constraint(equalToConstant: 128).isActive = true
        
        price.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        price.leadingAnchor.constraint(equalTo: nameOfCrypto.trailingAnchor, constant: 36).isActive = true
        price.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 26).isActive = true
        
        percent.topAnchor.constraint(equalTo: price.bottomAnchor).isActive = true
        percent.leadingAnchor.constraint(equalTo: symbolOfCrypto.trailingAnchor, constant: 36).isActive = true
        percent.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 26).isActive = true
        
    }
}
