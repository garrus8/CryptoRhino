//
//  MainViewController.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 21.06.2021.
//

import UIKit

class MainViewController: UIViewController {
    
//    let searchController = UISearchController(searchResultsController: nil)
//    var searchBarIsEmpty : Bool {
//        guard let text = searchController.searchBar.text else {return false}
//        return text.isEmpty
//    }
//    private var isFiltering : Bool {
//        return searchController.isActive && !searchBarIsEmpty
//    }
    static let shared = MainViewController()
   
    var dataSource : UICollectionViewDiffableDataSource<SectionOfCrypto, Crypto>?
    var collectionView : UICollectionView!
    let CollectionViewGroup = DispatchGroup()
    var sections = [SectionOfCrypto]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        definesPresentationContext = true
        if NetworkMonitor.shared.isConnected {
            
            NetworkManager.shared.getData()
            NetworkManager.shared.getFullCoinCapList()
            NetworkManager.shared.getTopOfCrypto()
            NetworkManager.shared.getFullListOfCoinGecko()
            NetworkManager.shared.groupOne.wait()
            NetworkManager.shared.collectionViewLoad()


            setupCollectionView()
            setupDataSource()

//            NetworkManager.shared.groupOne.wait()
            if NetworkManager.shared.coinCapDict.count != 0 {
            NetworkManager.shared.putCoinGeckoData(array: &NetworkManager.shared.results, group: NetworkManager.shared.groupTwo, otherArray: NetworkManager.shared.collectionViewArray)
            NetworkManager.shared.putCoinGeckoData(array: &NetworkManager.shared.resultsF, group: NetworkManager.shared.groupTwo, otherArray: [])
            NetworkManager.shared.groupTwo.wait()
            NetworkManager.shared.putCoinGeckoData(array: &NetworkManager.shared.collectionViewArray, group: NetworkManager.shared.groupThree, otherArray: NetworkManager.shared.results)
            
            NetworkManager.shared.webSocket2(symbols: NetworkManager.shared.websocketArray)
            NetworkManager.shared.receiveMessage(tableView: [], collectionView: [self.collectionView])

            NetworkManager.shared.setupSections()
                if !NetworkManager.shared.results.isEmpty {
            reloadData()
                }
            NetworkManager.shared.updateUI(collectionViews: [self.collectionView])
            NetworkManager.shared.recoursiveUpdateUI(collectionViews: [self.collectionView])

            NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionView), name: NSNotification.Name(rawValue: "newImage"), object: nil)
            }
        } else {
            let alert = UIAlertController(title: "No internet connection", message: "Check your internet connection and restart the app", preferredStyle: .alert)
            self.present(alert, animated: true)
        }
       
    }
    
    @objc func reloadCollectionView() {
        DispatchQueue.main.async {
//            NetworkManager.shared.groupFour.wait()
            self.collectionView.reloadData()
            
        }
    }
    
    func setupCollectionView() {
        CollectionViewGroup.enter()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.contentInset.top += 10
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor(hexString: "#4158B7")
        view.addSubview(collectionView)
        collectionView.register(TableCollectionViewCell.self, forCellWithReuseIdentifier: TableCollectionViewCell.reuseId)
        collectionView.register(CarouselCollectionViewCell.self, forCellWithReuseIdentifier: CarouselCollectionViewCell.reuseId)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        collectionView.delegate = self
        //        collectionView.dataSource = self
        
        CollectionViewGroup.leave()
    }
    
    func setupDataSource() {
        CollectionViewGroup.enter()
        dataSource = UICollectionViewDiffableDataSource<SectionOfCrypto, Crypto>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, crypto) -> UICollectionViewCell? in
            let carousel = SectionOfCrypto(type: "carousel", title: "Top (by Market Cap)", items: NetworkManager.shared.collectionViewArray)
            let table = SectionOfCrypto(type: "table", title: "Hot (by 24H Volume)", items: NetworkManager.shared.results)
            self.sections = [carousel,table]
            switch NetworkManager.shared.sections[indexPath.section].type {
//            switch self.sections[indexPath.section].type {
            case "carousel" :
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCollectionViewCell.reuseId, for: indexPath) as! CarouselCollectionViewCell
                cell.configure(with: crypto)
                return cell
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TableCollectionViewCell.reuseId, for: indexPath) as! TableCollectionViewCell
                cell.configure(with: crypto)
                return cell
            }
        })
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else {return nil}
            guard let item = self.dataSource?.itemIdentifier(for: indexPath) else {return nil}
            guard let section = self.dataSource?.snapshot().sectionIdentifier(containingItem: item) else {return nil}
            if section.title.isEmpty {return nil}
            sectionHeader.title.text = section.title
            sectionHeader.title.font = UIFont(name: "Avenir", size: 22)
            sectionHeader.title.textColor = .white
            
            return sectionHeader
        }
        CollectionViewGroup.leave()
    }
    
    func reloadData() {
        NetworkManager.shared.groupSetupSections.wait()
    
            var snapshot = NSDiffableDataSourceSnapshot<SectionOfCrypto, Crypto>()
            snapshot.appendSections(NetworkManager.shared.sections)
        
            for section in NetworkManager.shared.sections {
                snapshot.appendItems(section.items, toSection: section)
            }
            self.dataSource?.apply(snapshot)
            
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let section = NetworkManager.shared.sections[sectionIndex]
//            let section = self.sections[sectionIndex]
            switch section.type {
            case "carousel" :
                return self.createCarouselSection()
            default:
                return self.createTableSection()
            }
        }
//        let config = UICollectionViewCompositionalLayoutConfiguration()
//
//        config.interSectionSpacing = 20
//        layout.configuration = config
        return layout
    }
    func createCarouselSection() -> NSCollectionLayoutSection  {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 8)
        
        
//        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(143),
//                                                     heightDimension: .estimated(143))
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
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(60))
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
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let crypto = self.dataSource!.itemIdentifier(for: indexPath) else { return }
//        let homeView = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
//        let ChartVC = ChartViewController(crypto: crypto)
        let ChartVC = ChartViewController()
//        let ChartVC = self.storyboard?.instantiateViewController(withIdentifier: "ChartViewController") as! ChartViewController
        ChartVC.crypto = crypto
        
//        present(ChartVC, animated: true, completion: nil)
        self.navigationController?.pushViewController(ChartVC, animated: true)
//        collectionView.deselectItem(at: indexPath, animated: true)
        
        
    }
}


