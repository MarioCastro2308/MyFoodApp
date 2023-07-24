//
//  MealViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 21/07/23.
//

import UIKit
import CoreData

class MealViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var complementsArray = [Complements]()
    
    @IBOutlet weak var dateTxtField: UITextField!
    @IBOutlet weak var complementsTableView: UITableView!
    
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegates
        complementsTableView.delegate = self
        complementsTableView.dataSource = self
        
        complementsTableView.register(UINib(nibName: "ComplementCell", bundle: nil), forCellReuseIdentifier: "ComplementCell")
        
        createDatePicker()
    }
    
    func createToolbar () -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonAction))
        
        toolBar.setItems([doneBtn], animated: true)
        return toolBar
    }
    
    func createDatePicker(){
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .time
        dateTxtField.inputView = datePicker
        dateTxtField.inputAccessoryView = createToolbar()
    }

    @objc func doneButtonAction (){
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_gb")
        formatter.dateFormat = "HH:mm:ss"
        dateTxtField.text = formatter.string(from: datePicker.date)
        view.endEditing(true)
    }
}

//MARK: - UITableViewDelegate Methods
extension MealViewController : UITableViewDelegate {
    
}

//MARK: - UITableViewDataSource Methods
extension MealViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComplementCell", for: indexPath) as! ComplementCell
        cell.lblName.text = "Hello"
        cell.lblQuantity.text = "100 gr"
        
        return cell
    }
    
    
}

