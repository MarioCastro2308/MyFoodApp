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
    var mealsData = [MealDataModel]()
    
    let dayPickerView = UIPickerView()
    var selectedDay : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegates
        mealsTableView.dataSource = self
        
        txtFieldDay.inputView = dayPickerView
        txtFieldDay.text = daysArray[0]
        dayPickerView.dataSource = self
        dayPickerView.delegate = self
        // Side Menu button
        btnSideMenu.target = revealViewController()
        btnSideMenu.action = #selector(revealViewController()?.revealSideMenu)
        // Tebleview Cell
        mealsTableView.register(UINib(nibName: "ComplementCell", bundle: nil), forCellReuseIdentifier: "ComplementCell")
        loadMealData()
    }
    
    
    @IBAction func btnSearchAction(_ sender: UIButton) {
        mealsData = []
        print("Meals before get loadmeals:  \(mealsData.count)")
        print(selectedDay)
        loadMealData()
    }
    
    func loadMealData(){
        print("Loading meals...")
        if(selectedDay == nil ){
            selectedDay = daysArray[0]
            loadMeals(for: selectedDay!)
        } else {
            loadMeals(for: selectedDay!)
        }
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
        print("Meals after get complements:  \(mealsData.count)")
        mealsTableView.reloadData()
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

extension WeakPlanViewController {
    
    func loadMeals(for selectedDay : String){
        // 2. Obtenemos que comidas estan registradas para el dia de hoy
        let request : NSFetchRequest<Meal> = Meal.fetchRequest()
        let dayPredicate = NSPredicate(format: "day MATCHES %@", selectedDay)
        
        request.predicate = dayPredicate
        
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
