//
//  RegisterViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 15/06/23.
//

import UIKit
import FirebaseAuth;

class RegisterViewController: UIViewController {

    @IBOutlet weak var txtFieldPassword: UITextField!
    
    @IBOutlet weak var txtFieldEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnRegisterAction(_ sender: UIButton) {
        
        if let email = txtFieldEmail.text, let password = txtFieldPassword.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                
                if let e = error {
                    print("Register error: \(e.localizedDescription)")
                } else{
//                    self.performSegue(withIdentifier: "RegisterToMain", sender: self)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "SuperViewID") as! SuperViewController
                    
                    self.present(vc, animated: true)

                }
            }
        }
    }
    

}
