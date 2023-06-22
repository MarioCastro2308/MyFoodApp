//
//  HomeViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 15/06/23.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    //@IBOutlet weak var tbView: UITableView!
    @IBOutlet weak var txtFieldSearch: UITextField!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblKcal: UILabel!
    @IBOutlet weak var lblProteins: UILabel!
    @IBOutlet weak var lblCarbs: UILabel!
    @IBOutlet weak var lblFats: UILabel!
    
    var nutritionDataManager : NutritionDataManager = NutritionDataManager()
    var arrayTest : [String] = ["Hello1", "Hello2", "Hello3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        nutritionDataManager.delegate = self
        txtFieldSearch.delegate = self
//        tbView.dataSource = self
//        tbView.register(UINib(nibName: "ComplementCell", bundle: nil), forCellReuseIdentifier: "ComplementCell")
    }
    
    @IBAction func btnLogoutAction(_ sender: UIBarButtonItem) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    
    
}

//MARK: - UITextFieldDelegate Methods
extension HomeViewController : UITextFieldDelegate {
    
    @IBAction func btnSearch(_ sender: UIButton) {
        txtFieldSearch.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtFieldSearch.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return (txtFieldSearch.text != "") ? true : false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let complement : String = txtFieldSearch.text {
            nutritionDataManager.fetchNutritionData(for: complement)
        }
        
        txtFieldSearch.placeholder = "Search"
        txtFieldSearch.text = ""
    }
}

//MARK: - UITableViewDataSource Methods

//extension HomeViewController : UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return arrayTest.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ComplementCell", for: indexPath) as! ComplementCell
//        cell.lblTitle.text = arrayTest[indexPath.row]
//        return cell
//    }
//}

//MARK: - NutritionManagerDelegate Methods
extension HomeViewController : NutritionDataManagerDelegate {
    func didUpdateComplementData(_ nutritionDataManager: NutritionDataManager, complementData: NutritionModel) {
        DispatchQueue.main.async {
            self.lblTitle.text = "\(complementData.foodMatch) ( \(complementData.quantity) \(complementData.measure) )"
            self.lblKcal.text = "KCalorias  = \(complementData.kcal)"
            self.lblProteins.text = "Proteins = \(complementData.proteins)"
            self.lblCarbs.text = "Carbohidrats: \(complementData.carbs)"
            self.lblFats.text = "Fats = \(complementData.fats)"
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    
}
