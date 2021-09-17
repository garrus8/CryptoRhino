//
//  CoreDataManager.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 17.09.2021.
//
import CoreData
import UIKit


class CoreDataManager {
    
    var networkManager : NetworkManager!
    
    init(networkManager : NetworkManager) {
        self.networkManager = networkManager
    }
    
    private func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    func getData() {
        // GROUP 1
        
        let context = self.getContext()
        let fetchRequest : NSFetchRequest<Favorites> = Favorites.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            DataSingleton.shared.favorites = try context.fetch(fetchRequest)
            self.setData(group: DispatchGroups.shared.groupOne)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    func setData(group : DispatchGroup) {
        DispatchQueue.global().async(group: group) {
            DataSingleton.shared.resultsF.removeAll()
            DispatchQueue.global().async(flags: .barrier) {
                for i in DataSingleton.shared.favorites {
                    if let symbol = i.symbol{
                        let crypto = Crypto(symbolOfCrypto: symbol, nameOfCrypto: i.name!, descriptionOfCrypto: i.descrtiption!, image: UIImage(named: "pngwing.com")!, percentages: Persentages())
                        //                    DispatchQueue.global().async(flags: .barrier) {
                        print("self.resultsF",DataSingleton.shared.resultsF.count)
                        DataSingleton.shared.symbolsF.append(i.symbol!)
                        DataSingleton.shared.resultsF.append(crypto)
                        DataSingleton.shared.websocketArray.append(symbol)
                        DataSingleton.shared.dict1[symbol] = 0
                    }
                }
            }
        }
    }
    
    func addData(object : Favorites) {
        
        if let symbol = object.symbol {
            let crypto = Crypto(symbolOfCrypto: symbol, nameOfCrypto: object.name!, descriptionOfCrypto: object.descrtiption!, image: UIImage(named: "pngwing.com")!, percentages: Persentages())
            
            DispatchQueue.global().async(flags: .barrier) {
                DataSingleton.shared.symbolsF.insert(object.symbol!, at: 0)
                DataSingleton.shared.resultsF.insert(crypto, at: 0)
                DataSingleton.shared.websocketArray.append(symbol)
                DataSingleton.shared.dict1[symbol] = 0
                var sub = [DataSingleton.shared.resultsF.first!]
                //                        self.putCoinGeckoData(array: &self.resultsF, group: self.groupTwo)
                self.networkManager.putCoinGeckoData(array: &sub, group: DispatchGroups.shared.groupTwo, otherArray: [])
                DataSingleton.shared.resultsF[0] = sub.first!
            }
        }
    }
}
