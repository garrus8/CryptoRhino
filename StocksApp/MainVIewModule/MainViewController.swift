//
//  MainViewController.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 21.06.2021.
//

import UIKit

protocol MainViewControllerProtocol : UIViewController {
    func setupCollectionView()
    func returnCollectionView() -> UICollectionView
    func reloadCollectionView()
    func createCarouselSection() -> NSCollectionLayoutSection
    func createTableSection() -> NSCollectionLayoutSection
}

class MainViewController: UIViewController, MainViewControllerProtocol {
        
    var presenter : MainViewPresenterProtocol!
    
    static let shared = MainViewController()
   
//    var dataSource : UICollectionViewDiffableDataSource<SectionOfCrypto, Crypto>?
    var collectionView : UICollectionView!
    let CollectionViewGroup = DispatchGroup()
//    var sections = [SectionOfCrypto]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        presenter.launchMethods()
    }
    
    @objc func reloadCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func setupCollectionView() {
        CollectionViewGroup.enter()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: presenter.createCompositionalLayout())
        collectionView.contentInset.top += 10
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor(hexString: "#4158B7")
        view.addSubview(collectionView)
        collectionView.register(TableCollectionViewCell.self, forCellWithReuseIdentifier: TableCollectionViewCell.reuseId)
        collectionView.register(CarouselCollectionViewCell.self, forCellWithReuseIdentifier: CarouselCollectionViewCell.reuseId)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        collectionView.delegate = self
        CollectionViewGroup.leave()
    }
    
    func returnCollectionView() -> UICollectionView {
        return self.collectionView
    }
    
    func createCarouselSection() -> NSCollectionLayoutSection  {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 12)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(143),
                                                     heightDimension: .absolute(143))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [layoutItem])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 20, leading: 15, bottom: 20, trailing: 7)
        let header = createSectionHeader()
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    func createTableSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(71))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(71))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20 , leading: 15, bottom: 0, trailing: 15)
        
        let header = createSectionHeader()
        
        section.boundarySupplementaryItems = [header]
        
        return section
        
    }
    
    func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        return header
    }
    

}
// MARK: - Нужно сделать роутер и вернуть дид селект!

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        presenter.showChartView(indexPath : indexPath)
    }
}


