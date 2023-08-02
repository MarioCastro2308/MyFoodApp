//
//  WeakPlanViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 25/07/23.
//

import UIKit

class WeakPlanViewController: UIViewController {
    
    
    @IBOutlet weak var txtFieldDay: UITextField!
    @IBOutlet weak var mealsTableView: UITableView!
    @IBOutlet weak var btnSideMenu: UIBarButtonItem!
    
    var mealsDataManager = MealsDataManager()
    let daysArray = ["lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo"]
    
    var mealsDataArray = [MealDataModel]() // Used to show data in tableview
    
    let dayPickerView = UIPickerView()
    var selectedDay : String = "lunes"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegates
        mealsTableView.dataSource = self
        dayPickerView.dataSource = self
        dayPickerView.delegate = self
        // TextField Day Picker
        txtFieldDay.inputView = dayPickerView
        txtFieldDay.text = daysArray[0]
        // Side Menu button
        btnSideMenu.target = revealViewController()
        btnSideMenu.action = #selector(revealViewController()?.revealSideMenu)
        // Custom Cells
        mealsTableView.register(UINib(nibName: K.CustomCell.complementCell, bundle: nil), forCellReuseIdentifier: K.CustomCell.complementCell)
        mealsTableView.register(UINib(nibName: K.CustomCell.mealHeaderCell, bundle: nil), forCellReuseIdentifier: K.CustomCell.mealHeaderCell)
        getCurrentUserData()
    }
    
    @IBAction func btnSearchAction(_ sender: UIButton) {
        mealsDataArray = []
        getCurrentUserData()
    }
    
    
    // Get the current user information
    func getCurrentUserData() {
        mealsDataManager.loadMeals(selectedDay: selectedDay) { meals in
            if(!meals.isEmpty){
                getComplements(for: meals)
            } else {
                mealsTableView.reloadData()
            }
        }
    }
    
    func getComplements(for meals : [Meal]){
        for meal in meals {
            mealsDataManager.loadComplements(for: meal, completionHandler: { complements in
                
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en")
                formatter.dateFormat = "hh:mm a"
                let stringHour = formatter.string(from: meal.hour!)
                
                mealsDataArray.append(MealDataModel(mealTitle: meal.title!, mealHour: stringHour, mealComplements: complements))
            })
        }
        
        mealsTableView.reloadData()
    }
    
    // We send the selected day to the view TodayMealsViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.toMeals {
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
        if(!mealsDataArray.isEmpty){
            return mealsDataArray.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(!mealsDataArray.isEmpty){
            return mealsDataArray[section].mealComplements.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if(!mealsDataArray.isEmpty){
            // Section Header
            if(indexPath.row == 0) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.mealHeaderCell, for: indexPath) as! MealHeaderCell
                let meal = mealsDataArray[indexPath.section]
                cell.lblTitle.text = meal.mealTitle.uppercased()
                cell.lblHour.text = meal.mealHour
                
                return cell
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.complementCell, for: indexPath) as! ComplementCell
                let complement = mealsDataArray[indexPath.section].mealComplements[indexPath.row - 1]
                cell.lblName.text = complement.name
                cell.lblQuantity.text = "\(complement.quantity) \(complement.measure!)"
                
                return cell
            }
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            var content = cell.defaultContentConfiguration()
            content.text = "No registered meals yet"
            cell.contentConfiguration = content
            
            return cell
        }
    }
}
