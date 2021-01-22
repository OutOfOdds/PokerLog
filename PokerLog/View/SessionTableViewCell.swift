//
//  SessionTableViewCell.swift
//  WinRateApp
//
//  Created by Mike Mailian on 09.11.2020.
//

import UIKit
import Foundation


class SessionTableViewCell: UITableViewCell {
    
    @IBOutlet var viewLabel: UIView!
    @IBOutlet var pokerTypeLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var moneyInLabel: UILabel!
    @IBOutlet var moneyOutLabel: UILabel!
    @IBOutlet var timePlayedLabel: UILabel!
    @IBOutlet var profitLabel: UILabel!
    @IBOutlet var percentLabel: UILabel!
    @IBOutlet var commentTextView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Adding cornet radius to View inside Cell
        viewLabel.layer.cornerRadius = 20
        viewLabel.layer.masksToBounds = true
        
        commentTextView.contentInset = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        commentTextView.layer.borderWidth = 1
        commentTextView.layer.cornerRadius = 20
        commentTextView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
}
