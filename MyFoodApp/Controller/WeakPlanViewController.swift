//
//  WeakPlanViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 25/07/23.
//

import UIKit
import CoreData
import FirebaseAuth
import FirebaseFirestore

class WeakPlanViewController: UIViewController {
    
    
    @IBOutlet weak var txtFieldDay: UITextField!
    @IBOutlet weak var mealsTableView: UITableView!
    @IBOutlet weak var btnSideMenu: UIBarButtonItem!
    
    let daysArray = ["lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo"]
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var mealsArray = [Meal]()
    var complementsArray = [Complement]()
    var mealsData = [MealDataModel]()
    
    var mealsDataManager = MealsDataManager()
    
    let dayPickerView = UIPickerView()
    var selectedDay : String = "lunes"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegates
        mealsTableView.dataSource = self
        
        dayPickerView.dataSource = self
        dayPickerView.delegate = self
        
        txtFieldDay.inputView = dayPickerView
        txtFieldDay.text = daysArray[0]
        
        // Side Menu button
        btnSideMenu.target = revealViewController()
        btnSideMenu.action = #selector(revealViewController()?.revealSideMenu)
        // Tableview Cell
        mealsTableView.register(UINib(nibName: "ComplementCell", bundle: nil), forCellReuseIdentifier: "ComplementCell")
        
        getCurrentUserData()
    }
    
    @IBAction func btnSearchAction(_ sender: UIButton) {
        mealsData = []
        getCurrentUserData()
    }
    
    func getCurrentUserData() {
        mealsDataManager.loadMeals(for: selectedDay) { meals in
            if(!meals.isEmpty){
                getComplements(for: meals)
            } else {
                mealsTableView.reloadData()
            }
        }
        
    }
    
//    func getComplements(for meals : [Meal]){
//        for meal in meals{
//            mealsDataManager.loadComplements(selectedDay: meal.day!, mealTitle: meal.title!) { complements in
//
//                let formatter = DateFormatter()
//                formatter.locale = Locale(identifier: "en")
//                formatter.dateFormat = "hh:mm a"
//                let hour = formatter.string(from: meal.hour!)
//
//                mealsData.append(MealDataModel(mealTitle: meal.title!, mealHour: hour, mealComplements: complements))
//            }
//        }
//        mealsTableView.reloadData()
//    }
    
    func getComplements(for meals : [Meal]){
        for meal in meals {
            mealsDataManager.loadComplements(for: meal, completionHandler: { complements in
                
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en")
                formatter.dateFormat = "hh:mm a"
                let stringHour = formatter.string(from: meal.hour!)
                
                mealsData.append(MealDataModel(mealTitle: meal.title!, mealHour: stringHour, mealComplements: complements))
            })
        }
        
        mealsTableView.reloadData()
    }
    
    // We send the selected day to the view TodayMealsViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditMeal" {
            let mealVC: TodayMealsViewController = segue.destination as! TodayMealsViewController
            mealVC.selectedDay = selectedDay
        }
    }
}

//MARK: - UIPickerViewDelegate and UIPickerViewDatasource Methods
extension WeakPlanViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return daysArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return daysArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDay = daysArray[row]
        txtFieldDay.text = selectedDay
        txtFieldDay.resignFirstResponder()
    }
}

//MARK: - UITableViewDataSource Methods
extension WeakPlanViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(!mealsData.isEmpty){
            return mealsData.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(!mealsData.isEmpty){
            return mealsData[section].mealComplements.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComplementCell", for: indexPath) as! ComplementCell
        
        // si hay alguna comida establecida para el dia de hoy
        if(!mealsData.isEmpty){
            
            // si se trata de a primera celda (section title)
            if(indexPath.row == 0) {
                
                let meal = mealsData[indexPath.section]
                
                cell.lblName.text = meal.mealTitle.uppercased()
                cell.lblQuantity.text = meal.mealHour
                
                cell.contentView.backgroundColor = #colorLiteral(red: 0.2666666667, green: 0.4784313725, blue: 0.2156862745, alpha: 1)
                cell.lblName.textColor = UIColor.white
                cell.lblQuantity.textColor = UIColor.white
                
            } else {
                let complement = mealsData[indexPath.section].mealComplements[indexPath.row - 1]
                
                cell.lblName.text = complement.name
                cell.lblQuantity.text = "\(complement.quantity) \(complement.measure!)"
                
                cell.contentView.backgroundColor = UIColor.white
                cell.lblName.textColor = UIColor.black
                cell.lblQuantity.textColor = UIColor.black
            }
        } else {
            cell.lblName.text = "No meal added yet"
            cell.lblQuantity.text = ""
        }
        
        return cell
        
    }
}
