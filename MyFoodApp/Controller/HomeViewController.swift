//
//  HomeViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 22/06/23.
//

import UIKit

class HomeViewController: UIViewController {

    
    @IBOutlet weak var sideMenuBtn: UIBarButtonItem!
    @IBOutlet weak var caloriesView: UIView!
    @IBOutlet weak var macrosView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenuBtn.target = revealViewController()
        sideMenuBtn.action = #selector(revealViewController()?.revealSideMenu)
        
        caloriesView.layer.cornerRadius = 15
        caloriesView.clipsToBounds = true
        
        caloriesView.layer.borderColor = UIColor.black.cgColor
        caloriesView.layer.borderWidth = 1
//        
//        caloriesView.layer.shadowColor = UIColor.black.cgColor
//        caloriesView.layer.shadowOpacity = 0.2
//        caloriesView.layer.shadowOffset = CGSize(width: 4, height: 4)
//        caloriesView.layer.shadowRadius = 5.0
//        caloriesView.layer.masksToBounds = false
        
        
        macrosView.layer.cornerRadius = 15
        macrosView.clipsToBounds = true
        
        macrosView.layer.borderColor = UIColor.black.cgColor
        macrosView.layer.borderWidth = 1
    }
    
}
