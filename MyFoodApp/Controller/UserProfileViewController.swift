//
//  UserProfileViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 20/07/23.
//

import UIKit

class UserProfileViewController: UIViewController, UIPickerViewDelegate,UIPickerViewDataSource {

    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var txtFieldGender: UITextField!
    
    let pickerView = UIPickerView()
    let gender1 = ["Male", "Female"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Profile ImageView
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.borderWidth = 2
        
        // Picker view
        pickerView.delegate = self
        pickerView.dataSource = self
        txtFieldGender.inputView = pickerView
        
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gender1.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gender1[row]
    }

    func pickerView(_ pickerView:UIPickerView,didSelectRow row: Int,inComponent component: Int){
        txtFieldGender.text = gender1[row]
        txtFieldGender.resignFirstResponder()
    }

}
