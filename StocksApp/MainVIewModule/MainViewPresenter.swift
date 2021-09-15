//
//  MainViewPresenter.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 14.09.2021.
//

import UIKit

protocol MainViewPresenterProtocol : AnyObject {
    init(view: MainViewControllerProtocol, builder : Builder)
    func launchMethods()
    func setupDataSource()
    func createCompositionalLayout() -> UICollectionViewLayout
    func reloadData()
    func showChartView(crypto : Crypto)
    func returnDataSource() -> UICollectionViewDiffableDataSource<SectionOfCrypto, Crypto>?
}

class MainViewPresenter : MainViewPresenterProtocol {
    
    let view : MainViewControllerProtocol
    var dataSource : UICollectionViewDiffableDataSource<SectionOfCrypto, Crypto>?
    var sections = [SectionOfCrypto]()
    var builder : Builder
    
    required init(view: MainViewControllerProtocol, builder : Builder) {
        self.view = view
        self.builder = builder
    }
    
    func launchMethods() {
        if NetworkMonitor.shared.isConnected {
            
            NetworkManager.shared.getData()
            NetworkManager.shared.getFullCoinCapList()
            NetworkManager.shared.getTopOfCrypto()
            NetworkManager.shared.getTopSearch()
            NetworkManager.shared.groupOne.wait()
            NetworkManager.shared.getFullListOfCoinGecko()
            NetworkManager.shared.collectionViewLoad()


            view.setupCollectionView()
            setupDataSource()

            if NetworkManager.shared.coinCapDict.count != 0 {
            NetworkManager.shared.putCoinGeckoData(array: &NetworkManager.shared.results, group: NetworkManager.shared.groupTwo, otherArray: NetworkManager.shared.collectionViewArray)
            NetworkManager.shared.putCoinGeckoData(array: &NetworkManager.shared.resultsF, group: NetworkManager.shared.groupTwo, otherArray: [])
            NetworkManager.shared.groupTwo.wait()
            NetworkManager.shared.putCoinGeckoData(array: &NetworkManager.shared.collectionViewArray, group: NetworkManager.shared.groupThree, otherArray: NetworkManager.shared.results)
            
            NetworkManager.shared.webSocket2(symbols: NetworkManager.shared.websocketArray)
            NetworkManager.shared.receiveMessage(tableView: [], collectionView: [view.returnCollectionView()])
            NetworkManager.shared.groupThree.wait()
            NetworkManager.shared.setupSections()
            reloadData()
            NetworkManager.shared.updateUI(collectionViews: [view.returnCollectionView()])
            NetworkManager.shared.recoursiveUpdateUI(collectionViews: [view.returnCollectionView()])

//                NotificationCenter.default.addObserver(view, selector: #selector(view.reloadCollectionView), name: NSNotification.Name(rawValue: "newImage"), object: nil)
            }
        } else {
            let alert = UIAlertController(title: "No internet connection", message: "Check your internet connection and restart the app", preferredStyle: .alert)
            view.present(alert, animated: true)
        }
        
    }
    func setupDataSource() {
        //            CollectionViewGroup.enter()
        dataSource = UICollectionViewDiffableDataSource<SectionOfCrypto, Crypto>(collectionView: view.returnCollectionView(), cellProvider: { (collectionView, indexPath, crypto) -> UICollectionViewCell? in
            let carousel = SectionOfCrypto(type: "carousel", title: "Top (by Market Cap)", items: NetworkManager.shared.collectionViewArray)
            let table = SectionOfCrypto(type: "table", title: "Hot (by 24H Volume)", items: NetworkManager.shared.results)
            self.sections = [carousel,table]
            switch NetworkManager.shared.sections[indexPath.section].type {
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
        //            CollectionViewGroup.leave()
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let section = NetworkManager.shared.sections[sectionIndex]
            switch section.type {
            case "carousel" :
                return self.view.createCarouselSection()
            default:
                return self.view.createTableSection()
            }
        }
        
        return layout
    }
    
    func reloadData() {
        NetworkManager.shared.groupSetupSections.wait()
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionOfCrypto, Crypto>()
        snapshot.appendSections(NetworkManager.shared.sections)
        
        for section in NetworkManager.shared.sections {
            snapshot.appendItems(section.items, toSection: section)
        }
        dataSource?.apply(snapshot)
        
    }
    
    func returnDataSource() -> UICollectionViewDiffableDataSource<SectionOfCrypto, Crypto>? {
        return dataSource
    }
    
    func showChartView(crypto : Crypto) {
        let chartVC = builder.createChartViewModule(crypto: crypto)
        view.navigationController?.pushViewController(chartVC, animated: true)
    }
}
