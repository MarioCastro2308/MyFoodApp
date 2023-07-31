//
//  BlueButton.swift
//  MyFoodApp
//
//  Created by Mario Castro on 28/07/23.
//

import UIKit

class BlueButton: UIButton {
    
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
        backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.5764705882, blue: 0.6901960784, alpha: 1)
//        self.tintColor = UIColor.brown
        titleLabel!.textColor = UIColor.white
        titleLabel!.font = UIFont(name: "Cherry Bomb One", size: 20)
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }

}
