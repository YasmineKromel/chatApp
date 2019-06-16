//
//  ChatVC.swift
//  chatApp
//
//  Created by Yasmine on 5/22/19.
//  Copyright © 2019 Yasmine. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SwiftKeychainWrapper


class LoginVC: UIViewController, UITextFieldDelegate{
    
    
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var userUID:String?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view. 3mla a ya yasmin    }
        email.delegate = self
        password.delegate = self
        
    }
    
    
    @IBAction func anonymousTapped(_ sender: UIButton) {
        
        Auth.auth().signInAnonymously() { (authResult, error) in
           // let user = authResult.user
           // let isAnonymous = user.isAnonymous  // true
          //  let uid = user.uid
            if error == nil
            {
                let controller = chattingVC()
                self.present(controller, animated: true, completion: nil)
                
            }
        }
    }
    
    
    
    @IBAction func userAuth(_ sender: UIButton) {
        
      //  if let email = email.text, let password = password.text {
        let email = "yas@gmail.com"
        let password = "12345678"
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if error == nil {
                    self.userUID = user?.user.uid
                    KeychainWrapper.standard.set(self.userUID!, forKey: "uid")
                   // self.performSegue(withIdentifier: "toMessage", sender: nil)
                    let controller = chattingVC()
                    self.present(controller, animated: true, completion: nil)
                } else {
                    Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                        if error != nil {
                            print("cant sign in user")
                        } else {
                          //self.performSegue(withIdentifier: "toMessage", sender: nil)
                            let controller = chattingVC()
                            self.present(controller, animated: true, completion: nil)
                        }
                    }
                }
            }
       // }
        
    }
    
       
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
}
    
    
    
    
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


