//
//  NewsViewController.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 09.04.2021.
//

import UIKit
//import SafariServices

protocol NewsViewControllerProtocol : UIViewController {
    var activityIndicator: UIActivityIndicatorView { get set }
    var collectionView: UICollectionView! { get }
}

class NewsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NewsViewControllerProtocol  {

//    var newsData = [NewsData]()
    var presenter : NewsViewPresenterProtocol!
    var collectionView : UICollectionView!
    var activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
//        getNews()
        
    }
  
    func setupCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: self.view.frame.size.width - 30, height: 132)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor(hexString: "#4158B7")
        collectionView.register(NewsCell.self, forCellWithReuseIdentifier: NewsCell.reuseId)
        view.addSubview(collectionView)
        
        activityIndicator.center = view.center
        activityIndicator.color = .white
        collectionView.addSubview(activityIndicator)
//        DispatchQueue.main.async {
//        self.activityIndicator.startAnimating()
//        self.activityIndicator.isHidden = false
//        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
//    func getNews(){
//        DispatchQueue.global().async {
//            let request = NSMutableURLRequest(
//                url: NSURL(string: "https://min-api.cryptocompare.com/data/v2/news/?lang=EN")! as URL,
//                cachePolicy: .useProtocolCachePolicy,
//                timeoutInterval: 10.0)
//            request.httpMethod = "GET"
//            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
//                guard let stocksData = data, error == nil, response != nil else {return}
//
//                do {
//                    let newsData = try News.decode(from: stocksData)
//                    for i in 0..<(newsData?.data?.count)! {
//                        let news = newsData?.data![i]
//                        self.newsData.append(news!)
//
//                    }
//
//                    DispatchQueue.main.async {
//                        self.activityIndicator.stopAnimating()
//                        self.activityIndicator.isHidden = true
//                        self.collectionView.reloadData()
//                    }
//
//                } catch let error as NSError {
//                    print(error.localizedDescription)
//                }
//
//            }.resume()
//        }
//    }
    

    // MARK: - Table view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.newsData.count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsCell.reuseId, for: indexPath) as! NewsCell
        cell.presenter = self.presenter
        cell.configure(with: presenter.newsData[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
//        let elem = presenter.newsData[indexPath.item]
//        guard let url = URL(string: elem.url!) else {return}
//        let vc = SFSafariViewController(url: url)
//        present(vc, animated: true, completion: nil)
        presenter.openSafari(indexPath: indexPath)
    }
}
