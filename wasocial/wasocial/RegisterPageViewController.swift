//
//  RegisterPageViewController.swift
//  wasocial
//
//  Created by 草我 on 2017/4/9.
//  Copyright © 2017年 陈逸山. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class RegisterPageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var repeatPasswordField: UITextField!
    @IBOutlet weak var realnameField: UITextField!
    @IBOutlet weak var gradeField: UITextField!
    @IBOutlet weak var profileImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        var tapgesture = UITapGestureRecognizer(target: self,action:"ImageTapped")
        profileImg.isUserInteractionEnabled = true
        profileImg.addGestureRecognizer(tapgesture)
        // Do any additional setup after loading the view.
    }

    func ImageTapped(){
        let myPicker = UIImagePickerController()
        myPicker.delegate = self
        myPicker.sourceType = .photoLibrary
        myPicker.allowsEditing = true
        present(myPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        profileImg.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerButton(_ sender: Any) {
        let username = usernameField.text
        let password = passwordField.text
        let repeatPassword = repeatPasswordField.text
        let realname = realnameField.text
        let grade = gradeField.text
        
        //Check for empty
        
        
        if((username?.isEmpty)! || (password?.isEmpty)! || (repeatPassword?.isEmpty)! || (repeatPassword?.isEmpty)! || (repeatPassword?.isEmpty)!){
            
            displayMyAlertMessage(AlertMessage: "All fields are required")
            return
        }else if(password != repeatPassword){
            displayMyAlertMessage(AlertMessage: "Passwords don't match")
            return
        }else if(!isValidEmail(testStr: username!)){
            displayMyAlertMessage(AlertMessage: "The email address is badly formatted")
            return
        }else if((password?.characters.count)! < 7){
            displayMyAlertMessage(AlertMessage: "Password is too short!")
            return
        }else{
            // create account
            FIRAuth.auth()?.createUser(withEmail: self.usernameField.text!,password:self.passwordField.text!,completion:{(user,error) in
                if error == nil{
                    
                    self.usernameField.text = ""
                    self.passwordField.text = ""
                    self.repeatPasswordField.text = ""
                }
                else{
                    let alertController = UIAlertController(title: "Oops!", message: error?.localizedDescription,preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                let imageName = NSUUID().uuidString
                let storageRef = FIRStorage.storage().reference().child(imageName)
                if let uploadData = UIImagePNGRepresentation(self.profileImg.image!){
                storageRef.put(uploadData, metadata: nil, completion:
                    {(metadata, error) in
                        if error != nil{
                            print(error)
                            return
                        }
                        if let profileImgURL = metadata?.downloadURL()?.absoluteString{
                            let user = User(realname: realname!, grade: grade!, email: username!, profileImgURL: profileImgURL)
                            self.registerUser(realname: realname!,user: user)
                        }
                    })
                }
            })
            
        }

        
        //Display alert message with confirmation
        var myAlert = UIAlertController(title: "Success", message: "Registration is successful, thank you!", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (myAlert) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    private func registerUser(realname:String, user: User){
        let ref = FIRDatabase.database().reference(withPath: "user")
        let userRef = ref.childByAutoId()
        userRef.setValue(user.toAnyObject())
        UserDefaults.standard.set(realname, forKey: "realname")
    }
    
    func displayMyAlertMessage(AlertMessage:String){
        var myAlert = UIAlertController(title: "Alert", message: AlertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
    }

    @IBAction func exitButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

}
