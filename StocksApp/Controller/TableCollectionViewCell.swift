//
//  TableCollectionViewCell.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 21.06.2021.
//

import UIKit

class TableCollectionViewCell: UICollectionViewCell {
    
    static var reuseId: String = "TableCollectionViewCell"
    
    let friendImageView  = UIImageView()
    let nameOfCrypto = UILabel()
    let symbolOfCrypto = UILabel()
    let price = UILabel()
    let percent = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 1, alpha: 1)
        setupElements()
        setupConstraints()
        self.backgroundColor = .brown
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        
    }
    
    func setupElements() {
        nameOfCrypto.translatesAutoresizingMaskIntoConstraints = false
        symbolOfCrypto.translatesAutoresizingMaskIntoConstraints = false
        friendImageView.translatesAutoresizingMaskIntoConstraints = false
        price.translatesAutoresizingMaskIntoConstraints = false
        percent.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configure (with crypto: Crypto) {
        nameOfCrypto.text = crypto.nameOfCrypto
        symbolOfCrypto.text = crypto.symbolOfCrypto
        price.text = crypto.price
        percent.text = crypto.percentages?.priceChangePercentage24H
        friendImageView.image = crypto.image
        friendImageView.layer.cornerRadius = friendImageView.frame.height/2
        friendImageView.clipsToBounds = true
    }
//    func configureForFavorite (with crypto: Crypto) {
//        nameOfCrypto.text = crypto.nameOfCrypto
//        symbolOfCrypto.text = crypto.symbolOfCrypto
//        price.text = crypto.price
//        percent.text = crypto.percent
//        friendImageView.image = UIImage(data: crypto.imageData!)
//    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Constraints
extension TableCollectionViewCell {
    func setupConstraints() {
        addSubview(friendImageView)
        addSubview(nameOfCrypto)
        addSubview(symbolOfCrypto)
        addSubview(price)
        addSubview(percent)
        
        // oponentImageView constraints
        friendImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        friendImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        friendImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        friendImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
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