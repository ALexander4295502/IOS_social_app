//
//  LoginViewController.swift
//  wasocial
//
//  Created by 草我 on 2017/4/9.
//  Copyright © 2017年 陈逸山. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButton(_ sender: Any) {
        let username = usernameField.text
        let password = passwordField.text
      //        let usernameStored = UserDefaults.standard.string(forKey: "userName")
//        let passwordStored = UserDefaults.standard.string(forKey: "passWord")
        if((username?.isEmpty)! || (password?.isEmpty)!){
            
            displayMyAlertMessage(AlertMessage: "All fields are required")
            return
        }else{
            FIRAuth.auth()?.signIn(withEmail: self.usernameField.text!, password: self.passwordField.text!, completion: {(user,error) in
                if error == nil{
                    self.usernameField.text = ""
                    self.passwordField.text = ""
                    UserDefaults.standard.set(true, forKey: "userLoggedIn")
                    self.dismiss(animated: true, completion: nil)
                    print("username", username)
                    UserDefaults.standard.set(username, forKey: "userName")
                    UserDefaults.standard.synchronize()

                    
                }
                else{
                    let alertController = UIAlertController(title: "Oops!", message: error?.localizedDescription,preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                }
            })
            
        }
        
        
    }
    
    func displayMyAlertMessage(AlertMessage:String){
        var myAlert = UIAlertController(title: "Alert", message: AlertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
