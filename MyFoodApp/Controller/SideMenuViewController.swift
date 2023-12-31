//
//  SideMenuViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 22/06/23.
//

import UIKit

protocol SideMenuViewControllerDelegate {
    func selectedCell(_ row: Int)
}

class SideMenuViewController: UIViewController {
    
    @IBOutlet weak var sideMenuTableView: UITableView!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    
    let userDataManager = UserDataManager()
    var delegate: SideMenuViewControllerDelegate?
    var defaultHighlightedCell: Int = 0
    var userData : UserDataModel?
    
    var menu: [SideMenuModel] = [
        SideMenuModel(icon: UIImage(systemName: "house.fill")!, title: "Home"),
        SideMenuModel(icon: UIImage(systemName: "person.fill")!, title: "Edit Profile"),
        SideMenuModel(icon: UIImage(systemName: "calendar")!, title: "Today Meals"),
        SideMenuModel(icon: UIImage(systemName: "calendar")!, title: "Weak Plan"),
        SideMenuModel(icon: UIImage(systemName: "xmark")!, title: "Log out"),
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Profile ImageView
        self.profileImageView.layer.cornerRadius = 50
        self.profileImageView.clipsToBounds = true
        
        // TableView
        self.sideMenuTableView.delegate = self
        self.sideMenuTableView.dataSource = self
        self.sideMenuTableView.backgroundColor = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 1, alpha: 1)
        self.sideMenuTableView.separatorStyle = .none
        
        // Set Highlighted Cell
        DispatchQueue.main.async {
            let defaultRow = IndexPath(row: self.defaultHighlightedCell, section: 0)
            self.sideMenuTableView.selectRow(at: defaultRow, animated: false, scrollPosition: .none)
        }
        
        // Footer
        self.footerLabel.textColor = UIColor.white
        self.footerLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        self.footerLabel.text = "Developed by Mario Castro"
        
        // Register TableView Cell
        self.sideMenuTableView.register(SideMenuCell.nib, forCellReuseIdentifier: SideMenuCell.identifier)
        
        // Update TableView with the data
        self.sideMenuTableView.reloadData()
        
        getUserData()
    }
    
    // Get the information of the current user
    func getUserData(){
        userDataManager.getUserData { data in
            if data != nil {
                self.userData = data
                self.updateScreenData()
            }
        }
    }
    
    func updateScreenData(){ userDataManager.getUserProfilePhoto(for: userData!.imagePath!) { profileImage in
        self.profileImageView.image = profileImage
    }
        lblUserName.text = userData?.userName
    }
    
}

// MARK: - UITableViewDelegate

extension SideMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

// MARK: - UITableViewDataSource

extension SideMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuCell.identifier, for: indexPath) as? SideMenuCell else { fatalError("xib doesn't exist") }
        
        cell.iconImageView.image = self.menu[indexPath.row].icon
        cell.titleLabel.text = self.menu[indexPath.row].title
        
        // Highlighted color
        let myCustomSelectionColorView = UIView()
        myCustomSelectionColorView.backgroundColor = #colorLiteral(red: 0.1607843137, green: 0.5019607843, blue: 0.7254901961, alpha: 1)
        cell.selectedBackgroundView = myCustomSelectionColorView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.delegate?.selectedCell(indexPath.row)
        
        if indexPath.row == 1 {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
