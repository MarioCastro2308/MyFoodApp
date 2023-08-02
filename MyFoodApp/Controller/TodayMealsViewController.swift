//
//  TodayMealsViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 20/07/23.
//

import UIKit

class TodayMealsViewController: UIViewController {
    
    @IBOutlet weak var btnSideMenu: UIBarButtonItem!
    @IBOutlet weak var mealsTableView: UITableView!
    
    var mealsDataManager = MealsDataManager()
    var mealsData = [MealDataModel]()
    var selectedDay : String?
    var selectedMealTitle : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegates
        mealsTableView.dataSource = self
        mealsTableView.delegate = self
        // Side Menu Button
        btnSideMenu.target = revealViewController()
        btnSideMenu.action = #selector(revealViewController()?.revealSideMenu)
        // Custom cells
        mealsTableView.register(UINib(nibName: K.CustomCell.complementCell, bundle: nil), forCellReuseIdentifier: K.CustomCell.complementCell)
        mealsTableView.register(UINib(nibName: K.CustomCell.mealHeaderCell, bundle: nil), forCellReuseIdentifier: K.CustomCell.mealHeaderCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getCurrentUserData()
    }
    
    func getCurrentUserData(){
        mealsData = []
        selectedMealTitle = nil
        
        if(selectedDay == nil) {
            mealsDataManager.loadMeals(selectedDay: getCurrentDay()) { meals in
                
                if !meals.isEmpty {
                    getComplements(for: meals)
                } else {
                    mealsTableView.reloadData()
                }
            }
        } else {
            self.title = selectedDay!.uppercased()
            mealsDataManager.loadMeals(selectedDay: selectedDay!) { meals in
                
                if !meals.isEmpty {
                    getComplements(for: meals)
                } else {
                    mealsTableView.reloadData()
                }
            }
        }
    }
    
    // Gets the name of the current day
    func getCurrentDay() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let currentDay = dateFormatter.string(from: date)
        return currentDay
    }
    
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.toMealDetails {
            let mealVC: MealViewController = segue.destination as! MealViewController
            
            if(selectedDay == nil){
                mealVC.selectedDay = getCurrentDay()
            } else {
                mealVC.selectedDay = selectedDay
            }
            
            mealVC.selectedMealTitle = selectedMealTitle
        }
    }
}

//MARK: - UITableViewControllerDelegate Methods

extension TodayMealsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(!mealsData.isEmpty) {
            selectedMealTitle = mealsData[indexPath.section].mealTitle

            performSegue(withIdentifier: K.Segues.toMealDetails, sender: self)
        }
    }
}


//MARK: - UITableViewControllerDataSource Methods

extension TodayMealsViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(!mealsData.isEmpty){
            return mealsData.count // Number of Meals
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(!mealsData.isEmpty){
            // Number of complements per Meal
            return mealsData[section].mealComplements.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(!mealsData.isEmpty){
            // Section Header
            if(indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.mealHeaderCell, for: indexPath) as! MealHeaderCell
                
                let meal = mealsData[indexPath.section]
                
                cell.lblTitle.text = meal.mealTitle.uppercased()
                cell.lblHour.text = meal.mealHour
                
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.complementCell, for: indexPath) as! ComplementCell
                
                let complement = mealsData[indexPath.section].mealComplements[indexPath.row - 1]
                
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
