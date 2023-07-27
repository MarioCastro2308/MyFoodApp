//
//  GradientView.swift
//  MyFoodApp
//
//  Created by Mario Castro on 26/07/23.
//

import UIKit

class GradientView: UIView {

    var topColor : UIColor = #colorLiteral(red: 0.337254902, green: 0.6705882353, blue: 0.1843137255, alpha: 1) // #56ab2f
    var bottomColor : UIColor = #colorLiteral(red: 0.6588235294, green: 0.8784313725, blue: 0.3882352941, alpha: 1) // #a8e063
    
    var startPointX : CGFloat = 0
    var startPointY : CGFloat = 0
    
    var endPointX : CGFloat = 1
    var endPointY : CGFloat = 1
    
    override func layoutSubviews() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: startPointX, y: startPointY)
        gradientLayer.endPoint = CGPoint(x: endPointX, y: endPointY)
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    

}
