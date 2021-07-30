//
//  NewsCell.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 28.07.2021.
//

import UIKit


class NewsCell: UICollectionViewCell {
    
    static var reuseId: String = "NewsCell"
    
    let nameOfCrypto : UILabel = {
        let label =  UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
//        textView.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        label.numberOfLines = 3
//        label.lineBreakMode = .byTruncatingTail
        label.lineBreakMode = .byWordWrapping
//        label.font = UIFont.systemFont(ofSize: 16)
        label.sizeToFit()
        return label
    }()
    let symbolOfCrypto : UILabel = {
        let label =  UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
//        textView.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.systemFont(ofSize: 14)
        label.sizeToFit()
        return label
    }()
    let dateLable : UILabel = {
        let label =  UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = true
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.systemFont(ofSize: 10)
        label.sizeToFit()
        
        return label
    }()
    let imageView = UIImageView()
    
    var publishedOn : UILabel = {
    let label =  UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.layer.masksToBounds = true
    label.lineBreakMode = .byTruncatingTail
    label.font = UIFont.systemFont(ofSize: 8)
    label.sizeToFit()
    
    return label
}()

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
        imageView.translatesAutoresizingMaskIntoConstraints = false
        publishedOn.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configure(with newsData: NewsData) {
        nameOfCrypto.text = newsData.title
        symbolOfCrypto.text = newsData.body!
        let imageUrl = newsData.imageurl!
        NetworkManager.shared.obtainImage(StringUrl: imageUrl, group: DispatchGroup()) { image in
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
        
        let publishedOnDate = Double(newsData.publishedOn!)
        let date = NSDate(timeIntervalSince1970: publishedOnDate) as Date
        publishedOn.text = date.timeAgoDisplay()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Constraints
extension NewsCell {
    func setupConstraints() {
        addSubview(nameOfCrypto)
        addSubview(symbolOfCrypto)
        addSubview(imageView)
        addSubview(publishedOn)
    
        imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        // oponentLabel constraints
        nameOfCrypto.topAnchor.constraint(equalTo: topAnchor, constant: 6).isActive = true
        nameOfCrypto.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        nameOfCrypto.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -20).isActive = true
//        nameOfCrypto.heightAnchor.constraint(equalToConstant: 80).isActive = true
        nameOfCrypto.bottomAnchor.constraint(equalTo: symbolOfCrypto.topAnchor, constant: -6).isActive = true
//        nameOfCrypto.widthAnchor.constraint(equalToConstant: 128).isActive = true
        
        // lastMessageLabel constraints
//        symbolOfCrypto.topAnchor.constraint(equalTo: nameOfCrypto.bottomAnchor, constant: 2).isActive = true
        symbolOfCrypto.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -20).isActive = true
        symbolOfCrypto.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
//        symbolOfCrypto.widthAnchor.constraint(equalToConstant: 128).isActive = true
        symbolOfCrypto.heightAnchor.constraint(equalToConstant: 40).isActive = true
        symbolOfCrypto.bottomAnchor.constraint(equalTo: publishedOn.topAnchor, constant: -6).isActive = true
        
        publishedOn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).isActive = true
        publishedOn.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        publishedOn.heightAnchor.constraint(equalToConstant: 10).isActive = true
        publishedOn.widthAnchor.constraint(equalToConstant: 100).isActive = true
    
    }
}
