//
//  SideMenuCell.swift
//  MyFoodApp
//
//  Created by Mario Castro on 20/07/23.
//

import UIKit

class SideMenuCell: UITableViewCell {

    class var identifier: String { return String(describing: self) }
        class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }

    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
        override func awakeFromNib() {
            super.awakeFromNib()
            
            // Background
            self.backgroundColor = .clear
            
            // Icon
            self.iconImageView.tintColor = .black
            
            // Title
            self.titleLabel.textColor = .black
        }
    
    
}
