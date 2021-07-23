//
//  Extensions.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 16.07.2021.
//

import UIKit

extension UIButton {
    convenience init(setTitle : String) {
        self.init()
        self.setTitle(setTitle,
                        for: .normal)
        self.setTitleColor(.systemBlue,
                             for: .normal)
        self.sizeToFit()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .red
        
    }
}
extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String { html2AttributedString?.string ?? "" }
}
extension StringProtocol {
    var html2AttributedString: NSAttributedString? {
        Data(utf8).html2AttributedString
    }
    var html2String: String {
        html2AttributedString?.string ?? ""
    }
}
