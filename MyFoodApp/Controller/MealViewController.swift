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
    var complementsArray = [Complement]()
    let timeDatePicker = UIDatePicker()
    
    var selectedDay : String?
    var selectedMealTitle : String?
    var selectedMeal : Meal?
    //    var selectedMeal : MealDataModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegates
        complementsTableView.delegate = self
        complementsTableView.dataSource = self
        complementsTableView.register(UINib(nibName: "ComplementCell", bundle: nil), forCellReuseIdentifier: "ComplementCell")
        createDatePicker()
        
        if(selectedMealTitle != nil ) {
            getMealData()
        }
    }
    
    func getMealData(){
        mealsDataManager.loadMeal(selectedDay: selectedDay!, mealTitle: selectedMealTitle!) { meal in
            selectedMeal = meal
            getComplements(for: meal)
        }
    }
    
    func getComplements(for meal : Meal){
        mealsDataManager.loadComplements(for: meal) { complements in
            
            updateFormData(mealData: meal, complements: complements)
        }
    }
    
    
    
    func updateFormData(mealData : Meal , complements : [Complement]){
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "HH:mm:ss"
        let hour = formatter.string(from: mealData.hour!)
        
        txtFieldTitle.text = mealData.title
        txtFieldHour.text = hour
        complementsArray = complements
        
        //        relateComplements(parentMeal: selectedMeal!)
        complementsTableView.reloadData()
    }
    
    
    func createToolbar () -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonAction))
        
        toolBar.setItems([doneBtn], animated: true)
        return toolBar
    }
    
    func createDatePicker(){
        timeDatePicker.preferredDatePickerStyle = .wheels
        timeDatePicker.datePickerMode = .time
        txtFieldHour.inputView = timeDatePicker
        txtFieldHour.inputAccessoryView = createToolbar()
    }
    
    @objc func doneButtonAction (){
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "HH:mm:ss"
        txtFieldHour.text = formatter.string(from: timeDatePicker.date)
        view.endEditing(true)
    }
    
    @IBAction func btnSaveMeal(_ sender: UIButton) {
        
        if validateFormData() {
            
            if(selectedMeal != nil){
                updateMeal()
            } else {
                saveNewMeal()
            }
            
            
        } else {
            showMessageAlert(title: "Error", message: "Invalid data")
        }
    }
    
    func validateFormData() -> Bool {
        
        if let mealTitle = txtFieldTitle.text, !mealTitle.isEmpty,
           let mealHour = txtFieldHour.text, !mealHour.isEmpty,
           !complementsArray.isEmpty{
            
            return true
        } else {
            return false
        }
    }
    
    func updateMeal(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let mealHourDate = dateFormatter.date(from: txtFieldHour.text!)
        
        selectedMeal!.title = txtFieldTitle.text!
        selectedMeal?.hour = mealHourDate
        
        let nutrients = getTotalNutrients()
        
        selectedMeal!.kcal = nutrients["kcal"]!
        selectedMeal!.proteins = nutrients["proteins"]!
        selectedMeal!.carbs = nutrients["carbs"]!
        selectedMeal!.fats = nutrients["fats"]!
        
        relateComplements(parentMeal: selectedMeal!)
    }
    
    func saveNewMeal(){
        
        if let currentUserEmail = Auth.auth().currentUser?.email {
    
            let newMeal = Meal(context: context)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            let mealHourDate = dateFormatter.date(from: txtFieldHour.text!)
            
            newMeal.title = txtFieldTitle.text!
            newMeal.hour = mealHourDate
            newMeal.day = selectedDay!
            newMeal.userEmail = currentUserEmail
            
            let nutrients = getTotalNutrients()
            
            newMeal.kcal = nutrients["kcal"]!
            newMeal.proteins = nutrients["proteins"]!
            newMeal.carbs = nutrients["carbs"]!
            newMeal.fats = nutrients["fats"]!
            
            relateComplements(parentMeal: newMeal)
            
        }
    }
    
    
    
    //    @IBAction func btnSaveMeal(_ sender: UIButton) {
    //
    //        if let mealTitle = txtFieldTitle.text, !mealTitle.isEmpty,
    //           let mealHour = txtFieldHour.text, !mealHour.isEmpty,
    //           let currentUserEmail = Auth.auth().currentUser?.email,
    //           !complementsArray.isEmpty{
    //
    //            let newMeal = Meal(context: context)
    //
    //            let dateFormatter = DateFormatter()
    //            dateFormatter.dateFormat = "HH:mm:ss"
    //            let mealHourDate = dateFormatter.date(from: mealHour)
    //
    //            newMeal.title = mealTitle
    //            newMeal.hour = mealHourDate
    //            newMeal.day = selectedDay!
    //            newMeal.userEmail = currentUserEmail
    //
    //            let nutrients = getTotalNutrients()
    //
    //            newMeal.kcal = nutrients["kcal"]!
    //            newMeal.proteins = nutrients["proteins"]!
    //            newMeal.carbs = nutrients["carbs"]!
    //            newMeal.fats = nutrients["fats"]!
    //
    //            relateComplements(parentMeal: newMeal)
    //        } else {
    //            showMessageAlert(title: "Error", message: "Invalid data")
    //        }
    //    }
    
    func relateComplements(parentMeal : Meal){
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
}

//MARK: - UITableViewDelegate Methods
extension MealViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        context.delete(complementsArray[indexPath.row])
        
        complementsArray.remove(at: indexPath.row)
        
        saveComplements()
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
    
    func saveComplements(){
        do{
            try context.save()
            complementsTableView.reloadData()
        } catch{
            print("Error Saving the context : \(error)")
        }
    }
    
}

