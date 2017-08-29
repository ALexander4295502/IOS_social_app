//
//  ViewController.swift
//  wasocial
//
//  Created by 陈逸山 on 4/9/17.
//  Copyright © 2017 陈逸山. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    
   
    @IBOutlet weak var diaryViewTable: UITableView!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var username: UILabel!
    var friendDisplayList: [String]=[]
    var diaryDisplayList: [Diary]=[]
    var realname : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let isUserLogginIn = UserDefaults.standard.bool(forKey: "userLoggedIn")
        let email = UserDefaults.standard.string(forKey: "userName")
        if(!isUserLogginIn){
            self.performSegue(withIdentifier: "loginView", sender: self);
        }else{
            setProfileImage()
        }
        retriveDiary()
    }
    
    func setProfileImage(){
        let email = UserDefaults.standard.string(forKey: "userName")!
        let userRef = FIRDatabase.database().reference(withPath: "user")
        userRef.observe(.value, with: {snapshot in
            for child in snapshot.children{
                let childsnap = child as! FIRDataSnapshot
                if let snapshotValue = childsnap.value as? NSDictionary, let snapVal = snapshotValue["email"] as? String {
                    if(snapVal == email){
                        self.realname = snapshotValue["realname"] as? String
                        self.username.text = self.realname
                        if let profileImageUrl = snapshotValue["profileImgURL"] as? String {
                            let url = NSURL(string: profileImageUrl)
                            URLSession.shared.dataTask(with: url! as URL, completionHandler:{(data, response, error) in
                                
                                if error != nil{
                                    print(error!)
                                    return
                                }
                                DispatchQueue.main.sync(execute: {
                                    print(data!)
                                    self.profilePhoto.image = UIImage(data: data!)
                                })
                            }).resume()
                        }
                    }
                }
            }
        })
    }
    func retriveDiary(){
        diaryViewTable.dataSource = self
        diaryViewTable.delegate = self
        let diaryRef = FIRDatabase.database().reference(withPath: "diary")
        diaryRef.observe(.value, with: { snapshot in
            self.diaryDisplayList.removeAll()
            for child in snapshot.children {
                let childsnap = child as! FIRDataSnapshot
                if let snapshotValue = childsnap.value as? NSDictionary, let snapVal = snapshotValue["user"] as? String {
                    
                    if(snapVal == UserDefaults.standard.string(forKey: "userName")){
                        
                        let diaryGet = Diary(date:(snapshotValue["date"] as? String)!, title: (snapshotValue["title"] as? String)!, user: (snapshotValue["user"] as? String)!, content: (snapshotValue["content"] as? String)!, mykey: (snapshotValue["mykey"] as? String)!, emotion: (snapshotValue["emotion"] as? Double)!, visible:(snapshotValue["visible"] as? String)! ,imageURL: (snapshotValue["imageURL"] as? String)!)
                        
                        self.diaryDisplayList.append(diaryGet)
                        }
                }
                
            }
            print(self.diaryDisplayList)
            self.diaryViewTable.reloadData()
        })

    }
        
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == self.diaryViewTable){
            
            let detailedVC = DiaryDetailViewController(nibName: "DiaryDetailViewController", bundle: nil)
            detailedVC.diariInfo = diaryDisplayList[indexPath.row]
            navigationController?.pushViewController(detailedVC, animated: true)
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        let isUserLogginIn = UserDefaults.standard.bool(forKey: "userLoggedIn")
        
        if(!isUserLogginIn){
            self.performSegue(withIdentifier: "loginView", sender: self);
        }else{
            let email = UserDefaults.standard.string(forKey: "userName")
            retriveDiary()
            
            setProfileImage()
        }
        
        
        
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        try! FIRAuth.auth()?.signOut()
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        UserDefaults.standard.synchronize()
        username.text = ""
        diaryDisplayList.removeAll()
        diaryViewTable.reloadData()
        friendDisplayList.removeAll()
        profilePhoto.image = UIImage(named: "profileImg")
        self.performSegue(withIdentifier: "loginView", sender: self)
        
    }
    // set up displayTableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =  UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        if(tableView == self.diaryViewTable){
            cell.textLabel!.text = diaryDisplayList[indexPath.row].date+" - "+diaryDisplayList[indexPath.row].title
            cell.detailTextLabel?.text = diaryDisplayList[indexPath.row].content
            let emotion = diaryDisplayList[indexPath.row].emotion
            if(emotion > 0 && emotion < 0.2){
                cell.imageView?.image = UIImage(named: "sad3.png")
            }else if(emotion < 0.35){
                cell.imageView?.image = UIImage(named: "sad2.png")
            }else if(emotion < 0.5){
                cell.imageView?.image = UIImage(named: "sad1.png")
            }else if(emotion < 0.6){
                cell.imageView?.image = UIImage(named: "normal.png")
            }else if(emotion < 0.75){
                cell.imageView?.image = UIImage(named: "happy1.png")
            }else if(emotion < 0.9){
                cell.imageView?.image = UIImage(named: "happy2.png")
            }else{
                cell.imageView?.image = UIImage(named: "happy3.png")
            }
        }
        
        return cell
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            return diaryDisplayList.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let diaryRef = FIRDatabase.database().reference(withPath: "diary")
            print("delete child key",diaryDisplayList[indexPath.row].key)
            diaryRef.child(diaryDisplayList[indexPath.row].mykey).removeValue { (error, ref) in
                if error != nil {
                    print("error while deleting")
                }
            }
            
            
            self.diaryDisplayList.remove(at: indexPath.row)
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0;//Choose your custom row height
    }
  


}



extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

