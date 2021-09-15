//
//  SearchTableViewCell.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 02.07.2021.
//

import UIKit

class SearchTableViewCell: UICollectionViewCell {
    
    static var reuseId: String = "SearchTableViewCell"
    
    let nameOfCrypto : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFProDisplay-Medium", size: 15)
        label.textColor = .white
        return label
    }()
    let symbolOfCrypto : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFCompactText-Regular", size: 14)
        label.textColor = UIColor(hexString: "#C2B6D7")
        return label
    }()
    
   

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hexString: "#202F72")
        setupElements()
        setupConstraints()
        
        self.layer.cornerRadius = 10
        self.layer.shadowPath = UIBezierPath(rect: self.layer.bounds).cgPath
        self.layer.shadowColor = UIColor(red: 0.023, green: 0.087, blue: 0.367, alpha: 0.3).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 10
        self.layer.shadowOffset = CGSize(width: 0, height: -4)
        self.clipsToBounds = true
        
        
    }

    
    func setupElements() {
        nameOfCrypto.translatesAutoresizingMaskIntoConstraints = false
        symbolOfCrypto.translatesAutoresizingMaskIntoConstraints = false
    }
    
//    func configure(with crypto: FullBinanceListElement) {
//        nameOfCrypto.text = crypto.displaySymbol
//        symbolOfCrypto.text = crypto.fullBinanceListDescription
//    }
    func configure(with crypto: GeckoListElement) {
        nameOfCrypto.text = crypto.name
        symbolOfCrypto.text = crypto.symbol
        
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
        nameOfCrypto.topAnchor.constraint(equalTo: topAnchor, constant: 11).isActive = true
        nameOfCrypto.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
//        nameOfCrypto.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 16).isActive = true
        nameOfCrypto.widthAnchor.constraint(equalToConstant: 128).isActive = true
        
        // lastMessageLabel constraints
        symbolOfCrypto.topAnchor.constraint(equalTo: nameOfCrypto.bottomAnchor).isActive = true
        symbolOfCrypto.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        symbolOfCrypto.widthAnchor.constraint(equalToConstant: 128).isActive = true
        

        
    }
}