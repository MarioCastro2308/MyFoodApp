//
//  WeakPlanViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 25/07/23.
//

import UIKit
import CoreData
class WeakPlanViewController: UIViewController {
    
    
    @IBOutlet weak var txtFieldDay: UITextField!
    @IBOutlet weak var mealsTableView: UITableView!
    @IBOutlet weak var btnSideMenu: UIBarButtonItem!
    
    let daysArray = ["lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo"]
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var mealsArray = [Meal]()
    var complementsArray = [Complement]()
    
    let dayPickerView = UIPickerView()
    var selectedDay : String = "lunes"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegates
        mealsTableView.dataSource = self
        
        txtFieldDay.inputView = dayPickerView
        txtFieldDay.text = selectedDay
        dayPickerView.dataSource = self
        dayPickerView.delegate = self
        // Side Menu button
        btnSideMenu.target = revealViewController()
        btnSideMenu.action = #selector(revealViewController()?.revealSideMenu)
        // Tebleview Cell
        mealsTableView.register(UINib(nibName: "ComplementCell", bundle: nil), forCellReuseIdentifier: "ComplementCell")
        
    }
    
    
    @IBAction func btnSearchAction(_ sender: UIButton) {
        
        loadMeals(for: selectedDay)
        
        print(selectedDay)
        print(mealsArray)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditMeal" {
            let mealVC: TodayMealsViewController = segue.destination as! TodayMealsViewController
            mealVC.selectedDay = selectedDay
        }
    }
    
    
    
}

//MARK: - UIPickerViewDatasource Methods
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
        if(mealsArray.count > 0){
            return mealsArray.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(mealsArray.count > 0){
            loadComplements(mealTitle: mealsArray[section].title!)
            return complementsArray.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComplementCell", for: indexPath) as! ComplementCell
        
        
        // si hay alguna comida establecida para el dia de hoy
        if(mealsArray.count > 0){
            // si se trata de a primera celda (section title)
            if(indexPath.row == 0) {
                let meal = mealsArray[indexPath.section]
                cell.lblName.text = meal.title
                cell.lblQuantity.text = ""
            } else {
                let complement = complementsArray[indexPath.row]
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

extension WeakPlanViewController {
    
    func loadMeals(for selectedDay : String){
        // 2. Obtenemos que comidas estan registradas para el dia de hoy
        let request : NSFetchRequest<Meal> = Meal.fetchRequest()
        let dayPredicate = NSPredicate(format: "day MATCHES %@", selectedDay)
        
        request.predicate = dayPredicate
        
        do{
            mealsArray = try context.fetch(request)
        } catch {
            print("Error loading meals \(error)")
        }
    }
    
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
    
}
