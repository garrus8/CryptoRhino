//
//  TableCollectionViewCell.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 21.06.2021.
//

import UIKit

class TableCollectionViewCell: UICollectionViewCell {
    
    static var reuseId: String = "TableCollectionViewCell"
    let friendImageView = UIImageView()
    let nameOfCrypto : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Medium", size: 17)
        label.textColor = .white
        return label
    }()
    let symbolOfCrypto : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 13)
        label.textColor = UIColor(hexString: "#C2B6D7")
        return label
    }()
    let price : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Medium", size: 15)
        label.textColor = .white
        return label
    }()
    let percent : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Medium", size: 14)
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
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupElements() {
        nameOfCrypto.translatesAutoresizingMaskIntoConstraints = false
        symbolOfCrypto.translatesAutoresizingMaskIntoConstraints = false
        friendImageView.translatesAutoresizingMaskIntoConstraints = false
        price.translatesAutoresizingMaskIntoConstraints = false
        percent.translatesAutoresizingMaskIntoConstraints = false
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        friendImageView.layer.cornerRadius = friendImageView.frame.height/2
        friendImageView.clipsToBounds = true
    }
    
    func configure (with crypto: Crypto) {
        nameOfCrypto.text = crypto.nameOfCrypto
        symbolOfCrypto.text = crypto.symbolOfCrypto
        friendImageView.image = crypto.image
        
        if let priceOfCrypto = crypto.priceLabel {
        price.text = "$" + priceOfCrypto
        }
        guard let percentages = crypto.percentages?.priceChangePercentage24H else {return}
        
        if percentages.hasPrefix("-") {
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
            percent.textColor = UIColor(red: 0.8, green: 0.169, blue: 0.451, alpha: 1)
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
    }
}

// MARK: - Setup Constraints
extension TableCollectionViewCell {
    
    private func setupConstraints() {
        addSubview(friendImageView)
        addSubview(nameOfCrypto)
        addSubview(symbolOfCrypto)
        addSubview(price)
        addSubview(percent)
        
        friendImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12).isActive = true
        friendImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        friendImageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        friendImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        nameOfCrypto.topAnchor.constraint(equalTo: self.topAnchor, constant: 11).isActive = true
        nameOfCrypto.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 8).isActive = true
        nameOfCrypto.trailingAnchor.constraint(equalTo: price.leadingAnchor, constant: -5).isActive = true
        
        symbolOfCrypto.topAnchor.constraint(equalTo: nameOfCrypto.bottomAnchor, constant: 4).isActive = true
        symbolOfCrypto.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 8).isActive = true
        nameOfCrypto.trailingAnchor.constraint(equalTo: percent.leadingAnchor, constant: -5).isActive = true
        
        price.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        price.widthAnchor.constraint(equalToConstant: 100).isActive = true
        price.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12).isActive = true
        
        percent.topAnchor.constraint(equalTo: price.bottomAnchor).isActive = true
        percent.widthAnchor.constraint(equalToConstant: 100).isActive = true
        percent.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12).isActive = true
        
    }
}
