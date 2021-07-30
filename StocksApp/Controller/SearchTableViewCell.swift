//
//  SearchTableViewCell.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 02.07.2021.
//

import UIKit

class SearchTableViewCell: UICollectionViewCell {
    
    static var reuseId: String = "SearchTableViewCell"
    
    let nameOfCrypto = UILabel()
    let symbolOfCrypto = UILabel()
   

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

 
    
    func setupElements() {
        nameOfCrypto.translatesAutoresizingMaskIntoConstraints = false
        symbolOfCrypto.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configure(with crypto: Crypto) {
        nameOfCrypto.text = crypto.nameOfCrypto
        symbolOfCrypto.text = crypto.symbolOfCrypto
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Constraints
extension SearchTableViewCell {
    func setupConstraints() {
        addSubview(nameOfCrypto)
        addSubview(symbolOfCrypto)
    
        
        // oponentLabel constraints
        nameOfCrypto.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        nameOfCrypto.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
//        nameOfCrypto.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 16).isActive = true
        nameOfCrypto.widthAnchor.constraint(equalToConstant: 128).isActive = true
        
        // lastMessageLabel constraints
        symbolOfCrypto.topAnchor.constraint(equalTo: nameOfCrypto.bottomAnchor).isActive = true
        symbolOfCrypto.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        symbolOfCrypto.widthAnchor.constraint(equalToConstant: 128).isActive = true
        

        
    }
}