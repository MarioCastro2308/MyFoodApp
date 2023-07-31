//
//  UserProfileViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 20/07/23.
//

import UIKit
import FirebaseAuth

class UserProfileViewController: UIViewController {

    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var txtFieldUsername: UITextField!
    @IBOutlet weak var txtFieldHeight: UITextField!
    @IBOutlet weak var txtFieldWeight: UITextField!
    @IBOutlet weak var txtFieldGender: UITextField!
    @IBOutlet weak var txtFieldAge: UITextField!
    
    let pickerView = UIPickerView()
    let genderArray = ["Male", "Female"]
    var userData : UserDataModel?
    let userDataManager = UserDataManager()
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
        txtFieldGender.text = genderArray[0]
        
        getUserData()
    }
    
    
    func getUserData(){
        userDataManager.getUserData { data in
            self.userData = data
            self.updateFormData()
        }
    }
    
    @IBAction func btnSaveDataAction(_ sender: UIButton) {
        if(validateUserData()){
//            saveUserData()
            userDataManager.saveUserData(data: userData!) { error in
                if let e = error {
                    self.showMessageAlert(title: "Error!", message: "Error registering user information")
                } else {
                    self.showMessageAlert(title: "Success!", message: "User information successfully registered")
                }
            }
        }
        else {
            showMessageAlert(title: "invalid Data", message: "The information entered is wrong")
        }
    }
    
    func validateUserData() -> Bool {
        
        if let username = txtFieldUsername.text, !username.isEmpty,
           let height = txtFieldHeight.text, !height.isEmpty, Float(height) != nil,
           let weight = txtFieldWeight.text, !weight.isEmpty, Float(weight) != nil,
           let gender = txtFieldGender.text, !gender.isEmpty,
           let age = txtFieldAge.text, !age.isEmpty, Int(age) != nil,
           let currentUserEmail = Auth.auth().currentUser?.email
        {
            userData = UserDataModel(userEmail : currentUserEmail, userName: username, userHeight: Float(height)!, userWeight: Float(weight)!, userGender: gender, userAge: Int(age)!)
            
            return true
        }
        
        return false
    }
    
    func updateFormData(){
        txtFieldUsername.text = "\(userData!.userName)"
        txtFieldHeight.text = "\(userData!.userHeight)"
        txtFieldWeight.text = "\(userData!.userWeight)"
        txtFieldGender.text = "\(userData!.userGender)"
        txtFieldAge.text = "\(userData!.userAge)"
    }
    
    func showMessageAlert(title : String, message : String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
  
}

//MARK: - UIPickerViewDelegate and UIPickerViewDataSource Methods

extension UserProfileViewController : UIPickerViewDelegate,UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderArray.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderArray[row]
    }

    func pickerView(_ pickerView:UIPickerView,didSelectRow row: Int,inComponent component: Int){
        txtFieldGender.text = genderArray[row]
        txtFieldGender.resignFirstResponder()
    }
}
