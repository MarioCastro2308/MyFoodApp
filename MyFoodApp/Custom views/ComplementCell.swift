//
//  ComplementCell.swift
//  MyFoodApp
//
//  Created by Mario Castro on 21/07/23.
//

import UIKit

class ComplementCell: UITableViewCell {

    
    
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
