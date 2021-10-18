//
//  NewsViewController.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 09.04.2021.
//

import UIKit

protocol NewsViewControllerProtocol : UIViewController {
    var activityIndicator: UIActivityIndicatorView { get set }
    var collectionView: UICollectionView! { get }
}

class NewsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NewsViewControllerProtocol  {

    var presenter : NewsViewPresenterProtocol!
    var collectionView : UICollectionView!
    var activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCollectionView()
    }
  
    func setupCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: self.view.frame.size.width - 30, height: 138)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor(hexString: "#4158B7")
        collectionView.register(NewsCell.self, forCellWithReuseIdentifier: NewsCell.reuseId)
        view.addSubview(collectionView)
        activityIndicator.center = view.center
        activityIndicator.color = .white
        collectionView.addSubview(activityIndicator)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
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
        presenter.openSafari(indexPath: indexPath)
    }
}
