//
//  ChartAndPriceExtension.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 29.09.2021.
//

import UIKit

extension ChartViewController {
     func setupChartAndPriceView(){
        chartAndPriceView.addSubview(priceOfCrypto)
        
        priceOfCrypto.centerXAnchor.constraint(equalTo: chartAndPriceView.centerXAnchor).isActive = true
        priceOfCrypto.topAnchor.constraint(equalTo: chartAndPriceView.topAnchor, constant: 20).isActive = true
        
        chartAndPriceView.addSubview(diffPriceOfCrypto)
        diffPriceOfCrypto.centerXAnchor.constraint(equalTo: chartAndPriceView.centerXAnchor).isActive = true
        diffPriceOfCrypto.topAnchor.constraint(equalTo: priceOfCrypto.bottomAnchor, constant: 5).isActive = true
        
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

