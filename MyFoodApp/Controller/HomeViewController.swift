//
//  HomeViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 22/06/23.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var backSideMenuView: UIView!
    
    @IBOutlet weak var leadingConstraintSideMenu: NSLayoutConstraint!
    
    var sideMenuViewController : SideMenuViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        backSideMenuView.isHidden = true
        btnMenu.tintColor = .white
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSlideMenu" {
            if let controller = segue.destination as? SideMenuViewController{
                self.sideMenuViewController = controller
                self.sideMenuViewController?.delegate = self
            }
        }
    }
    
    
    @IBAction func tapBackSideMenu(_ sender: UITapGestureRecognizer) {
        hideSideMenu()
    }
    
    @IBAction func btnMenuAction(_ sender: UIBarButtonItem) {
//        backSideMenuView.isHidden = false
//        leadingConstraintSideMenu.constant = 0
//        print("hello my friend")
        UIView.animate(withDuration: 0.1) {
            self.leadingConstraintSideMenu.constant = 10
            self.view.layoutIfNeeded()
        } completion: { (status) in
            self.backSideMenuView.alpha = 0.75
            self.backSideMenuView.isHidden = false
            UIView.animate(withDuration: 0.1) {
                self.leadingConstraintSideMenu.constant = 0
                self.view.layoutIfNeeded()
            } completion: { (status) in
                self.isHamburgerMenuShown = true
            }
        }
       self.backSideMenuView.isHidden = false
    }
    
    private func hideSideMenu(){
        UIView.animate(withDuration: 0.1) {
            self.leadingConstraintSideMenu.constant = 10
            self.view.layoutIfNeeded()
        } completion: { (status) in
            self.backSideMenuView.alpha = 0.0
            UIView.animate(withDuration: 0.1) {
                self.leadingConstraintSideMenu.constant = -280
                self.view.layoutIfNeeded()
            } completion: { (status) in
                self.backSideMenuView.isHidden = true
                self.isHamburgerMenuShown = false
            }
        }
    }
    
    private var isHamburgerMenuShown:Bool = false
    private var beginPoint:CGFloat = 0.0
    private var difference:CGFloat = 0.0
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (isHamburgerMenuShown)
        {
             if let touch = touches.first
            {
                let location = touch.location(in: backSideMenuView)
                beginPoint = location.x
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (isHamburgerMenuShown)
        {
            if let touch = touches.first
            {
                let location = touch.location(in: backSideMenuView)
                
                let differenceFromBeginPoint = beginPoint - location.x
                
                if (differenceFromBeginPoint>0 || differenceFromBeginPoint<280)
                {
                    difference = differenceFromBeginPoint
                    self.leadingConstraintSideMenu.constant = -differenceFromBeginPoint
                    self.backSideMenuView.alpha = 0.75-(0.75*differenceFromBeginPoint/280)
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (isHamburgerMenuShown)
        {
            if (difference>140)
            {
                UIView.animate(withDuration: 0.1) {
                    self.leadingConstraintSideMenu.constant = -290
                } completion: { (status) in
                    self.backSideMenuView.alpha = 0.0
                    self.isHamburgerMenuShown = false
                    self.backSideMenuView.isHidden = true
                }
            }
            else{
                UIView.animate(withDuration: 0.1) {
                    self.leadingConstraintSideMenu.constant = -10
                } completion: { (status) in
                    self.backSideMenuView.alpha = 0.75
                    self.isHamburgerMenuShown = true
                    self.backSideMenuView.isHidden = false
                }
            }
        }
    }
}

 
//MARK: - SideMenuControllerDelegate Methods
extension HomeViewController : SideMenuViewControllerDelegate {
    
    func hideMenu() {
        self.hideSideMenu()
    }
    
}
