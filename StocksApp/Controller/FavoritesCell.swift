//
//  FavoritesCell.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 09.07.2021.
//

import UIKit

class FavoritesCell: UICollectionViewCell {
    static var reuseId: String = "FavoritesCell"
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//     super.init(style: style, reuseIdentifier: reuseIdentifier)
//        backgroundColor = UIColor(white: 1, alpha: 1)
//        setupElements()
//        setupConstraints()
//
//        self.layer.cornerRadius = 8
//        self.clipsToBounds = true
//
//        let shadowPath2 = UIBezierPath(rect: self.bounds)
//        self.layer.masksToBounds = false
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOffset = CGSize(width: CGFloat(1.0), height: CGFloat(3.0))
//        self.layer.shadowOpacity = 0.5
//        self.layer.shadowPath = shadowPath2.cgPath
//
//    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 1, alpha: 1)
        setupElements()
        setupConstraints()
        
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
//        let shadowPath2 = UIBezierPath(rect: self.bounds)
//        self.layer.masksToBounds = false
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOffset = CGSize(width: CGFloat(1.0), height: CGFloat(3.0))
//        self.layer.shadowOpacity = 0.5
//        self.layer.shadowPath = shadowPath2.cgPath
        
    }
//    override var frame: CGRect {
//        get {
//            return super.frame
//        }
//        set (newFrame) {
//            var frame = newFrame
//            let newWidth = frame.width * 0.95
//            let space = (frame.width - newWidth) / 2
//            frame.size.width = newWidth
//            frame.origin.x += space
//
//            super.frame = frame
//
//        }
//    }
    
    
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
