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
    
//    var mealsArray = [Meal]()
    var currentUserData : UserDataModel?
    
    var userDataManager = UserDataManager()
    
//    var userBMI : Float?
//    var todayKcal : Float?
    
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
        
//        checkUserRequirements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
        userDataManager.getUserData { data in
            if let userData = data {
                let userBMI = self.calculateBMI(with: userData)
                let nutrients = self.getTodayNutrients(for: self.loadMeals())
                self.showDataOnScreen(bmi: userBMI, nutrients: nutrients)
            } else {
                let nutrients = self.getTodayNutrients(for: self.loadMeals())
                self.showDataOnScreen(bmi: nil, nutrients: nutrients)
            }
        }
    }
    
    func showDataOnScreen(bmi : Float?, nutrients : [String : Float]){
        var remain : Float = 0.0
        let kcal = nutrients["kcal"]!
        let proteins = nutrients["proteins"]!
        let carbs = nutrients["carbs"]!
        let fats = nutrients["fats"]!
        
        if bmi == nil {
            lblCaloriesGoal.text = "Undefined"
            lblCaloriesGoal.font = lblCaloriesGoal.font.withSize(20)
            lblCaloriesRemaining.text = "Undefined"
            lblCaloriesRemaining.font = lblCaloriesRemaining.font.withSize(20)
        } else {
            if bmi! > kcal {
                remain = bmi! - kcal;
            }
            lblCaloriesGoal.text = String(format: "%.2f",bmi!)
            lblCaloriesRemaining.text = String(format: "%.2f", remain)
        }
        
        
        lblProteins.text = String(format: "%.1f",proteins)
        lblCarbs.text = String(format: "%.1f", carbs)
        lblFats.text = String(format: "%.1f",fats)
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
        var kcal : Float = 0
        var proteins : Float = 0
        var carbs : Float = 0
        var fats : Float = 0
        
        for meal in todayMeals {
            kcal = kcal + meal.kcal
            proteins = proteins + meal.proteins
            carbs = carbs + meal.carbs
            fats = fats + meal.fats
        }
        
        return ["kcal" : kcal, "proteins" : proteins, "carbs" : carbs, "fats" : fats]
    }
    
    func getTodayKcalories(for todayMeals : [Meal]) -> Float {
        var sum : Float = 0
        for meal in todayMeals {
            sum = sum + meal.kcal
        }
        
        return sum
    }
}
//MARK: - DataManipulation Methods
extension HomeViewController {
    
    func getCurrentDay() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let currentDay = dateFormatter.string(from: date)
        
        return  currentDay
    }
    
    func loadMeals() -> [Meal] {
        let userEmail = Auth.auth().currentUser?.email
        var mealsArray : [Meal] = []
        let request : NSFetchRequest<Meal> = Meal.fetchRequest()
        let dayPredicate = NSPredicate(format: "day MATCHES %@", getCurrentDay())
        let userPredicate = NSPredicate(format: "userEmail MATCHES %@", userEmail!)
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [dayPredicate, userPredicate])
        
        do{
            mealsArray = try context.fetch(request)
        } catch {
            print("Error loading meals \(error)")
        }
        
        return mealsArray
    }
}
