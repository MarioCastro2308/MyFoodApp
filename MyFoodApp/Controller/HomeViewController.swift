//
//  HomeViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 22/06/23.
//

import UIKit
import CoreData
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController {

    
    @IBOutlet weak var sideMenuBtn: UIBarButtonItem!
    @IBOutlet weak var caloriesView: UIView!
    @IBOutlet weak var macrosView: UIView!
    
    @IBOutlet weak var lblCaloriesGoal: UILabel!
    @IBOutlet weak var lblCaloriesRemaining: UILabel!
    
    @IBOutlet weak var lblProteins: UILabel!
    @IBOutlet weak var lblCarbs: UILabel!
    @IBOutlet weak var lblFats: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var userDataManager = UserDataManager()
    var mealDataManager = MealsDataManager()
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenuBtn.target = revealViewController()
        sideMenuBtn.action = #selector(revealViewController()?.revealSideMenu)
        
        caloriesView.layer.cornerRadius = 15
        caloriesView.clipsToBounds = true
        
        caloriesView.layer.borderColor = UIColor.black.cgColor
        caloriesView.layer.borderWidth = 1

        
        macrosView.layer.cornerRadius = 15
        macrosView.clipsToBounds = true
        
        macrosView.layer.borderColor = UIColor.black.cgColor
        macrosView.layer.borderWidth = 1
        
        getUserData()
    }
    
    func getUserData(){
        userDataManager.getUserData { data in
            if data != nil {
                let userBMI = self.calculateBMI(with: data!)

                self.mealDataManager.loadMeals(selectedDay: self.getCurrentDay()) { meals in
                    if !meals.isEmpty {
                        let nutrients  = self.getTodayNutrients(for: meals)
                        self.updateScreenData(bmi: userBMI, nutrients: nutrients)
                    } else {
                        self.updateScreenData(bmi: userBMI, nutrients: nil)
                    }
                }
            }
        }
    }
    
    func updateScreenData(bmi : Float, nutrients : [String : Float]?){
        var remain : Float = 0.0
        
        if nutrients != nil {
            let kcal = nutrients!["kcal"]!
            let proteins = nutrients!["proteins"]!
            let carbs = nutrients!["carbs"]!
            let fats = nutrients!["fats"]!
            
            if bmi > kcal {
                remain = bmi - kcal;
            }
            
            lblCaloriesGoal.text = String(format: "%.0f",bmi)
            lblCaloriesGoal.font = lblCaloriesGoal.font.withSize(35)
            
            lblCaloriesRemaining.text = String(format: "%.0f", remain)
            lblCaloriesRemaining.font = lblCaloriesRemaining.font.withSize(35)
            
            lblProteins.text = String(format: "%.0f",proteins)
            lblCarbs.text = String(format: "%.0f", carbs)
            lblFats.text = String(format: "%.0f",fats)
        } else {
            lblCaloriesGoal.text = String(format: "%.0f",bmi)
            lblCaloriesGoal.font = lblCaloriesGoal.font.withSize(35)
            
            lblCaloriesRemaining.text = String(format: "%.0f", remain)
            lblCaloriesRemaining.font = lblCaloriesRemaining.font.withSize(35)
        }
    }
    
    func calculateBMI(with userData : UserDataModel) -> Float {
        
        let weight = userData.userWeight
        let height = userData.userHeight
        let age = userData.userAge
        
        let bmi : Float
        
        if(userData.userGender == "Male"){
            
            let valueWeight = 13.75 * weight
            let valueHeight = 5.003 * height
            let valueAge = 6.75 * Float(age)
            
            bmi = 66.5 + valueWeight  + valueHeight - valueAge

        } else {
            let valueWeight = 9.563 * weight
            let valueHeight = 1.85 * height
            let valueAge = 4.676 * Float(age)
            
            bmi = 665.1 + valueWeight  + valueHeight - valueAge
        }
        
        return bmi
    }
    
    func getTodayNutrients(for todayMeals : [Meal]) -> [String : Float] {
        var dayKcal : Float = 0
        var dayProteins : Float = 0
        var dayCarbs : Float = 0
        var dayFats : Float = 0
        
        for meal in todayMeals {
            dayKcal = dayKcal + meal.kcal
            dayProteins = dayProteins + meal.proteins
            dayCarbs = dayCarbs + meal.carbs
            dayFats = dayFats + meal.fats
        }
        
        return ["kcal" : dayKcal, "proteins" : dayProteins, "carbs" : dayCarbs, "fats" : dayFats]
    }
    
    func getTodayKcalories(for todayMeals : [Meal]) -> Float {
        var sum : Float = 0
        for meal in todayMeals {
            sum = sum + meal.kcal
        }
        
        return sum
    }
    
    func getCurrentDay() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let currentDay = dateFormatter.string(from: date)
        
        return  currentDay
    }
}
