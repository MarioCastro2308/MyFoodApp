//
//  MealHeaderCell.swift
//  MyFoodApp
//
//  Created by Mario Castro on 31/07/23.
//

import UIKit

class MealHeaderCell: UITableViewCell {
    
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblHour: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentView.backgroundColor = #colorLiteral(red: 0.2666666667, green: 0.4784313725, blue: 0.2156862745, alpha: 1)
        lblTitle.textColor = UIColor.white
        lblHour.textColor = UIColor.white
        lblTitle.font = UIFont(name: "DM Sans", size: 20)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
