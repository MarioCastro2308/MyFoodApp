//
//  UserDataManager.swift
//  MyFoodApp
//
//  Created by Mario Castro on 28/07/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

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
                            
                            self.userData = UserDataModel(userEmail: currentUserData["userEmail"] as! String, userName: currentUserData["userName"] as! String, userHeight: currentUserData["userHeight"] as! Float, userWeight: currentUserData["userWeight"] as! Float, userGender: currentUserData["userGender"] as! String, userAge: currentUserData["userAge"] as! Int)
                            
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
}
