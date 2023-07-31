//
//  UserProfileViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 20/07/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

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
    
    var currentUserEmail : String?
    
    
    let db = Firestore.firestore()
    
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
    
    
    @IBAction func btnSaveDataAction(_ sender: UIButton) {
        if(validateUserData()){
            saveUserData()
        }
        else {
            print("Invalid Data")
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
        // yiuaosd
        txtFieldGender.text = genderArray[row]
        txtFieldGender.resignFirstResponder()
    }
}

//MARK: - FireStore DataManipulationMethods
extension UserProfileViewController{
    
    // Gets the information of the currently logged in user
    func getUserData(){
        
        if let userEmail = Auth.auth().currentUser?.email {
            let usersColection = db.collection(K.FStore.colectionName)
            let query = usersColection.whereField(K.FStore.emailField, isEqualTo: userEmail)
            
            query.getDocuments { querySnapshot, error in
                
                if let e = error {
                    print("Error retrieving data from firebase: \(e)")
                } else {
                    
                    if let snapshotDocuments = querySnapshot?.documents, !snapshotDocuments.isEmpty {
                        
                        for doc in snapshotDocuments {
                            print(doc.data())
                            let currentUserData = doc.data()
                            
                            self.userData = UserDataModel(userEmail: currentUserData["userEmail"] as! String, userName: currentUserData["userName"] as! String, userHeight: currentUserData["userHeight"] as! Float, userWeight: currentUserData["userWeight"] as! Float, userGender: currentUserData["userGender"] as! String, userAge: currentUserData["userAge"] as! Int)
                            
                            self.updateFormData()
                        }
                    }
                    else {
                        print("User Data not found")
                    }
                }
            }
        } else {
            print("Current user not found")
        }
    }
    
    func saveUserData(){

        let usersColection = db.collection(K.FStore.colectionName)
        let userEmail = userData!.userEmail
        
        usersColection.document(userEmail).setData([
            K.FStore.emailField : userData!.userEmail,
            K.FStore.usernameField : userData!.userName,
            K.FStore.heightField : userData!.userHeight,
            K.FStore.weightField : userData!.userWeight,
            K.FStore.genderField : userData!.userGender,
            K.FStore.ageField : userData!.userAge
        ]) { error in
            if let e = error {
                self.showMessageAlert(title: "Error!", message: "Error registering user information")
            } else {
                self.showMessageAlert(title: "Success!", message: "User information successfully registered")
                //                self.getUserData()
            }
        }
    }
}
