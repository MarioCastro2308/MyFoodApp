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

    var selectedDay : String?
   
    
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
    
    func loadMealsData(){
        
        print("Loading meals...")
        if(selectedDay == nil ){
            getCurrentDayMeals()
        } else {
            loadMeals(for: selectedDay!)
        }
    }
    
    // si la variable selectedDay == nil se le asignara el valor del dia actual
    func getCurrentDayMeals(){
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        selectedDay = dateFormatter.string(from: date)
        
        loadMeals(for: selectedDay!)
    }
    
    // Se obtiene la lista de complementos para cada comida del arreglo
    func getComplements(){
        for meal in mealsArray{
            loadComplements(mealTitle: meal.title!)
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en")
            formatter.dateFormat = "hh:mm a"
            let hour = formatter.string(from: meal.hour!)
            
            mealsData.append(MealDataModel(mealTitle: meal.title!, mealHour: hour, mealComplements: complementsArray))
        }
        
        mealsTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMealDetails" {
            let mealVC: MealViewController = segue.destination as! MealViewController
            mealVC.selectedDay = selectedDay
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mealsData = []
        loadMealsData()
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
                
                let meal = mealsData[indexPath.section]
                
                cell.lblName.text = meal.mealTitle.uppercased()
                cell.lblQuantity.text = meal.mealHour
                
                
                cell.contentView.backgroundColor = #colorLiteral(red: 0.2666666667, green: 0.4784313725, blue: 0.2156862745, alpha: 1)
                cell.lblName.textColor = UIColor.white
                cell.lblQuantity.textColor = UIColor.white
                
            } else {
                let complement = mealsData[indexPath.section].mealComplements[indexPath.row - 1]
                cell.lblName.text = complement.name
                cell.lblQuantity.text = "\(complement.quantity)"
                
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
            
            if(mealsArray.count > 0){
                getComplements()
            } else {
                mealsTableView.reloadData()
            }
        } catch {
            print("Error loading meals \(error)")
        }
    }

}

