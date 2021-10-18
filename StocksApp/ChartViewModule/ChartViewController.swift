//
//  ChartViewController.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 06.04.2021.
//

import UIKit
import Charts
import SafariServices

protocol ChartViewControllerProtocol : UIViewController {
    var activityIndicator: UIActivityIndicatorView { get set }
    func reloadCommunityDataTableView()
    func reloadMarketDataTableView()
    func updateContentViewFrame(contentViewFrameChange : CGFloat, detailInfoViewFrameChange : CGFloat, scrollViewChange : CGFloat)
    func navigationBarSetup()
    func setData(dataSet: LineChartDataSet, xAxisValueFormatter: ChartViewPresenter.MyXAxisFormatter)
    func lineChartViewSetup()
    func updateData()
}

class ChartViewController: UIViewController {

    var presenter : ChartViewPresenterProtocol!
    var scrollView = UIScrollView()
    private let contentView = UIView()
    let chartAndPriceView : UIView = {
        let chart = UIView()
        chart.backgroundColor = UIColor(hexString: "#4158B7")
        return chart
    }()
    let detailInfoView : UIView = {
        let view = UIView()
        return view
    }()
    let lineChartView : LineChartView = {
        var chart = LineChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        return chart
    }()
    var marketDataTableView = UITableView()
    var communityDataTableView = UITableView()
    private var contentViewFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 1520)
    private var detailInfoViewFrame = CGRect(x: 15, y: 633, width: UIScreen.main.bounds.size.width - 30, height: 890)
    let nameOfCrypto : UILabel = {
        let label = UILabel()
        label.text = "nameOfCrypto"
        label.numberOfLines = 0
        label.sizeToFit()
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let priceOfCrypto : UILabel = {
        let label = UILabel()
        label.text = "priceOfCrypto"
        label.numberOfLines = 0
        label.font = UIFont(name: "AvenirNext-Medium", size: 30)
        label.sizeToFit()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let cryptoTextField : UITextField = {
        let textField = UITextField()
        textField.keyboardType = .decimalPad
        textField.returnKeyType = .done
        textField.clearsOnBeginEditing = true
        textField.keyboardAppearance = .dark
        textField.textColor = .white
        textField.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        textField.textAlignment = .right
        textField.addTarget(self, action: #selector(cryptoTextFieldEditing), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    private func returnToolBar() -> UIToolbar {
        let bar = UIToolbar()
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissMyKeyboard))
        doneBtn.tintColor = .white
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bar.items = [flexSpace, flexSpace, doneBtn]
        bar.sizeToFit()
        return bar
    }
    @objc
    private func cryptoTextFieldEditing() {
        guard let number = cryptoTextField.text else {return}
        guard let double = Double(number) else {return}
        guard let currentPrice = converterCurrencyLabel.text else {return}
        let lowercased = currentPrice.lowercased()
        let convertNumber = presenter.converterFromCrypto(first: double, price: presenter.priceDict[lowercased])
        currencyTextField.text = convertNumber
    }
    let currencyTextField : UITextField = {
        let textField = UITextField()
        textField.keyboardType = .decimalPad
        textField.returnKeyType = .done
        textField.clearsOnBeginEditing = true
        textField.keyboardAppearance = .dark
        textField.textColor = .white
        textField.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        textField.textAlignment = .right
        textField.addTarget(self, action: #selector(currencyTextFieldEditing), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    @objc
    private func currencyTextFieldEditing() {
        guard let number = currencyTextField.text else {return}
        guard let double = Double(number) else {return}
        guard let currentPrice = converterCurrencyLabel.text else {return}
        let lowercased = currentPrice.lowercased()
        let convertNumber = presenter.converterToCrypto(second: double, price: presenter.priceDict[lowercased])
        cryptoTextField.text = convertNumber
    }
    let converterCryptoLabel : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.textColor = .white
        label.font = UIFont(name: "AvenirNext-Medium", size: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let converterCurrencyLabel : UITextField = {
        let label = UITextField()
        label.sizeToFit()
        label.textColor = UIColor(red: 0.053, green: 0.109, blue: 0.371, alpha: 1)
        label.backgroundColor = UIColor(red: 0.946, green: 0.956, blue: 1, alpha: 1)
        label.layer.cornerRadius = 5
        label.textAlignment = .center
        label.font = UIFont(name: "AvenirNext-Medium", size: 14)
        label.text = "USD"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let diffPriceOfCrypto: UILabel = {
        let label = UILabel()
        label.text = "diffPriceOfCrypto"
        label.numberOfLines = 0
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 15)
        label.sizeToFit()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let descriptionLabel : UILabel = {
        let textView = UILabel()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.masksToBounds = true
        textView.numberOfLines = 7
        textView.lineBreakMode = .byTruncatingTail
        textView.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
        textView.textColor = .white
        textView.sizeToFit()
        return textView
    }()
    private var computedDiffPrice : String {
        get {
            return diffPriceOfCrypto.text ?? ""
        }
        set(newValue) {
            if newValue.hasPrefix("-") {
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = UIImage(systemName: "arrowtriangle.down.fill")?.withTintColor(.red)
                
                let fullString = NSMutableAttributedString()
                fullString.append(NSAttributedString(attachment: imageAttachment))
                
                var copyOfNewValue = newValue
                copyOfNewValue.removeFirst()
                fullString.append(NSAttributedString(string: " \(copyOfNewValue)%"))
                
                diffPriceOfCrypto.attributedText = fullString
                diffPriceOfCrypto.textColor = UIColor(hexString: "#CC2B73")
            } else {
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = UIImage(systemName: "arrowtriangle.up.fill")?.withTintColor(.green)
                
                let fullString = NSMutableAttributedString()
                fullString.append(NSAttributedString(attachment: imageAttachment))
                fullString.append(NSAttributedString(string: " \(newValue)%"))

                diffPriceOfCrypto.attributedText = fullString
                diffPriceOfCrypto.textColor = UIColor.green
            }
        }
    }

    var dayChartButton : UIButton = {
        let button = UIButton(setTitle: "day")
        button.addTarget(self,
                         action: #selector(dayChartButtonLoad),
                         for: .touchUpInside)
        return button
    }()
    var activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    @objc
    private func dayChartButtonLoad() {
        presenter.removeValues()
        DispatchQueue.main.async {
            self.dayChartButton.backgroundColor = UIColor(red: 0.324, green: 0.424, blue: 0.854, alpha: 1)
            self.weekChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.monthChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.yearChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            if let idOfCrypto = self.presenter.labels[KeysOfLabels.idOfCrypto.rawValue] {
                self.presenter.chartLoad(idOfCrypto: idOfCrypto, interval: Interval.day)
            }
            if let percent = self.presenter.percentages.priceChangePercentage24H {
                self.computedDiffPrice = percent
            }
        }
    }
    var weekChartButton : UIButton = {
        let button = UIButton(setTitle: "week")
        button.addTarget(self,
                         action: #selector(weekChartButtonLoad),
                         for: .touchUpInside)
        return button
    }()
    @objc
    private func weekChartButtonLoad() {
        presenter.removeValues()
        DispatchQueue.main.async {
            self.dayChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.weekChartButton.backgroundColor = UIColor(red: 0.324, green: 0.424, blue: 0.854, alpha: 1)
            self.monthChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.yearChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            if let idOfCrypto = self.presenter.labels[KeysOfLabels.idOfCrypto.rawValue] {
                self.presenter.chartLoad(idOfCrypto: idOfCrypto, interval: Interval.week)
            }
            if let percent = self.presenter.percentages.priceChangePercentage7D {
                self.computedDiffPrice = percent
            }
        }
    }
    var monthChartButton : UIButton = {
        let button = UIButton(setTitle: "month")
        button.addTarget(self,
                         action: #selector(monthChartButtonLoad),
                         for: .touchUpInside)
        return button
        
    }()
    @objc
    private func monthChartButtonLoad() {
        presenter.removeValues()
        DispatchQueue.main.async {
            self.dayChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.weekChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.monthChartButton.backgroundColor = UIColor(red: 0.324, green: 0.424, blue: 0.854, alpha: 1)
            self.yearChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            if let idOfCrypto = self.presenter.labels[KeysOfLabels.idOfCrypto.rawValue] {
                self.presenter.chartLoad(idOfCrypto: idOfCrypto, interval: Interval.month)
            }
            if let percent = self.presenter.percentages.priceChangePercentage30D {
                self.computedDiffPrice = percent
            }
        }
    }
    var yearChartButton : UIButton = {
        let button = UIButton(setTitle: "year")
        button.addTarget(self,
                         action: #selector(yearChartButtonLoad),
                         for: .touchUpInside)
        return button
    }()
    @objc
    private func yearChartButtonLoad() {
        presenter.removeValues()
        DispatchQueue.main.async {
            self.dayChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.weekChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.monthChartButton.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
            self.yearChartButton.backgroundColor = UIColor(red: 0.324, green: 0.424, blue: 0.854, alpha: 1)
            if let idOfCrypto = self.presenter.labels[KeysOfLabels.idOfCrypto.rawValue] {
                self.presenter.chartLoad(idOfCrypto: idOfCrypto, interval: Interval.year)
            }
            if let percent = self.presenter.percentages.priceChangePercentage1Y {
                self.computedDiffPrice = percent
            }
        }
    }
    let onRedditButton : UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.969, green: 0.576, blue: 0.102, alpha: 1)
        button.layer.cornerRadius = 14
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Reddit", for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
        button.addTarget(self,
                         action: #selector(onReddit),
                         for: .touchUpInside)
        return button
    }()
    let onSiteButton : UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor(red: 0.969, green: 0.576, blue: 0.102, alpha: 1).cgColor
        button.setTitleColor(UIColor(red: 0.969, green: 0.576, blue: 0.102, alpha: 1), for: .normal)
        button.setTitle("Website", for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
        button.addTarget(self,
                         action: #selector(onSite),
                         for: .touchUpInside)
        return button
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var count = 0
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if count < 3 {
            setupScrollView()
        }
        count += 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
        setupChartAndPriceView()
        setupDetailInfo()
        navigationBarSetup()
        lineChartViewSetup()
        cryptoTextField.text = "1"
        currencyTextField.text = presenter.labels[KeysOfLabels.priceOfCrypto.rawValue]
        converterCryptoLabel.text = presenter.labels[KeysOfLabels.symbolOfCurrentCrypto.rawValue]
        setupChartButton(button: &dayChartButton)
        setupChartButton(button: &weekChartButton)
        setupChartButton(button: &monthChartButton)
        setupChartButton(button: &yearChartButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currencyTextField.addBottomBorder()
        cryptoTextField.addBottomBorder()
        setupPickerView()
        cryptoTextField.inputAccessoryView = returnToolBar()
        currencyTextField.inputAccessoryView =  returnToolBar()
        let bar =  returnToolBar()
        bar.barTintColor = UIColor(red: 0.058, green: 0.109, blue: 0.329, alpha: 1)
        converterCurrencyLabel.inputAccessoryView = bar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let idOfCrypto = presenter.labels[KeysOfLabels.idOfCrypto.rawValue] {
            presenter.chartLoad(idOfCrypto: idOfCrypto, interval: Interval.day)
        }
        marketDataTableView.register(MarketDataCell.self, forCellReuseIdentifier: "MarketDataCell")
        marketDataTableView.delegate = self
        marketDataTableView.dataSource = self
        communityDataTableView.register(MarketDataCell.self, forCellReuseIdentifier: "MarketDataCell")
        communityDataTableView.delegate = self
        communityDataTableView.dataSource = self
        currencyTextField.delegate = self
        cryptoTextField.delegate = self
        scrollView.delegate = self
        setupToHideKeyboardOnTapOnView()
    }
    
    func setupScrollView(){
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(chartAndPriceView)
        contentView.addSubview(detailInfoView)
        contentView.backgroundColor = UIColor(hexString: "#4158B7")
        detailInfoView.frame = detailInfoViewFrame
        chartAndPriceView.frame = CGRect(x:0.0, y: 0.0, width: view.frame.size.width, height: 630)
        contentView.frame = contentViewFrame
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scrollView.backgroundColor = UIColor(hexString: "#4158B7")
        scrollView.contentSize = CGSize(width: self.view.bounds.size.width, height: chartAndPriceView.frame.height + detailInfoView.frame.height)
    }
    
    @objc
    private func onReddit() {
        guard let redditUrl = presenter.labels[KeysOfLabels.redditUrl.rawValue] else {return}
        guard let url = URL(string: redditUrl) else {return}
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    
    @objc
    private func onSite() {
        guard let siteUrl = presenter.labels[KeysOfLabels.siteUrl.rawValue] else {return}
        guard let url = URL(string: siteUrl) else {return}
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }

    private var clickBool = true
    private var constHeightOfTextLabel = CGFloat()
    
    @objc
    func loadMore() {
        
        if clickBool == true {
            descriptionLabel.numberOfLines = 0
            descriptionLabel.lineBreakMode = .byWordWrapping
            constHeightOfTextLabel = descriptionLabel.frame.height
            let height = descriptionLabel.systemLayoutSizeFitting(CGSize(width: descriptionLabel.frame.width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
            scrollView.contentInset.bottom += (height - descriptionLabel.frame.height - 30)
            contentViewFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: contentViewFrame.height + height - constHeightOfTextLabel - 30)
            contentView.frame = contentViewFrame
            detailInfoViewFrame = CGRect(x: 15, y: 600, width: UIScreen.main.bounds.size.width - 30, height: detailInfoViewFrame.height + height - constHeightOfTextLabel)
            detailInfoView.frame = detailInfoViewFrame
            
            for elem in detailInfoView.subviews {
                if let stack = elem as? UIStackView {
                    for button in stack.arrangedSubviews {
                        if let button = button as? UIButton  {
                            let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
                            if button.imageView?.image == UIImage(systemName: "chevron.down", withConfiguration: imageConfig) {
                                button.setImage(UIImage(systemName: "chevron.up", withConfiguration: imageConfig), for: .normal)
                            }
                        }
                    }
                }
            }
        } else {
            descriptionLabel.numberOfLines = 7
            descriptionLabel.lineBreakMode = .byTruncatingTail
            scrollView.contentInset.bottom -= descriptionLabel.frame.height
            scrollView.contentInset.bottom += constHeightOfTextLabel
            scrollView.contentOffset = CGPoint(x: 0, y: 500)
            
            for elem in detailInfoView.subviews {
                if let stack = elem as? UIStackView {
                    for button in stack.arrangedSubviews {
                        if let button = button as? UIButton  {
                            let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
                            if button.imageView?.image == UIImage(systemName: "chevron.up", withConfiguration: imageConfig) {
                                button.setImage(UIImage(systemName: "chevron.down", withConfiguration: imageConfig), for: .normal)
                            }
                        }
                    }
                }
            }
            
        }
        clickBool.toggle()
    }
    @objc func dismissMyKeyboard(){
     view.endEditing(true)
     }
    func setupChartButton(button : inout UIButton) {
        if button.titleLabel?.text == "day" {
            button.backgroundColor = UIColor(red: 0.324, green: 0.424, blue: 0.854, alpha: 1)
        } else {
            button.backgroundColor = UIColor(red: 0.146, green: 0.197, blue: 0.421, alpha: 1)
        }
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 4
        button.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 15)
    }
}

extension ChartViewController : ChartViewControllerProtocol {

    func reloadMarketDataTableView() {
        marketDataTableView.reloadData()
    }
    func reloadCommunityDataTableView() {
        communityDataTableView.reloadData()
    }
    func updateData() {
        DispatchQueue.main.async { [self] in
            nameOfCrypto.text = presenter.labels[KeysOfLabels.symbolOfCurrentCrypto.rawValue]
            descriptionLabel.text = presenter.labels[KeysOfLabels.descriptionLabel.rawValue]
            computedDiffPrice = presenter.percentages.priceChangePercentage24H!
            priceOfCrypto.text?.removeAll()
            priceOfCrypto.text?.append("$")
            priceOfCrypto.text?.append(presenter.labels[KeysOfLabels.priceOfCrypto.rawValue] ?? "Name of crypto")
            currencyTextField.text = presenter.labels[KeysOfLabels.priceOfCrypto.rawValue]
        }
    }
    
    func updateContentViewFrame(contentViewFrameChange : CGFloat, detailInfoViewFrameChange : CGFloat, scrollViewChange : CGFloat) {
        self.contentViewFrame.size.height -= contentViewFrameChange
        self.detailInfoViewFrame.size.height -= detailInfoViewFrameChange
        self.scrollView.contentInset.bottom -= scrollViewChange
    }
    
    func navigationBarSetup() {
        DispatchQueue.main.async { [self] in
            let image : UIImage
            if presenter.bool {
                image = UIImage(systemName: "heart.fill") ?? UIImage()
            } else {
                image = UIImage(systemName: "heart") ?? UIImage()
            }
            let butt = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(saveTapped))
            
            navigationItem.rightBarButtonItem = butt
            navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 0.969, green: 0.576, blue: 0.102, alpha: 1)
            navigationController?.navigationBar.tintColor = .white
            
            let logoAndTitle = UIView()
            let label : UILabel = {
                let label = UILabel()
                label.text = " \(self.nameOfCrypto.text ?? "")"
                label.textColor = .white
                label.sizeToFit()
                label.center = logoAndTitle.center
                label.textAlignment = NSTextAlignment.center
                return label
            }()
            let logo : UIImageView = {
                let logo = UIImageView()
                logo.image = presenter.image
                let imageAspect = logo.image!.size.width/logo.image!.size.height
                logo.frame = CGRect(x: label.frame.origin.x-label.frame.size.height*imageAspect, y: label.frame.origin.y, width: label.frame.size.height*imageAspect, height: label.frame.size.height)
                logo.contentMode = UIView.ContentMode.scaleAspectFit
                logo.layer.cornerRadius = logo.frame.height/2
                logo.clipsToBounds = true
                return logo
            }()
            logoAndTitle.addSubview(label)
            logoAndTitle.addSubview(logo)
            navigationItem.titleView = logoAndTitle
        }
    }
    @objc
    private func saveTapped() {
        presenter.saveTapped()
    }
}

extension ChartViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    var arrayOfCurrency : [String] {
        return Array(presenter.priceDict.keys).map({$0.uppercased()}).sorted()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        arrayOfCurrency.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        arrayOfCurrency[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        converterCurrencyLabel.text = arrayOfCurrency[row]
        cryptoTextFieldEditing()
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        
        var pickerViewLabel = UILabel()
        
        if let currentLabel = view as? UILabel {
            pickerViewLabel = currentLabel
        } else {
            pickerViewLabel = UILabel()
        }
        
        pickerViewLabel.textColor = .white
        pickerViewLabel.textAlignment = .center
        pickerViewLabel.font = UIFont(name: "Avenir", size: 23)
        pickerViewLabel.text = arrayOfCurrency[row]
        
        return pickerViewLabel
    }
    
    private func setupPickerView() {
        let picker = UIPickerView()
        picker.backgroundColor = UIColor(red: 0.058, green: 0.109, blue: 0.329, alpha: 1)
        picker.tintColor = .white
        picker.delegate = self
        converterCurrencyLabel.inputView = picker
    }
}

extension ChartViewController : ChartViewDelegate {
    
    func lineChartViewSetup() {
        lineChartView.backgroundColor = UIColor(hexString: "#4158B7")
        lineChartView.leftAxis.enabled = false
        lineChartView.xAxis.setLabelCount(5, force: false)
        lineChartView.rightAxis.setLabelCount(8, force: false)
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelTextColor = .white
        lineChartView.rightAxis.labelTextColor = .white
        lineChartView.animate(xAxisDuration: 0.8)
    }
    
    func setData(dataSet: LineChartDataSet, xAxisValueFormatter: ChartViewPresenter.MyXAxisFormatter) {
        dataSet.label = ""
        dataSet.drawCirclesEnabled = false
        dataSet.mode = .linear
        dataSet.lineWidth = 1
        dataSet.setColor(UIColor(hexString: "F7931A"))
        dataSet.fill = Fill(color: UIColor(hexString: "#202F72"))
        dataSet.fillAlpha = 0.7
        dataSet.drawFilledEnabled = true
        dataSet.drawVerticalHighlightIndicatorEnabled = false
        dataSet.highlightColor = diffPriceOfCrypto.textColor
        let data = LineChartData(dataSet: dataSet)
        data.setDrawValues(false)
        lineChartView.data = data
        lineChartView.xAxis.valueFormatter = xAxisValueFormatter
    }
}

extension ChartViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == marketDataTableView {
            return presenter.marketData.count
        } else {
            return presenter.communityData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MarketDataCell.reuseId, for: indexPath) as? MarketDataCell else {return UITableViewCell()}
        if tableView == marketDataTableView {
            let marketDataElem = presenter.marketData[indexPath.row]
            cell.configure(with: marketDataElem)
        } else {
            let communityDataElem = presenter.communityData[indexPath.row]
            cell.configure(with: communityDataElem)
        }
        cell.backgroundColor = UIColor(hexString: "#4158B7")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ChartViewController : UITextFieldDelegate {
    
    func setupToHideKeyboardOnTapOnView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
