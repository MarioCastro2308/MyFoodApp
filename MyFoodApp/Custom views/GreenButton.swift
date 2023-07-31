//
//  GreenButton.swift
//  MyFoodApp
//
//  Created by Mario Castro on 26/07/23.
//

import UIKit

class GreenButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupButton()
    }
    
    func setupButton(){
        backgroundColor = #colorLiteral(red: 0.337254902, green: 0.6705882353, blue: 0.1843137255, alpha: 1)
        titleLabel!.textColor = UIColor.white
        titleLabel!.font = UIFont(name: "Cherry Bomb One", size: 20)
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.lineBreakMode = .byClipping
        layer.cornerRadius = 25
        layer.borderWidth = 2
        layer.borderColor = UIColor.black.cgColor
    }
}
