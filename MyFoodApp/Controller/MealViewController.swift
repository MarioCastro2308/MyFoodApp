//
//  MealViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 21/07/23.
//

import UIKit
import CoreData
import FirebaseAuth

class MealViewController: UIViewController {
    
    
    @IBOutlet weak var txtFieldTitle: UITextField!
    @IBOutlet weak var txtFieldHour: UITextField!
    @IBOutlet weak var complementsTableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let mealsDataManager = MealsDataManager()
    
    var complementsArray = [Complement]() // Used to show data in tableview
    var complementsBackupArray = [Complement]() // Used to store a complements backup
    var complementsToDeleteArray = [Complement]() // Used to store the complements to delete
    
    let timeDatePicker = UIDatePicker()
    
    var selectedDay : String?
    var selectedMealTitle : String?
    var isAnExistingMeal : Bool = false
    
    var targetMeal : Meal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegates
        complementsTableView.delegate = self
        complementsTableView.dataSource = self
        complementsTableView.register(UINib(nibName: "ComplementCell", bundle: nil), forCellReuseIdentifier: "ComplementCell")
        createDatePicker()
        
        // If a meal has been selected
        if(selectedMealTitle != nil ) {
            isAnExistingMeal = true
            getMealData()
        }
    }
    
    // We obtain the information of the selected meal
    func getMealData() {
        mealsDataManager.loadMeal(selectedDay: selectedDay!, mealTitle: selectedMealTitle!) { meal in
            targetMeal = meal
            getComplements(for: meal)
        }
    }
    
    // We get the list of complements related to the selected food
    func getComplements(for meal : Meal){
        mealsDataManager.loadComplements(for: meal) { complements in
            updateFormData(mealData: meal, complements: complements)
        }
    }
    
    // Displays the information obtained from the selected food
    func updateFormData(mealData : Meal , complements : [Complement]){
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en")
//        formatter.dateFormat = "HH:mm:ss"
//        let hour = formatter.string(from: mealData.hour!)
//
        txtFieldTitle.text = mealData.title
        txtFieldHour.text = getStringHour(from: mealData.hour!)
        complementsArray = complements
        complementsTableView.reloadData()
    }
    
    // Created a toolbar
    func createToolbar () -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonAction))
        
        toolBar.setItems([doneBtn], animated: true)
        return toolBar
    }
    
    // Created a datePicker
    func createDatePicker(){
        timeDatePicker.preferredDatePickerStyle = .wheels
        timeDatePicker.datePickerMode = .time
        txtFieldHour.inputView = timeDatePicker
        txtFieldHour.inputAccessoryView = createToolbar()
    }
    
    @objc func doneButtonAction (){
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en")
//        formatter.dateFormat = "HH:mm:ss"
//        txtFieldHour.text = formatter.string(from: timeDatePicker.date)
        txtFieldHour.text = getStringHour(from: timeDatePicker.date)
        view.endEditing(true)
    }
    
    // If the information in the form is valid, update or save the information in the context
    @IBAction func btnSaveMeal(_ sender: UIButton) {
        
        if validateFormData() {
            
            if(isAnExistingMeal){
                updateMeal()
            } else {
                saveNewMeal()
            }
        } else {
            showMessageAlert(title: "Error", message: "Error saving meal data")
        }
    }
    
    // Validates the information on the form
    func validateFormData() -> Bool {
        
        if let mealTitle = txtFieldTitle.text, !mealTitle.isEmpty,
           let mealHour = txtFieldHour.text, !mealHour.isEmpty,
           !complementsArray.isEmpty{
            
            return true
        } else {
            return false
        }
    }
    
    // Update the information of the selected meal
    func updateMeal(){
        
        targetMeal!.title = txtFieldTitle.text!
        targetMeal?.hour = getDateHour(from: txtFieldHour.text!)
        
        let nutrients = getTotalNutrients()
        targetMeal!.kcal = nutrients["kcal"]!
        targetMeal!.proteins = nutrients["proteins"]!
        targetMeal!.carbs = nutrients["carbs"]!
        targetMeal!.fats = nutrients["fats"]!
        
        deleteSelectedComplements()
        relateComplements(with: targetMeal!)
    }
    
    // Removes the complements selected to be removed
    func deleteSelectedComplements(){
        if !complementsToDeleteArray.isEmpty {
            for complement in complementsToDeleteArray {
                context.delete(complement)
            }
        }
    }
    
    // Save the information of the new Meal
    func saveNewMeal(){
        
        if let currentUserEmail = Auth.auth().currentUser?.email {
    
            let newMeal = Meal(context: context)
            newMeal.title = txtFieldTitle.text!
            newMeal.hour = getDateHour(from: txtFieldHour.text!)
            newMeal.day = selectedDay!
            newMeal.userEmail = currentUserEmail
            
            let nutrients = getTotalNutrients()
            newMeal.kcal = nutrients["kcal"]!
            newMeal.proteins = nutrients["proteins"]!
            newMeal.carbs = nutrients["carbs"]!
            newMeal.fats = nutrients["fats"]!
            
            relateComplements(with: newMeal)
            
        }
    }
    
    
    @IBAction func btnDeleteMealAction(_ sender: UIButton) {
        
        if(isAnExistingMeal){
            context.delete(targetMeal!)
            if(!complementsBackupArray.isEmpty){
                for complement in complementsBackupArray {
                    context.delete(complement)
                }
            }
            saveMeal()
        } else {
            txtFieldTitle.text = ""
            txtFieldHour.text = ""
            complementsArray = []
            complementsTableView.reloadData()
        }
    }
    
    // Relate each complement with the selected food
    func relateComplements(with parentMeal : Meal){
        for complement in complementsArray {
            complement.parentMeal = parentMeal
        }
        saveMeal()
    }
    
    func getTotalNutrients() -> [String : Float] {
        var kcal : Float = 0
        var proteins : Float = 0
        var carbs : Float = 0
        var fats : Float = 0
        
        for complement in complementsArray {
            kcal = kcal + complement.kcal
            proteins = proteins + complement.proteins
            carbs = carbs + complement.carbs
            fats = fats + complement.fats
        }
        
        return ["kcal" : kcal, "proteins" : proteins, "carbs" : carbs, "fats" : fats]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToComplements" {
            let complementsVC: ComplementsViewController = segue.destination as! ComplementsViewController
            complementsVC.delegate = self
            complementsVC.selectedComplements = complementsArray
        }
    }
    
    func showMessageAlert(title : String, message : String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    // Returns the hour in the given format (String)
    func getStringHour(from dateHour : Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: dateHour)
    }
    
    // Returns the hour in the given format (Date)
    func getDateHour(from txtHour : String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.date(from: txtHour)!
    }
}

//MARK: - UITableViewDelegate Methods
extension MealViewController : UITableViewDelegate {
    
    // When a cell is selected it is removed from the complementsArray but not from the context
    // In addition, the selected cell is added to the complementsToDeleteArray for future deletion.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(!complementsArray.isEmpty) {
            complementsToDeleteArray.append(complementsArray[indexPath.row])
            complementsArray.remove(at: indexPath.row)
            complementsTableView.reloadData()
        }
    }
}

//MARK: - UITableViewDataSource Methods
extension MealViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!complementsArray.isEmpty) {
            return complementsArray.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComplementCell", for: indexPath) as! ComplementCell
        
        if(!complementsArray.isEmpty){
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
    
    func sendDataToMealViewController(complementsList: [Complement]) {
        print("SendData")
        complementsArray = complementsList
        complementsBackupArray = complementsList
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
    
}

