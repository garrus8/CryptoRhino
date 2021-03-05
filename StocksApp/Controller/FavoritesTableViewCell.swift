//
//  FavoritesTableViewCell.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 02.03.2021.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {
    

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var change: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
