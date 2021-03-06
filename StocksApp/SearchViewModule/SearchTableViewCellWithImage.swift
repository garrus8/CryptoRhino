//
//  SearchTableViewCellWithImage.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 30.08.2021.
//

import UIKit

class SearchTableViewCellWithImage: UICollectionViewCell {

    static var reuseId: String = "SearchTableViewCellWithImage"

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

    let imageView = UIImageView()

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
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }

    func configure(with crypto: TopSearchItem) {
        nameOfCrypto.text = crypto.name
        symbolOfCrypto.text = crypto.symbol
        imageView.image = crypto.large
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Constraints
extension SearchTableViewCellWithImage {
    private func setupConstraints() {
        addSubview(nameOfCrypto)
        addSubview(symbolOfCrypto)
        addSubview(imageView)

        imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        nameOfCrypto.topAnchor.constraint(equalTo: topAnchor, constant: 11).isActive = true
        nameOfCrypto.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8).isActive = true
        nameOfCrypto.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true

        symbolOfCrypto.topAnchor.constraint(equalTo: nameOfCrypto.bottomAnchor).isActive = true
        symbolOfCrypto.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8).isActive = true
        symbolOfCrypto.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
    }
}

