//
//  ChartAndPriceExtension.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 29.09.2021.
//

import UIKit

extension ChartViewController {
     func setupChartAndPriceView(){
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "arrow.2.circlepath", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal)
        imageView.contentMode = .scaleAspectFit
        let converterView = UIView()
        converterView.translatesAutoresizingMaskIntoConstraints = false
        
        chartAndPriceView.addSubview(converterView)
        converterView.addSubview(cryptoTextField)
        converterView.addSubview(currencyTextField)
        converterView.addSubview(converterCryptoLabel)
        converterView.addSubview(converterCurrencyLabel)
        converterView.addSubview(imageView)
        
        converterView.topAnchor.constraint(equalTo: chartAndPriceView.topAnchor, constant: 24).isActive = true
        converterView.widthAnchor.constraint(equalTo: chartAndPriceView.widthAnchor).isActive = true
        converterView.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        converterCryptoLabel.trailingAnchor.constraint(equalTo: cryptoTextField.leadingAnchor, constant: -8).isActive = true
        converterCryptoLabel.leadingAnchor.constraint(equalTo: converterView.leadingAnchor, constant: 5).isActive = true
        converterCryptoLabel.topAnchor.constraint(equalTo: converterView.topAnchor).isActive = true
        converterCryptoLabel.bottomAnchor.constraint(equalTo: converterView.bottomAnchor).isActive = true
        
        cryptoTextField.topAnchor.constraint(equalTo: converterView.topAnchor).isActive = true
        cryptoTextField.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -12).isActive = true
        cryptoTextField.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -117).isActive = true
        cryptoTextField.bottomAnchor.constraint(equalTo: converterView.bottomAnchor).isActive = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        imageView.centerXAnchor.constraint(equalTo: converterView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: converterView.centerYAnchor).isActive = true
                
        converterCurrencyLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 55).isActive = true
        converterCurrencyLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12).isActive = true
        converterCurrencyLabel.topAnchor.constraint(equalTo: converterView.topAnchor).isActive = true
        converterCurrencyLabel.bottomAnchor.constraint(equalTo: converterView.bottomAnchor).isActive = true
        
        currencyTextField.trailingAnchor.constraint(equalTo: converterView.trailingAnchor, constant: -12).isActive = true
        currencyTextField.leadingAnchor.constraint(equalTo: converterCurrencyLabel.trailingAnchor, constant: 8).isActive = true
        currencyTextField.topAnchor.constraint(equalTo: converterView.topAnchor).isActive = true
        currencyTextField.bottomAnchor.constraint(equalTo: converterView.bottomAnchor).isActive = true
        
        
        chartAndPriceView.addSubview(priceOfCrypto)
        
        priceOfCrypto.centerXAnchor.constraint(equalTo: chartAndPriceView.centerXAnchor, constant: -54).isActive = true
        priceOfCrypto.topAnchor.constraint(equalTo: converterView.bottomAnchor, constant: 36).isActive = true
        
        chartAndPriceView.addSubview(diffPriceOfCrypto)
        
//        diffPriceOfCrypto.centerXAnchor.constraint(equalTo: chartAndPriceView.centerXAnchor, constant: 54).isActive = true
        diffPriceOfCrypto.leadingAnchor.constraint(equalTo: priceOfCrypto.trailingAnchor, constant: 10).isActive = true
        diffPriceOfCrypto.widthAnchor.constraint(equalToConstant: 80).isActive = true
//        diffPriceOfCrypto.topAnchor.constraint(equalTo: converterView.bottomAnchor, constant: 20).isActive = true
//        diffPriceOfCrypto.bottomAnchor.constraint(equalTo: priceOfCrypto.bottomAnchor).isActive = true
        
        diffPriceOfCrypto.centerYAnchor.constraint(equalTo: priceOfCrypto.centerYAnchor, constant: 5).isActive = true
        
//        let converterView = UIView()
//        converterView.translatesAutoresizingMaskIntoConstraints = false
//
//        chartAndPriceView.addSubview(converterView)
//        converterView.addSubview(cryptoTextField)
//        converterView.addSubview(currencyTextField)
//        converterView.addSubview(converterCryptoLabel)
//        converterView.addSubview(converterCurrencyLabel)
//        converterView.addSubview(imageView)
//
//        converterView.topAnchor.constraint(equalTo: diffPriceOfCrypto.bottomAnchor, constant: 10).isActive = true
//        converterView.widthAnchor.constraint(equalTo: chartAndPriceView.widthAnchor).isActive = true
//        converterView.heightAnchor.constraint(equalToConstant: 33).isActive = true
//
//        converterCryptoLabel.trailingAnchor.constraint(equalTo: cryptoTextField.leadingAnchor, constant: -8).isActive = true
//        converterCryptoLabel.leadingAnchor.constraint(equalTo: converterView.leadingAnchor, constant: 12).isActive = true
//        converterCryptoLabel.topAnchor.constraint(equalTo: converterView.topAnchor).isActive = true
//        converterCryptoLabel.bottomAnchor.constraint(equalTo: converterView.bottomAnchor).isActive = true
//
//        cryptoTextField.topAnchor.constraint(equalTo: converterView.topAnchor).isActive = true
//        cryptoTextField.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -12).isActive = true
//        cryptoTextField.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -112).isActive = true
//        cryptoTextField.bottomAnchor.constraint(equalTo: converterView.bottomAnchor).isActive = true
//
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
//        imageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
//        imageView.centerXAnchor.constraint(equalTo: converterView.centerXAnchor).isActive = true
//        imageView.centerYAnchor.constraint(equalTo: converterView.centerYAnchor).isActive = true
//
//        converterCurrencyLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 55).isActive = true
//        converterCurrencyLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12).isActive = true
//        converterCurrencyLabel.topAnchor.constraint(equalTo: converterView.topAnchor).isActive = true
//        converterCurrencyLabel.bottomAnchor.constraint(equalTo: converterView.bottomAnchor).isActive = true
//
//        currencyTextField.trailingAnchor.constraint(equalTo: converterView.trailingAnchor, constant: -12).isActive = true
//        currencyTextField.leadingAnchor.constraint(equalTo: converterCurrencyLabel.trailingAnchor, constant: 8).isActive = true
//        currencyTextField.topAnchor.constraint(equalTo: converterView.topAnchor).isActive = true
//        currencyTextField.bottomAnchor.constraint(equalTo: converterView.bottomAnchor).isActive = true
    

        
        let buttonsView = UIView()
        buttonsView.layer.cornerRadius = 7
        buttonsView.layer.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1).cgColor
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        
        chartAndPriceView.addSubview(buttonsView)
        buttonsView.centerXAnchor.constraint(equalTo: chartAndPriceView.centerXAnchor).isActive = true
        buttonsView.bottomAnchor.constraint(equalTo: chartAndPriceView.bottomAnchor).isActive = true
        buttonsView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        buttonsView.widthAnchor.constraint(equalTo: chartAndPriceView.widthAnchor, constant: -20).isActive = true
        
        buttonsView.addSubview(dayChartButton)
        dayChartButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor, constant: 3).isActive = true
        dayChartButton.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: 3).isActive = true
        dayChartButton.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.size.width - 46) / 4).isActive = true
        dayChartButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        buttonsView.addSubview(weekChartButton)
        weekChartButton.leadingAnchor.constraint(equalTo: dayChartButton.trailingAnchor, constant: 5).isActive = true
        weekChartButton.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: 3).isActive = true
        weekChartButton.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.size.width - 46) / 4).isActive = true
        weekChartButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        buttonsView.addSubview(monthChartButton)
        monthChartButton.leadingAnchor.constraint(equalTo: weekChartButton.trailingAnchor, constant: 5).isActive = true
        monthChartButton.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: 3).isActive = true
        monthChartButton.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.size.width - 46) / 4).isActive = true
        monthChartButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        buttonsView.addSubview(yearChartButton)
        yearChartButton.leadingAnchor.constraint(equalTo: monthChartButton.trailingAnchor, constant: 5).isActive = true
        yearChartButton.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: 3).isActive = true
        yearChartButton.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.size.width - 46) / 4).isActive = true
        yearChartButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        chartAndPriceView.addSubview(lineChartView)
        lineChartView.centerXAnchor.constraint(equalTo: chartAndPriceView.centerXAnchor).isActive = true
        lineChartView.topAnchor.constraint(equalTo: diffPriceOfCrypto.bottomAnchor, constant: 10).isActive = true
        lineChartView.widthAnchor.constraint(equalTo: chartAndPriceView.widthAnchor, constant: -20).isActive = true
        lineChartView.bottomAnchor.constraint(equalTo: buttonsView.topAnchor, constant: -5).isActive = true
    }
}

