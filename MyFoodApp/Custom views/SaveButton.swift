//
//  SaveButton.swift
//  MyFoodApp
//
//  Created by Mario Castro on 24/07/23.
//

import UIKit

class SaveButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    func setupButton(){
        setShadow()
        setTitleColor(.white, for: .normal)
        
        backgroundColor      = UIColor(red: 42/255, green: 126/255, blue: 254/255, alpha: 1.0)
        titleLabel?.font     = UIFont(name: "AvenirNext-DemiBold", size: 18)
        layer.cornerRadius   = 25
        layer.borderWidth    = 3.0
        layer.borderColor    = UIColor.darkGray.cgColor
    }
    
    
    private func setShadow() {
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOffset  = CGSize(width: 0.0, height: 6.0)
        layer.shadowRadius  = 8
        layer.shadowOpacity = 0.5
        clipsToBounds       = true
        layer.masksToBounds = false
    }
    
    
    
    
}
