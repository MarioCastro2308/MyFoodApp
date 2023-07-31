//
//  ComplementsViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 24/07/23.
//

import UIKit
import CoreData

protocol ComplementsViewControllerDelegate {
    
    func sendDataToMealViewController(complementsList  : [Complement])
}

class ComplementsViewController: UIViewController {
    
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var txtFieldSearch: UITextField!
    @IBOutlet weak var btnAddComplement: UIButton!
    
    @IBOutlet weak var lblComplementName: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var lblProteins: UILabel!
    @IBOutlet weak var lblCarbs: UILabel!
    @IBOutlet weak var lblFats: UILabel!
    
    var nutritionDataManager : NutritionDataManager = NutritionDataManager()
    var delegate : ComplementsViewControllerDelegate? = nil
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedComplements = [Complement]()
    var selectedComplementData : NutritionModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        nutritionDataManager.delegate = self
        txtFieldSearch.delegate = self

        // Result View
        resultView.layer.cornerRadius = 15
        resultView.clipsToBounds = true
        resultView.layer.borderColor = UIColor.black.cgColor
        resultView.layer.borderWidth = 1
        resultView.isHidden = true
        btnAddComplement.isHidden = true
        
    }
    
    // This method is called when the user pressed the search button
    @IBAction func btnSearchAction(_ sender: UIButton) {
        txtFieldSearch.endEditing(true)
    }
    
    @IBAction func btnAddComponentAction(_ sender: UIButton) {
        let newComplement = Complement(context: context)
        
        if(selectedComplementData==nil){
            return
        } else {
            newComplement.name = selectedComplementData?.foodMatch
            newComplement.quantity = Int64(selectedComplementData!.quantity)
            newComplement.measure = selectedComplementData?.measure
            newComplement.kcal = selectedComplementData!.kcal
            newComplement.proteins = selectedComplementData!.proteins
            newComplement.carbs = selectedComplementData!.carbs
            newComplement.fats = selectedComplementData!.fats
           
        }
        
        selectedComplements.append(newComplement)
        resultView.isHidden = true
        btnAddComplement.isHidden = true
        
        showMessageAlert(title: "Success!", message: "Complement added successfuly!")
        
    }
    
    func showMessageAlert(title : String, message : String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    @IBAction func btnSaveComponentsAction(_ sender: UIButton) {
        
        if(delegate != nil && selectedComplementData != nil){
            delegate?.sendDataToMealViewController(complementsList: selectedComplements)
            self.navigationController?.popViewController(animated: true)
        } else {
            showMessageAlert(title: "Error", message: "you haven't added any complement yet")
        }
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
    }
}

//MARK: - NutritionManagerDelegate Methods
extension ComplementsViewController : NutritionDataManagerDelegate{
    
    func didUpdateComplementData(_ nutritionDataManager: NutritionDataManager, complementData: NutritionModel) {
        DispatchQueue.main.async {
            self.lblComplementName.text = "\(complementData.foodMatch)"
            self.lblQuantity.text = "\(complementData.quantity) \(complementData.measure)"
            self.lblProteins.text = String(format: "%.2f", complementData.proteins)
            self.lblCarbs.text = String(format: "%.2f",complementData.carbs)
            self.lblFats.text = String(format: "%.2f",complementData.fats)
            self.selectedComplementData = complementData
            self.resultView.isHidden = false
            self.btnAddComplement.isHidden = false
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
