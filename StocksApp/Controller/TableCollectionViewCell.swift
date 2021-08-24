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
    let nameOfCrypto : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 15)
        label.textColor = .white
        return label
    }()
    let symbolOfCrypto : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 14)
        label.textColor = UIColor(hexString: "#C2B6D7")
        return label
    }()
    let price : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 16)
        label.textColor = .white
        return label
    }()
    let percent : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 14)
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
        friendImageView.translatesAutoresizingMaskIntoConstraints = false
        price.translatesAutoresizingMaskIntoConstraints = false
        percent.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configure (with crypto: Crypto) {
        nameOfCrypto.text = crypto.nameOfCrypto
        symbolOfCrypto.text = crypto.symbolOfCrypto
        price.text = crypto.price
        price.text?.insert("$", at: price.text!.startIndex)
//        percent.text = crypto.percentages?.priceChangePercentage24H
        if crypto.percentages!.priceChangePercentage24H!.hasPrefix("-") {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "arrowtriangle.down.fill")?.withTintColor(.red)
            
            let fullString = NSMutableAttributedString()
            fullString.append(NSAttributedString(attachment: imageAttachment))
            if let percentages = crypto.percentages {
                guard var perc24h = percentages.priceChangePercentage24H else { return }
                perc24h.removeFirst()
                fullString.append(NSAttributedString(string: " \(perc24h)%"))
            }
            percent.attributedText = fullString
            percent.textColor = UIColor(hexString: "#CC2B73")
        } else {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "arrowtriangle.up.fill")?.withTintColor(.green)
            
            let fullString = NSMutableAttributedString()
            fullString.append(NSAttributedString(attachment: imageAttachment))
            if let percentages = crypto.percentages {
                fullString.append(NSAttributedString(string: " \(percentages.priceChangePercentage24H ?? "")%"))
            }
            percent.attributedText = fullString
            percent.textColor = UIColor(red: 0.486, green: 0.863, blue: 0.475, alpha: 1)
        }
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
        friendImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        friendImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        friendImageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        friendImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        
        // oponentLabel constraints
        nameOfCrypto.topAnchor.constraint(equalTo: self.topAnchor, constant: 11).isActive = true
        nameOfCrypto.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 15).isActive = true
//        nameOfCrypto.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 16).isActive = true
        nameOfCrypto.widthAnchor.constraint(equalToConstant: 128).isActive = true
        
        // lastMessageLabel constraints
        symbolOfCrypto.topAnchor.constraint(equalTo: nameOfCrypto.bottomAnchor, constant: 2).isActive = true
        symbolOfCrypto.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 15).isActive = true
        symbolOfCrypto.widthAnchor.constraint(equalToConstant: 128).isActive = true
        
        price.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        price.leadingAnchor.constraint(equalTo: nameOfCrypto.trailingAnchor, constant: 65).isActive = true
        price.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
        
        percent.topAnchor.constraint(equalTo: price.bottomAnchor).isActive = true
        percent.leadingAnchor.constraint(equalTo: symbolOfCrypto.trailingAnchor, constant: 65).isActive = true
        percent.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
        
    }
}
