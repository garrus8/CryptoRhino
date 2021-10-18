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
        backgroundColor = UIColor(red: 0.062, green: 0.139, blue: 0.467, alpha: 1)
        setupElements()
        setupConstraints()
        
        self.layer.cornerRadius = 10
        self.layer.shadowPath = UIBezierPath(rect: self.layer.bounds).cgPath
        self.layer.shadowColor = UIColor(red: 0.023, green: 0.087, blue: 0.367, alpha: 0.3).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 10
        self.layer.shadowOffset = CGSize(width: 0, height: -4)
    }

    
    private func setupElements() {
        nameOfCrypto.translatesAutoresizingMaskIntoConstraints = false
        symbolOfCrypto.translatesAutoresizingMaskIntoConstraints = false
    }
    
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
    
    private func setupConstraints() {
        addSubview(nameOfCrypto)
        addSubview(symbolOfCrypto)
    
        nameOfCrypto.topAnchor.constraint(equalTo: topAnchor, constant: 11).isActive = true
        nameOfCrypto.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        nameOfCrypto.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
    
        symbolOfCrypto.topAnchor.constraint(equalTo: nameOfCrypto.bottomAnchor).isActive = true
        symbolOfCrypto.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        symbolOfCrypto.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
    }
}
