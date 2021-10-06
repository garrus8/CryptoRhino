////
////  ChartAndPriceView.swift
////  StocksApp
////
////  Created by Григорий Толкачев on 28.09.2021.
////
//
//import UIKit
//import Charts
//
//class ChartAndPriceView: UIView {
//
//    var viewController : ChartViewController!
//    
//    private let diffPriceOfCrypto: UILabel = {
//        let label = UILabel()
//        label.text = "diffPriceOfCrypto"
//        label.numberOfLines = 0
//        label.font = UIFont(name: "avenir", size: 15)
//        label.sizeToFit()
//        label.textColor = .white
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let priceOfCrypto: UILabel = {
//        let label = UILabel()
//        label.text = "priceOfCrypto"
//        label.numberOfLines = 0
//        label.font = UIFont(name: "avenir", size: 30)
//        label.sizeToFit()
//        label.textColor = .white
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private var dayChartButton : UIButton = {
//        let button = UIButton(setTitle: "day")
////        button.addTarget(self,
////                         action: #selector(dayChartButtonLoad),
////                         for: .touchUpInside)
//        button.layer.cornerRadius = 4
//        button.backgroundColor = UIColor(red: 0.324, green: 0.424, blue: 0.854, alpha: 1)
//        button.setTitleColor(.white, for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//        
//    }()
//    
//    private var weekChartButton : UIButton = {
//        let button = UIButton(setTitle: "week")
////        button.addTarget(self,
////                         action: #selector(weekChartButtonLoad),
////                         for: .touchUpInside)
//        button.layer.cornerRadius = 4
//        button.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
//        button.setTitleColor(.white, for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//        
//    }()
//    private var monthChartButton : UIButton = {
//        let button = UIButton(setTitle: "month")
////        button.addTarget(self,
////                         action: #selector(monthChartButtonLoad),
////                         for: .touchUpInside)
//        button.layer.cornerRadius = 4
//        button.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
//        button.setTitleColor(.white, for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//        
//    }()
//    private var yearChartButton : UIButton = {
//        let button = UIButton(setTitle: "year")
////        button.addTarget(self,
////                         action: #selector(yearChartButtonLoad),
////                         for: .touchUpInside)
//        button.layer.cornerRadius = 4
//        button.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
//        button.setTitleColor(.white, for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//        
//    }()
//    private let lineChartView : LineChartView = {
//        var chart = LineChartView()
//        chart.translatesAutoresizingMaskIntoConstraints = false
//        return chart
//    }()
//    
//    init(frame: CGRect, view : ChartViewController) {
//        super.init(frame: frame)
//        self.viewController = view
//        backgroundColor = UIColor(hexString: "#4158B7")
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupChartAndPriceView() {
//        addSubview(priceOfCrypto)
//        
//        priceOfCrypto.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        priceOfCrypto.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
//        
//        addSubview(diffPriceOfCrypto)
//        diffPriceOfCrypto.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        diffPriceOfCrypto.topAnchor.constraint(equalTo: priceOfCrypto.bottomAnchor, constant: 5).isActive = true
//        
//        let buttonsView = UIView()
//        buttonsView.layer.cornerRadius = 7
//        buttonsView.layer.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1).cgColor
//        buttonsView.translatesAutoresizingMaskIntoConstraints = false
//        
//        addSubview(buttonsView)
//        buttonsView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        buttonsView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//        buttonsView.heightAnchor.constraint(equalToConstant: 32).isActive = true
//        buttonsView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -20).isActive = true
//        
//        buttonsView.addSubview(dayChartButton)
//        dayChartButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor, constant: 3).isActive = true
//        dayChartButton.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: 3).isActive = true
//        dayChartButton.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.size.width - 46) / 4).isActive = true
//        dayChartButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
//        
//        buttonsView.addSubview(weekChartButton)
//        weekChartButton.leadingAnchor.constraint(equalTo: dayChartButton.trailingAnchor, constant: 5).isActive = true
//        weekChartButton.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: 3).isActive = true
//        weekChartButton.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.size.width - 46) / 4).isActive = true
//        weekChartButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
//        
//        buttonsView.addSubview(monthChartButton)
//        monthChartButton.leadingAnchor.constraint(equalTo: weekChartButton.trailingAnchor, constant: 5).isActive = true
//        monthChartButton.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: 3).isActive = true
//        monthChartButton.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.size.width - 46) / 4).isActive = true
//        monthChartButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
//        
//        buttonsView.addSubview(yearChartButton)
//        yearChartButton.leadingAnchor.constraint(equalTo: monthChartButton.trailingAnchor, constant: 5).isActive = true
//        yearChartButton.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: 3).isActive = true
//        yearChartButton.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.size.width - 46) / 4).isActive = true
//        yearChartButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
//        
//        
//        addSubview(lineChartView)
//        lineChartView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        lineChartView.topAnchor.constraint(equalTo: diffPriceOfCrypto.bottomAnchor, constant: 10).isActive = true
//        lineChartView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -20).isActive = true
//        lineChartView.bottomAnchor.constraint(equalTo: buttonsView.topAnchor, constant: -5).isActive = true
//    }
//    
//}
