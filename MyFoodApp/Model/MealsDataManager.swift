//
//  MealsDataManager.swift
//  MyFoodApp
//
//  Created by Mario Castro on 28/07/23.
//

import Foundation
import CoreData
import FirebaseFirestore
import FirebaseAuth

class MealsDataManager{
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var mealsArray = [Meal]()
    
    var complementsArray = [Complement]()
    let db = Firestore.firestore()
    
    // Get the full list of meals for the current user in the selected day
    func loadMeals(for selectedDay : String, completionHandler : ([Meal]) -> Void) {
        
        if let userEmail = Auth.auth().currentUser?.email {
            
            let request : NSFetchRequest<Meal> = Meal.fetchRequest()
            let dayPredicate = NSPredicate(format: "day MATCHES %@", selectedDay)
            let userPredicate = NSPredicate(format: "userEmail MATCHES %@", userEmail)
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [dayPredicate, userPredicate])
            
            do{
                mealsArray = try context.fetch(request)
                completionHandler(mealsArray)
            } catch {
                print("Error loading meals \(error)")
            }
        } else {
            print("Usuario no encontrado")
        }
    }
    
    func loadMeal(selectedDay : String, mealTitle : String , completionHandler : (Meal) -> Void) {
        
        if let userEmail = Auth.auth().currentUser?.email {
            
            let request : NSFetchRequest<Meal> = Meal.fetchRequest()
            let dayPredicate = NSPredicate(format: "day MATCHES %@", selectedDay)
            let userPredicate = NSPredicate(format: "userEmail MATCHES %@", userEmail)
            let titlePredicate = NSPredicate(format: "title MATCHES %@", mealTitle)
            
            
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [dayPredicate, userPredicate, titlePredicate])
            
            do{
                mealsArray = try context.fetch(request)
                completionHandler(mealsArray[0])
            } catch {
                print("Error loading meals \(error)")
            }
        } else {
            print("Usuario no encontrado")
        }
    }
    
    func loadComplements(for meal : Meal, completionHandler : ([Complement]) -> Void){
        
        if let userEmail = Auth.auth().currentUser?.email{
            
            let request : NSFetchRequest<Complement> = Complement.fetchRequest()
            
            let emailPredicate = NSPredicate(format: "parentMeal.userEmail MATCHES %@", userEmail)
            let dayPredicate = NSPredicate(format: "parentMeal.day MATCHES %@", meal.day!)
            let titlePredicate = NSPredicate(format: "parentMeal.title MATCHES %@", meal.title!)
            
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [emailPredicate, dayPredicate, titlePredicate])
            //        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
            //        request.sortDescriptors = [sortDescriptor]
            do{
                complementsArray = try context.fetch(request)
                completionHandler(complementsArray)
            } catch {
                print("Error loading complements \(error)")
            }
        }
    }
}
