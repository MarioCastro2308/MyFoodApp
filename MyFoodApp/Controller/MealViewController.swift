//
//  MealViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 21/07/23.
//

import UIKit
import CoreData

class MealViewController: UIViewController {
    
    
    @IBOutlet weak var txtFieldTitle: UITextField!
    @IBOutlet weak var txtFieldHour: UITextField!
    @IBOutlet weak var complementsTableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var complementsArray = [Complements]()
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegates
        complementsTableView.delegate = self
        complementsTableView.dataSource = self
        complementsTableView.register(UINib(nibName: "ComplementCell", bundle: nil), forCellReuseIdentifier: "ComplementCell")
        createDatePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func createToolbar () -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonAction))
        
        toolBar.setItems([doneBtn], animated: true)
        return toolBar
    }
    
    func createDatePicker(){
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .time
        txtFieldHour.inputView = datePicker
        txtFieldHour.inputAccessoryView = createToolbar()
    }
    
    @objc func doneButtonAction (){
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_gb")
        formatter.dateFormat = "HH:mm:ss"
        txtFieldHour.text = formatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    
    @IBAction func btnSaveMeal(_ sender: UIButton) {
       
        if (txtFieldTitle.text?.count != 0 && txtFieldHour.text?.count != 0 && complementsArray.count > 0){
            
            let newMeal = Meals(context: context)
            newMeal.title = txtFieldTitle.text
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            let mealHour = dateFormatter.date(from: txtFieldHour.text!)
            
            newMeal.hour = mealHour
            relateComplements(parentMeal: newMeal)
        } else {
            print("Meal has not been registered")
        }
    }
    
    func relateComplements(parentMeal : Meals){
        for complement in complementsArray {
            complement.parentMeal = parentMeal
        }
        
        saveMeal()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToComplements" {
            let complementsVC: ComplementsViewController = segue.destination as! ComplementsViewController
            complementsVC.delegate = self
        }
    }
}

//MARK: - UITableViewDelegate Methods
extension MealViewController : UITableViewDelegate {
    
}

//MARK: - UITableViewDataSource Methods
extension MealViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if complementsArray.count > 0 {
            return complementsArray.count
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComplementCell", for: indexPath) as! ComplementCell
        
        if(complementsArray.count > 0){
            let complement = complementsArray[indexPath.row]
            cell.lblName.text = complement.name
            cell.lblQuantity.text = "\(complement.quantity) \(complement.measure!)"
        } else {
            cell.lblName.text = "No complements added yet"
            cell.lblQuantity.text = ""
        }
        
        return cell
    }
}

//MARK: - ComplementsViewControllerDelegate Methods
extension MealViewController : ComplementsViewControllerDelegate {
    
    func sendDataToMealViewController(complementsList: [Complements]) {
        complementsArray = complementsList
        complementsTableView.reloadData()
    }
    
    
}

//MARK: - DataManipulation Methods
extension MealViewController {
    
    func saveMeal(){
        do{
            try context.save()
        } catch{
            print("Error Saving the context : \(error)")
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
//    func loadComplements(){
//        let request : NSFetchRequest<Complements> = Complements.fetchRequest()
//
//        do{
//            complementsArray = try context.fetch(request)
//        } catch{
//            print(error)
//        }
//
//        complementsTableView.reloadData()
//    }
    
    
}

