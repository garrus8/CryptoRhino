//
//  CarouselCollectionViewCell.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 22.06.2021.
//

import UIKit

class CarouselCollectionViewCell: UICollectionViewCell {
    static var reuseId: String = "CarouselCollectionViewCell"
    
    let imageView = UIImageView()
    let nameOfCrypto : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 16)
        label.textColor = .white
        label.numberOfLines = 2
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
        label.font = UIFont(name: "Avenir", size: 14)
        label.textColor = UIColor(hexString: "#C2D8FF")
        return label
    }()
    let percent : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 15)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hexString: "#202F72")
        setupElements()
        setupConstraints()

        self.layer.cornerRadius = 10
        self.layer.shadowPath = UIBezierPath(rect: self.layer.bounds).cgPath
        self.layer.shadowColor = UIColor(red: 0.083, green: 0.13, blue: 0.333, alpha: 0.4).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 10
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.clipsToBounds = true
    }
    func setupElements() {
        nameOfCrypto.translatesAutoresizingMaskIntoConstraints = false
        symbolOfCrypto.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        price.translatesAutoresizingMaskIntoConstraints = false
        percent.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configure(with crypto: Crypto) {
        nameOfCrypto.text = crypto.nameOfCrypto
        symbolOfCrypto.text = crypto.symbolOfCrypto
        price.text = crypto.price
        price.text?.insert("$", at: price.text!.startIndex)
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
//            fullString.append(NSAttributedString(string: "%"))
            percent.attributedText = fullString
            percent.textColor = UIColor(red: 0.486, green: 0.863, blue: 0.475, alpha: 1)
        }
        
        imageView.image = crypto.image
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - Setup Constraints
extension CarouselCollectionViewCell {
    func setupConstraints() {
        addSubview(imageView)
        addSubview(nameOfCrypto)
        addSubview(symbolOfCrypto)
        addSubview(price)
        addSubview(percent)
        
        
        nameOfCrypto.topAnchor.constraint(equalTo: topAnchor, constant: 13).isActive = true
        nameOfCrypto.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
        nameOfCrypto.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -8).isActive = true
//        nameOfCrypto.heightAnchor.constraint(equalToConstant: 80).isActive = true
//        nameOfCrypto.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: 13).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        symbolOfCrypto.topAnchor.constraint(equalTo: nameOfCrypto.bottomAnchor, constant: 5).isActive = true
        symbolOfCrypto.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
        symbolOfCrypto.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
//        price.topAnchor.constraint(equalTo: symbolOfCrypto.bottomAnchor, constant: 16).isActive = true
        price.bottomAnchor.constraint(equalTo: percent.topAnchor, constant: -2).isActive = true
        price.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
        price.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
        
        percent.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -17).isActive = true
        percent.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
        percent.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true

    }
}
