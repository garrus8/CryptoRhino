//
//  CarouselCollectionViewCell.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 22.06.2021.
//

import UIKit

class CarouselCollectionViewCell: UICollectionViewCell {
    static var reuseId: String = "CarouselCollectionViewCell"
    
    let friendImageView = UIImageView()
    let nameOfCrypto = UILabel()
    let symbolOfCrypto = UILabel()
    let price = UILabel()
    let percent = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 1, alpha: 1)
        setupElements()
        setupConstraints()

        friendImageView.frame = self.bounds
        addSubview(friendImageView)
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
extension CarouselCollectionViewCell {
    func setupConstraints() {
//        addSubview(friendImageView)
//        addSubview(nameOfCrypto)
        addSubview(symbolOfCrypto)
        addSubview(price)
//        addSubview(percent)
        
        
        // lastMessageLabel constraints
        symbolOfCrypto.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        symbolOfCrypto.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        symbolOfCrypto.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        price.topAnchor.constraint(equalTo: symbolOfCrypto.bottomAnchor, constant: 16).isActive = true
        price.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 36).isActive = true
        price.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 26).isActive = true
        
        
    }
}
