//
//  SideMenuViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 22/06/23.
//

import UIKit

class SideMenuViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var profilePicture: UIImageView!
    var delegate : SideMenuViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSlideMenu()
        // Do any additional setup after loading the view.
    }
    
    private func setupSlideMenu(){
        self.headerView.layer.cornerRadius = 30
        self.headerView.clipsToBounds = true
        self.profilePicture.layer.cornerRadius = 50
        self.profilePicture.clipsToBounds = true
    }
    
    
    @IBAction func btnTodayMealsAction(_ sender: UIButton) {
        
    }
    
    @IBAction func btnLogoutAction(_ sender: UIButton) {
        self.delegate?.hideMenu()
    }

}

protocol SideMenuViewControllerDelegate {
    func hideMenu()
}
