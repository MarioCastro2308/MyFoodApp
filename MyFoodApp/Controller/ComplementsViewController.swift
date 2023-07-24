//
//  ComplementsViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 24/07/23.
//

import UIKit
import CoreData
class ComplementsViewController: UIViewController {

    
    
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var txtFieldSearch: UITextField!
    
    @IBOutlet weak var lblComplementName: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var lblProteins: UILabel!
    @IBOutlet weak var lblCarbs: UILabel!
    @IBOutlet weak var lblFats: UILabel!
    
    var nutritionDataManager : NutritionDataManager = NutritionDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nutritionDataManager.delegate = self
        txtFieldSearch.delegate = self

        // Result View
        resultView.layer.cornerRadius = 15
        resultView.clipsToBounds = true
        resultView.layer.borderColor = UIColor.black.cgColor
        resultView.layer.borderWidth = 1
        resultView.isHidden = true
    }
    
    
    @IBAction func btnSearchAction(_ sender: UIButton) {
        txtFieldSearch.endEditing(true)
    }
}


//MARK: - UITextFieldDelegate Methods
extension ComplementsViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtFieldSearch.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return (txtFieldSearch.text != "") ? true : false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // si el usuario a escrito algo
        if let complement : String = txtFieldSearch.text {
            nutritionDataManager.fetchNutritionData(for: complement)
        }
        
        txtFieldSearch.placeholder = "Search"
        txtFieldSearch.text = ""
        resultView.isHidden = false
    }
}

//MARK: - NutritionManagerDelegate Methods
extension ComplementsViewController : NutritionDataManagerDelegate{
    func didUpdateComplementData(_ nutritionDataManager: NutritionDataManager, complementData: NutritionModel) {
        DispatchQueue.main.async {
            self.lblComplementName.text = "\(complementData.foodMatch)"
            self.lblQuantity.text = "\(complementData.quantity) \(complementData.measure)"
            self.lblProteins.text = "\(complementData.proteins)"
            self.lblCarbs.text = "\(complementData.carbs)"
            self.lblFats.text = "\(complementData.fats)"
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    
}
