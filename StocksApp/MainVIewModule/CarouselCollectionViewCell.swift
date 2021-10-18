//
//  CarouselCollectionViewCell.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 22.06.2021.
//

import UIKit

class CarouselCollectionViewCell: UICollectionViewCell {
    
    static var reuseId: String = "CarouselCollectionViewCell"
    private let imageView = UIImageView()
    private let nameOfCrypto : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    private let symbolOfCrypto : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 13)
        label.textColor = UIColor(red: 0.717, green: 0.807, blue: 1, alpha: 1)
        return label
    }()
    private let price : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Medium", size: 15)
        label.textColor = UIColor(red: 0.913, green: 0.943, blue: 1, alpha: 1)
        return label
    }()
    private let percent : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Medium", size: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.062, green: 0.139, blue: 0.467, alpha: 1)
        setupElements()
        setupConstraints()

        layer.cornerRadius = 10
        layer.shadowPath = UIBezierPath(rect: self.layer.bounds).cgPath
        layer.shadowColor = UIColor(red: 0.083, green: 0.13, blue: 0.333, alpha: 0.4).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 3)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupElements() {
        nameOfCrypto.translatesAutoresizingMaskIntoConstraints = false
        symbolOfCrypto.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        price.translatesAutoresizingMaskIntoConstraints = false
        percent.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configure(with crypto: Crypto) {
        
        nameOfCrypto.text = crypto.nameOfCrypto
        symbolOfCrypto.text = crypto.symbolOfCrypto
        imageView.image = crypto.image
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        
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
extension CarouselCollectionViewCell {
    
    func setupConstraints() {
        addSubview(imageView)
        addSubview(nameOfCrypto)
        addSubview(symbolOfCrypto)
        addSubview(price)
        addSubview(percent)
        
        nameOfCrypto.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        nameOfCrypto.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12).isActive = true
        nameOfCrypto.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -5).isActive = true
        
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        symbolOfCrypto.topAnchor.constraint(equalTo: nameOfCrypto.bottomAnchor, constant: 4).isActive = true
        symbolOfCrypto.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12).isActive = true
        symbolOfCrypto.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        price.bottomAnchor.constraint(equalTo: percent.topAnchor, constant: -4).isActive = true
        price.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12).isActive = true
        price.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12).isActive = true
        
        percent.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12).isActive = true
        percent.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12).isActive = true
        percent.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12).isActive = true
    }
}
