//
//  TodayMealsViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 20/07/23.
//

import UIKit
import CoreData
import FirebaseAuth
import FirebaseFirestore

class TodayMealsViewController: UIViewController {
    
    @IBOutlet weak var btnSideMenu: UIBarButtonItem!
    @IBOutlet weak var mealsTableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var mealsDataManager = MealsDataManager()
    var mealsData = [MealDataModel]()
    var selectedDay : String?
//    var selectedMeal : String?
    var selectedMealTitle : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegates
        mealsTableView.dataSource = self
        mealsTableView.delegate = self
        // Side Menu Button
        btnSideMenu.target = revealViewController()
        btnSideMenu.action = #selector(revealViewController()?.revealSideMenu)
        // Register custom cell
        mealsTableView.register(UINib(nibName: "ComplementCell", bundle: nil), forCellReuseIdentifier: "ComplementCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getCurrentUserData()
    }
    
    func getCurrentUserData(){
        mealsData = []
        selectedMealTitle = nil
        
        if(selectedDay == nil) {
            mealsDataManager.loadMeals(for: getCurrentDay()) { meals in
                
                if !meals.isEmpty {
                    getComplements(for: meals)
                } else {
                    mealsTableView.reloadData()
                }
            }
        } else {
            mealsDataManager.loadMeals(for: selectedDay!) { meals in
                
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
    
    // Get the complements for the given list of meals
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMealDetails" {
            let mealVC: MealViewController = segue.destination as! MealViewController
            
            if(selectedDay == nil){
                mealVC.selectedDay = getCurrentDay()
            } else {
                mealVC.selectedDay = selectedDay
            }
            
//            mealVC.selectedMealTitle = selectedMeal
            mealVC.selectedMealTitle = selectedMealTitle
        }
    }
}

//MARK: - UITableViewControllerDelegate Methods

extension TodayMealsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedMealTitle = mealsData[indexPath.section].mealTitle
//        selectedMeal = mealsData[indexPath.section]
        performSegue(withIdentifier: "goToMealDetails", sender: self)
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
