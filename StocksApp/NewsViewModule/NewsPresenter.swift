//
//  NewsViewPresenter.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 15.09.2021.
//

import UIKit
import SafariServices


protocol NewsViewPresenterProtocol : AnyObject {
    var newsData: [NewsData] { get }
    func obtainImage (stringUrl: String, complition : @escaping (UIImage)->())
    func openSafari(indexPath : IndexPath)
}

class NewsViewPresenter : NewsViewPresenterProtocol {
    var newsData = [NewsData]()
    weak var view : NewsViewControllerProtocol!
    var networkManager : NetworkManagerForNewsProtocol!
    
    init(view : NewsViewControllerProtocol, networkManager : NetworkManagerForNewsProtocol) {
        self.view = view
        self.networkManager = networkManager
        DispatchQueue.main.async {
            self.view.activityIndicator.startAnimating()
            self.view.activityIndicator.isHidden = false
        }
        getNews()
    }
    
    func getNews() {
    
        DispatchQueue.global().async {
//            let request = NSMutableURLRequest(
//                url: NSURL(string: "https://min-api.cryptocompare.com/data/v2/news/?lang=EN")! as URL,
//                cachePolicy: .useProtocolCachePolicy,
//                timeoutInterval: 10.0)
//            request.httpMethod = "GET"
//            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            NetworkRequestManager.request(url: Urls.news.rawValue) { data, response, error in
                guard let stocksData = data, error == nil, response != nil else {return}
                
                do {
                    guard let newsData = try News.decode(from: stocksData) else {return}
                    guard let data = newsData.data else {return}
                    for i in 0..<data.count {
                        let news = data[i]
                        self.newsData.append(news)
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.view.activityIndicator.stopAnimating()
                        self.view.activityIndicator.isHidden = true
                    }
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
    }
    func obtainImage (stringUrl: String, complition : @escaping (UIImage)->()) {
        networkManager.obtainImage(StringUrl: stringUrl, group: DispatchGroup()) { image in
            complition(image)
        }
    }
    func openSafari(indexPath : IndexPath) {
        let elem = newsData[indexPath.item]
        guard let url = URL(string: elem.url!) else {return}
        let vc = SFSafariViewController(url: url)
        view.present(vc, animated: true, completion: nil)
    }
}
