//
//  LoginViewController.swift
//  MyFoodApp
//
//  Created by Mario Castro on 15/06/23.
//

import UIKit
import FirebaseAuth
class LoginViewController: UIViewController {

    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func btnLoginAction(_ sender: UIButton) {
        
        if let email = txtFieldEmail.text, let password = txtFieldPassword.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
               
                if let e = error {
                    print("Login error: \(e.localizedDescription)")
                } else{
//                    self.performSegue(withIdentifier: "LoginToMain", sender: self)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "SuperViewID") as! SuperViewController
                    
                    self.present(vc, animated: true)
//                    self.view.insertSubview(vc.view, at: 1)
//                    self.addChild(vc)
//                    DispatchQueue.main.async {
//                        vc.view.translatesAutoresizingMaskIntoConstraints = false
//                        NSLayoutConstraint.activate([
//                            vc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//                            vc.view.topAnchor.constraint(equalTo: self.view.topAnchor),
//                            vc.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//                            vc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
//                        ])
//                    }
//
//                    vc.didMove(toParent: self)
                }
            }
        }
    }
    
}
