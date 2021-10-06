//
//  MainViewPresenter.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 14.09.2021.
//

import UIKit

protocol MainViewPresenterProtocol : AnyObject {
    init(view: MainViewControllerProtocol, builder : Builder, networkManager : NetworkManagerMainProtocol, webSocketManager : WebSocketProtocol, coreDataManager : CoreDataManagerForMainProtocol)
    func launchMethods()
    func setupDataSource()
    func createCompositionalLayout() -> UICollectionViewLayout
    func reloadData()
    func showChartView(indexPath : IndexPath)
//    func returnDataSource() -> UICollectionViewDiffableDataSource<SectionOfCrypto, Crypto>?
}

class MainViewPresenter : MainViewPresenterProtocol {
 
    private weak var view : MainViewControllerProtocol!
    
    var dataSource : UICollectionViewDiffableDataSource<SectionOfCrypto, Crypto>?
    var sections = [SectionOfCrypto]()
    var builder : Builder
    var networkManager : NetworkManagerMainProtocol!
    var webSocketManager : WebSocketProtocol!
    var coreDataManager : CoreDataManagerForMainProtocol!
    
    required init(view: MainViewControllerProtocol, builder : Builder,
                  networkManager : NetworkManagerMainProtocol,
                  webSocketManager : WebSocketProtocol,
                  coreDataManager : CoreDataManagerForMainProtocol) {
        self.view = view
        self.builder = builder
        self.networkManager = networkManager
        self.coreDataManager = coreDataManager
        self.webSocketManager = webSocketManager
    }
    
    func launchMethods() {
        
        if NetworkMonitor.shared.isConnected {
            
            coreDataManager.getData()
            networkManager.getFullCoinCapList(group : DispatchGroups.shared.groupOne)
            networkManager.getTopOfCrypto(group : DispatchGroups.shared.groupOne)
            networkManager.getTopSearch(group : DispatchGroups.shared.groupOne)
            DispatchGroups.shared.groupOne.wait()
            networkManager.getFullListOfCoinGecko(group : DispatchGroups.shared.groupTwo, waitingGroup : DispatchGroups.shared.groupOne)
            networkManager.carouselDataLoad(group : DispatchGroups.shared.groupTwo)
            
            view.setupCollectionView()
            setupDataSource()
            
            if DataSingleton.shared.coinCapDict.count != 0 {
                networkManager.putCoinGeckoData(array: &DataSingleton.shared.results,
                                                group: DispatchGroups.shared.groupTwo,
                                                otherArray: DataSingleton.shared.collectionViewArray)
                networkManager.putCoinGeckoData(array: &DataSingleton.shared.resultsF,
                                                group: DispatchGroups.shared.groupTwo,
                                                otherArray: [])
                DispatchGroups.shared.groupTwo.wait()
                networkManager.putCoinGeckoData(array: &DataSingleton.shared.collectionViewArray, group: DispatchGroups.shared.groupThree, otherArray: DataSingleton.shared.results)
                
                webSocketManager.webSocket(symbols: DataSingleton.shared.websocketArray)
                webSocketManager.receiveMessage()
                DispatchGroups.shared.groupThree.wait()
                networkManager.setupSections()
                reloadData()
                updateUI(collectionViews: [view.returnCollectionView()])
                recoursiveUpdateUI(collectionViews: [view.returnCollectionView()])

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
            let carousel = SectionOfCrypto(type: "carousel", title: "Top by Market Cap", items: DataSingleton.shared.collectionViewArray)
            let table = SectionOfCrypto(type: "table", title: "Hot by 24H Volume", items: DataSingleton.shared.results)
            self.sections = [carousel,table]
            switch DataSingleton.shared.sections[indexPath.section].type {
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
            let section = DataSingleton.shared.sections[sectionIndex]
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
        DispatchGroups.shared.groupSetupSections.wait()
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionOfCrypto, Crypto>()
        snapshot.appendSections(DataSingleton.shared.sections)
        
        for section in DataSingleton.shared.sections {
            snapshot.appendItems(section.items, toSection: section)
        }
        dataSource?.apply(snapshot)
        
    }
    
    func showChartView(indexPath : IndexPath) {
        guard let crypto = dataSource?.itemIdentifier(for: indexPath) else { return }
        let chartVC = builder.createChartViewModule(crypto: crypto)
        view.navigationController?.pushViewController(chartVC, animated: true)
    }
    
    func updateUI(collectionViews: [UICollectionView]){
        DispatchGroups.shared.groupOne.wait()
        DispatchGroups.shared.groupTwo.wait()
        //        groupThree.wait()
        DispatchQueue.main.async {
            self.view.reloadCollectionView()
//            for i in collectionViews {
//                i.reloadData()
//            }
        }
    }
    func recoursiveUpdateUI(collectionViews: [UICollectionView]){
        updateUI(collectionViews: collectionViews)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.recoursiveUpdateUI(collectionViews: collectionViews)
        }
    }
}
