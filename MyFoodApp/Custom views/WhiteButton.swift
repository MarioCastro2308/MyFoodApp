//
//  WhiteButton.swift
//  MyFoodApp
//
//  Created by Mario Castro on 26/07/23.
//

import UIKit

class WhiteButton: UIButton {

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
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//        self.tintColor = UIColor.brown
        titleLabel!.textColor = UIColor.black
        titleLabel!.font = UIFont(name: "Cherry Bomb One", size: 20)
        titleLabel?.lineBreakMode = .byClipping
        layer.cornerRadius = 25
        layer.borderWidth = 2
        layer.borderColor = UIColor.black.cgColor
    }

}
