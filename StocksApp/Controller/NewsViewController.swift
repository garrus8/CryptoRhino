//
//  NewsViewController.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 09.04.2021.
//

import UIKit

class NewsViewController: UITableViewController {
    
    var newsData = [NewsData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        getNews()

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
                    self.tableView.reloadData()
                }
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }.resume()
        
    }
    

    // MARK: - Table view data source
    
 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsData.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsTableViewCell
        cell.title.text = newsData[indexPath.row].title
        cell.body = newsData[indexPath.row].body!
        cell.url = newsData[indexPath.row].url!
       

        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailNewsVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailNewsViewController") as! DetailNewsViewController
        let newsItem = newsData[indexPath.row]
        detailNewsVC.newsTitleString = newsItem.title!
        detailNewsVC.newsBodyString = newsItem.body!
        detailNewsVC.newsUrlString = newsItem.url!
//        self.navigationController?.pushViewController(detailNewsVC, animated: true)
        present(detailNewsVC, animated: true, completion: nil)
    }

}
