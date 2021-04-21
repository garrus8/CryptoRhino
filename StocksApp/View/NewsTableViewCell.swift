//
//  NewsTableViewCell.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 09.04.2021.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    

    @IBOutlet weak var title: UILabel!
    
    var body = String()
    var url = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
