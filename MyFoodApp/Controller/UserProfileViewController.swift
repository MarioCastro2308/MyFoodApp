//
//  UserProfileViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 20/07/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class UserProfileViewController: UIViewController {
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var txtFieldUsername: UITextField!
    @IBOutlet weak var txtFieldHeight: UITextField!
    @IBOutlet weak var txtFieldWeight: UITextField!
    @IBOutlet weak var txtFieldGender: UITextField!
    @IBOutlet weak var txtFieldAge: UITextField!
    
    @IBOutlet weak var btnSideMenu: UIBarButtonItem!
    
    
    let pickerView = UIPickerView()
    let genderArray = ["Male", "Female"]
    var userData : UserDataModel?
    let userDataManager = UserDataManager()
    var imagePath : String?
    var selectedImage : UIImage?
    var isProfileImgUpdated : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSideMenu.target = revealViewController()
        btnSideMenu.action = #selector(revealViewController()?.revealSideMenu)
        
        // Profile ImageView
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.borderWidth = 2
        
        // Picker view
        pickerView.delegate = self
        pickerView.dataSource = self
        txtFieldGender.inputView = pickerView
        txtFieldGender.text = genderArray[0]
        
        tapgesture()
        getUserData()
        
    }
    
    func tapgesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tap)
    }
    
    @objc func profileImageTapped(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true)
    }
    
    // Get the information of the current user
    func getUserData(){
        userDataManager.getUserData { data in
            if data != nil {
                self.userData = data
                self.imagePath = data?.imagePath
                self.updateFormData()
            }
        }
    }
    
    @IBAction func btnSaveDataAction(_ sender: UIButton) {
        
        if(validateFormData()){

            if(imagePath != nil && isProfileImgUpdated){
                userDataManager.deleteOlderProfilePicture(for: imagePath!) { error in
                    if let e  = error {
                        print("Error deleting old profile image: \(e)")
                    } else {
                        self.userDataManager.saveProfilePicture(image: self.profileImageView.image!) { newImagePath in
                            self.userData?.imagePath = newImagePath
                            self.saveUserData()
                        }
                    }
                }
            } else if(imagePath != nil && isProfileImgUpdated == false) {
                userData?.imagePath = imagePath
                saveUserData()
            } else {
                userDataManager.saveProfilePicture(image: profileImageView.image!) { newImagePath in
                    self.userData?.imagePath = newImagePath
                    self.saveUserData()
                }
            }
        }
    }
    
    func saveUserData(){
        userDataManager.saveUserData(data: userData!) { error in
            if let e = error {
                self.showMessageAlert(title: "Error!", message: "\(e.localizedDescription)")
            } else {
                self.showMessageAlert(title: "Success!", message: "User information successfully registered")
            }
        }
    }
    
    // Validate the information on the form
    func validateFormData() -> Bool {
        
        let username : String? = txtFieldUsername.text
        let height : String? = txtFieldHeight.text
        let weight : String? = txtFieldWeight.text
        let gender : String? = txtFieldGender.text
        let age : String? = txtFieldAge.text
        let currentUserEmail : String? = Auth.auth().currentUser?.email
        
        if currentUserEmail == nil {
            showMessageAlert(title: "Error", message: "User not found")
            return false
        }
        
        if username!.isEmpty || height!.isEmpty || weight!.isEmpty || gender!.isEmpty || age!.isEmpty
        {
            showMessageAlert(title: "Sorry!", message: "Please, fill out all the fields")
            return false
        }
        
        if Float(height!) == nil  || Float(weight!) == nil || Int(age!) == nil {
            showMessageAlert(title: "Sorry!", message: "Invalid date type")
            return false
        }
        
        if selectedImage == nil {
            showMessageAlert(title: "Sorry!", message: "Please, add a profile picture")
            return false
        }
        
        
        userData = UserDataModel(imagePath : nil, userEmail : currentUserEmail!, userName: username!, userHeight: Float(height!)!, userWeight: Float(weight!)!, userGender: gender!, userAge: Int(age!)!)
        
        return true
        
    }
    
    func updateFormData() {
        
        userDataManager.getUserProfilePhoto(for: userData!.imagePath!, completionHandler: { image in
            self.selectedImage = image
            self.profileImageView.image = image
        })
        
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

//MARK: - UIImagePickerControllerDelegate

extension UserProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        selectedImage = info[.originalImage] as? UIImage
        profileImageView.image = selectedImage
        isProfileImgUpdated = true
        dismiss(animated: true)
    }
}
