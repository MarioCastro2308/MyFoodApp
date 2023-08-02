//
//  UserDataManager.swift
//  MyFoodApp
//
//  Created by Mario Castro on 28/07/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


class UserDataManager {
    
    var userData : UserDataModel? 
    let db = Firestore.firestore()

    func getUserData(completionHandler : @escaping (UserDataModel?) -> Void){
        
        if let userEmail = Auth.auth().currentUser?.email {
            
            let usersColection = db.collection(K.FStore.colectionName)
            let query = usersColection.whereField(K.FStore.emailField, isEqualTo: userEmail)
            
            query.getDocuments { querySnapshot, error in
                
                if let e = error {
                    print("Error retrieving data from firebase \(e)")
                } else {
                    
                    if let snapshotDocuments = querySnapshot?.documents, !snapshotDocuments.isEmpty {
                        
                        for doc in snapshotDocuments {
//                            print(doc.data())
                            let currentUserData = doc.data()
                            
                            self.userData = UserDataModel(
                                imagePath: currentUserData["profileImagePath"] as? String,
                                userEmail: currentUserData["userEmail"] as! String, userName: currentUserData["userName"] as! String, userHeight: currentUserData["userHeight"] as! Float, userWeight: currentUserData["userWeight"] as! Float, userGender: currentUserData["userGender"] as! String, userAge: currentUserData["userAge"] as! Int)
                            
                            completionHandler(self.userData)
                        }
                        
                    }
                    else {
                        completionHandler(self.userData)
                        print("El usuario no he registrado su informacion")
                    }
                }
            }
        } else {
            print("El usuario no fue encontrado")
        }
    }
    
    
    func saveUserData(data : UserDataModel,  completionHandler : @escaping (Error?) -> Void){

        let usersColection = db.collection(K.FStore.colectionName)
        let userEmail = data.userEmail
        
        usersColection.document(userEmail).setData([
            K.FStore.imagePath : data.imagePath!,
            K.FStore.emailField : data.userEmail,
            K.FStore.usernameField : data.userName,
            K.FStore.heightField : data.userHeight,
            K.FStore.weightField : data.userWeight,
            K.FStore.genderField : data.userGender,
            K.FStore.ageField : data.userAge
        ]) { error in
            if let e = error {
                completionHandler(e)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func getUserProfilePhoto(for path : String, completionHandler : @escaping (UIImage) -> Void ){
        // Create a reference with an initial file path and name
        let storage = Storage.storage().reference()
        // Create a reference to the file you want to download
        let fileRef = storage.child(path)
        
        fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let e = error {
                print("Error retrieving image from FireStorage : \(e)")
              } else {
                let image = UIImage(data: data!)
                completionHandler(image!)
              }
        }
    }
    
    func deleteOlderProfilePicture(for path : String, completionHandler : @escaping (Error?) -> Void) {
        
        let storage = Storage.storage().reference()
        let fileRef = storage.child(path)

        // Delete the file
        fileRef.delete { error in
          if let e = error {
              completionHandler(e)
          } else {
              completionHandler(nil)          }
        }
    }
    
    func saveProfilePicture(image : UIImage, completionHandler : @escaping (String) -> Void ) {
        // Create Storage Reference
        let storage = Storage.storage().reference()
        // Tourn our image into data
        let imageData = image.jpegData(compressionQuality: 0.50)
        
        guard imageData != nil else {
            return
        }
        
        let imagePath = "images/\(UUID().uuidString).jpg"
        
        // specify the filepath and name
        let fileRef = storage.child(imagePath)
        
        //upload that data
        fileRef.putData(imageData!, metadata: nil) { metadata, error in
            if let e = error {
                print("Error saving foto to FirebaseStorage : \(e)")
                return
            } else {
                completionHandler(imagePath)
            }
        }
    }

}
