//
//  NewsCell.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 28.07.2021.
//

import UIKit


class NewsCell: UICollectionViewCell {
    
    static var reuseId: String = "NewsCell"
    var presenter : NewsViewPresenterProtocol!
    
    let nameOfCrypto : UILabel = {
        let label =  UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.layer.masksToBounds = true
        label.numberOfLines = 3
//        label.lineBreakMode = .byTruncatingTail
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont(name: "Avenir", size: 14)
        label.textColor = .white
        label.sizeToFit()
        return label
    }()
    let symbolOfCrypto : UILabel = {
        let label =  UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
//        textView.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont(name: "Avenir", size: 12)
        //SFCompactText-Regular
        label.textColor = UIColor(red: 0.643, green: 0.766, blue: 0.996, alpha: 1)
        label.sizeToFit()
        return label
    }()

    let imageView : UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 7
        image.clipsToBounds = true
        return image
    }()
    
    var publishedOn : UILabel = {
    let label =  UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.layer.masksToBounds = true
    label.lineBreakMode = .byTruncatingTail
    label.font = UIFont.systemFont(ofSize: 8)
        label.textColor = .white
    label.sizeToFit()
    
    return label
}()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.062, green: 0.139, blue: 0.467, alpha: 1)
        setupElements()
        setupConstraints()
        self.layer.cornerRadius = 15
//        self.clipsToBounds = true
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 0).cgPath
        layer.shadowColor = UIColor(red: 0.024, green: 0.086, blue: 0.369, alpha: 0.3).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: -4)

        
    }
    
    func setupElements() {
        nameOfCrypto.translatesAutoresizingMaskIntoConstraints = false
        symbolOfCrypto.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        publishedOn.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configure(with newsData: NewsData) {
        nameOfCrypto.text = newsData.title
        symbolOfCrypto.text = newsData.body?.html2String
        let imageUrl = newsData.imageurl!

        presenter.obtainImage(stringUrl: imageUrl) { image in
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
//        addSubview(nameOfCrypto)
//        addSubview(symbolOfCrypto)
        addSubview(imageView)
        addSubview(publishedOn)
    
        imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -6).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 133).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        let arrangedSubviews : [UIView] = [nameOfCrypto,symbolOfCrypto]
        
        let stack = UIStackView(arrangedSubviews: arrangedSubviews)
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        
        stack.topAnchor.constraint(equalTo: self.topAnchor, constant: 13).isActive = true
        stack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 7).isActive = true
        stack.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -9).isActive = true
        stack.bottomAnchor.constraint(equalTo: publishedOn.topAnchor, constant: -6).isActive = true
        
        publishedOn.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -6).isActive = true
        publishedOn.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 7).isActive = true
        publishedOn.heightAnchor.constraint(equalToConstant: 10).isActive = true
        publishedOn.widthAnchor.constraint(equalToConstant: 100).isActive = true
    
    }
}
