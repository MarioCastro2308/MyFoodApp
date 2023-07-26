//
//  TodayMealsViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 20/07/23.
//

import UIKit
import CoreData

class TodayMealsViewController: UIViewController {
    
    @IBOutlet weak var btnSideMenu: UIBarButtonItem!
    @IBOutlet weak var mealsTableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var mealsArray = [Meal]()
    var complementsArray = [Complement]()
    var mealsData = [MealDataModel]()
    
    var selectedDay : String? {
        didSet {
            loadMeals(for: selectedDay!)
            self.title = selectedDay
            
        }
    }
   
    
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
        
        if(selectedDay == nil ){
            getCurrentDayMeals()
        }
    }
    
    func getCurrentDayMeals(){
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        selectedDay = dateFormatter.string(from: date)
    }
    
    func getComplements(){
        for meal in mealsArray{
            loadComplements(mealTitle: meal.title!)
            mealsData.append(MealDataModel(mealTitle: meal.title!, mealComplements: complementsArray))
        }
        
        print("Number of meals: \(mealsData.count)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMealDetails" {
            let mealVC: MealViewController = segue.destination as! MealViewController
            mealVC.selectedDay = selectedDay
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mealsTableView.reloadData()
    }
    
    
}

//MARK: - UITableViewControllerDelegate Methods

extension TodayMealsViewController : UITableViewDelegate {
    
}


//MARK: - UITableViewControllerDataSource Methods

extension TodayMealsViewController : UITableViewDataSource {
        
    func numberOfSections(in tableView: UITableView) -> Int {
        if(mealsData.count > 0){
            return mealsData.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(mealsData.count > 0){
//            loadComplements(mealTitle: mealsArray[section].title!)
//            mealsData.append(MealDataModel(mealTitle: mealsArray[section].title!, mealComplements: complementsArray))
//            print("Meal: \(mealsData)")
//            return complementsArray.count
            return mealsData[section].mealComplements.count + 1
            
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComplementCell", for: indexPath) as! ComplementCell
        
        // si hay alguna comida establecida para el dia de hoy
        if(mealsData.count > 0){
            // si se trata de a primera celda (section title)
            if(indexPath.row == 0) {
                
                let mealTitle = mealsData[indexPath.section].mealTitle
                cell.lblName.text = mealTitle
                cell.lblQuantity.text = ""
            } else {
                let complement = mealsData[indexPath.section].mealComplements[indexPath.row - 1]
                cell.lblName.text = complement.name
                cell.lblQuantity.text = "\(complement.quantity)"
            }
            
        } else {
            cell.lblName.text = "No meal added yet"
            cell.lblQuantity.text = ""
        }
        
        return cell
    }
    
    
}

//MARK: - ManipulationData Methods

extension TodayMealsViewController {

    func loadComplements(mealTitle : String){
        let request : NSFetchRequest<Complement> = Complement.fetchRequest()
        let complementPredicate = NSPredicate(format: "parentMeal.title MATCHES %@", mealTitle)
        
//        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
//        request.sortDescriptors = [sortDescriptor]
        request.predicate = complementPredicate
        do{
            complementsArray = try context.fetch(request)
        } catch {
          print("Error loading complements \(error)")
        }
    }

    func loadMeals(for selectedDay : String){
        
        let request : NSFetchRequest<Meal> = Meal.fetchRequest()
        let mealPredicate = NSPredicate(format: "day MATCHES %@", selectedDay)

        request.predicate = mealPredicate

        do{
            mealsArray = try context.fetch(request)
            getComplements()
        } catch {
            print("Error loading meals \(error)")
        }
    }

}

