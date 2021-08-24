//
//  NewsViewController.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 09.04.2021.
//

import UIKit
import SafariServices

class NewsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    var newsData = [NewsData]()
    var collectionView : UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        getNews()

    }
    func setupCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: self.view.frame.size.width - 30, height: 132)
//        self.view.frame.size.height / 6
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor(hexString: "#4158B7")
        collectionView.register(NewsCell.self, forCellWithReuseIdentifier: NewsCell.reuseId)
        view.addSubview(collectionView)
//        layout.itemSize = CGSize(width: collectionView.bounds.width - 20, height: 60)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    func getNews(){
        
        let request = NSMutableURLRequest(
            url: NSURL(string: "https://min-api.cryptocompare.com/data/v2/news/?lang=EN")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let stocksData = data, error == nil, response != nil else {return}
            
            do {
                let newsData = try News.decode(from: stocksData)
                for i in 0..<(newsData?.data?.count)! {
                    let news = newsData?.data![i]
                    self.newsData.append(news!)
                
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }.resume()
        
    }
    

    // MARK: - Table view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        newsData.count
        
    }
    
    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return newsData.count
//    }


//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsTableViewCell
//        cell.title.text = newsData[indexPath.row].title
//        cell.body = newsData[indexPath.row].body!
//        cell.url = newsData[indexPath.row].url!
//
//
//        return cell
//    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsCell.reuseId, for: indexPath) as! NewsCell
//        cell.nameOfCrypto.text = newsData[indexPath.item].title
//        cell.symbolOfCrypto.text = newsData[indexPath.item].body!
////        cell.url = newsData[indexPath.item].url!
//        let url = newsData[indexPath.item].url!
//        NetworkManager.shared.obtainImage(StringUrl: url, group: DispatchGroup()) { image in
//            cell.imageView.image = image
//        }
        cell.configure(with: newsData[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let elem = newsData[indexPath.item]
        guard let url = URL(string: elem.url!) else {return}
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
        
        }

//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let detailNewsVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailNewsViewController") as! DetailNewsViewController
//        let newsItem = newsData[indexPath.row]
//        detailNewsVC.newsTitleString = newsItem.title!
//        detailNewsVC.newsBodyString = newsItem.body!
//        detailNewsVC.newsUrlString = newsItem.url!
////        self.navigationController?.pushViewController(detailNewsVC, animated: true)
//        present(detailNewsVC, animated: true, completion: nil)
//    }

}
