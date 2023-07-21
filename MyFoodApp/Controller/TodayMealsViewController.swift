//
//  TodayMealsViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 20/07/23.
//

import UIKit

class TodayMealsViewController: UITableViewController {
    
    var mealsArray : [MealTest] = [
        MealTest(title: "BreakFast", complements: ["Chicken", "Rice", "Potatos"]),
        MealTest(title: "First Meal", complements: ["Chicken", "Pasta", "Avocado", "Fruit", "Avena", "Milk"]),
        MealTest(title: "Dinner", complements: ["Yogurth"]),
    ]
    
    
    @IBOutlet weak var sideMenuBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenuBtn.target = revealViewController()
        sideMenuBtn.action = #selector(revealViewController()?.revealSideMenu)
        tableView.tag = 100
        tableView.register(UINib(nibName: "MealCell", bundle: nil), forCellReuseIdentifier: "MealCell")
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

//    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80
//    }
    
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        return mealsArray.count
    //    }
    //
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mealsArray.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath) as! MealCell
        cell.mealTitleLabel.text = mealsArray[indexPath.row].title
        cell.complements = mealsArray[indexPath.row].complements
        cell.layoutIfNeeded()
        return cell
        
    }
}

extension UITableView {
    open override var intrinsicContentSize: CGSize {
            self.layoutIfNeeded()
            return self.contentSize
        }
        
    open override var contentSize: CGSize {
            didSet{
                self.invalidateIntrinsicContentSize()
            }
        }
}

