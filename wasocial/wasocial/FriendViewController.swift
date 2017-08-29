//
//  FriendViewController.swift
//  wasocial
//
//  Created by 陆倚颖 on 4/21/17.
//  Copyright © 2017 陈逸山. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class FriendViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var userIn : User?
    var diaryDisplayList : [Diary] = []

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    var myIndicator = UIActivityIndicatorView()
    @IBOutlet weak var diaryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let diaryRef = FIRDatabase.database().reference(withPath: "diary")
        name.text = userIn?.realname
        diaryTableView.dataSource = self
        diaryTableView.delegate = self
        // Do any additional setup after loading the view.
        setProfileImage(userName: (userIn?.email)!)
        diaryRef.observe(.value, with: { snapshot in
            self.diaryDisplayList.removeAll()
            for child in snapshot.children {
                let childsnap = child as! FIRDataSnapshot
                if let snapshotValue = childsnap.value as? NSDictionary, let snapVal = snapshotValue["user"] as? String {
                    print(self.userIn?.email," ==> ",snapVal)
                    if(snapVal == self.userIn?.email && snapshotValue["visible"] as? String == "Public" ){
                        
                        let diaryGet = Diary(date:(snapshotValue["date"] as? String)!, title: (snapshotValue["title"] as? String)!, user: (snapshotValue["user"] as? String)!, content: (snapshotValue["content"] as? String)!, mykey: (snapshotValue["mykey"] as? String)!,emotion: (snapshotValue["emotion"] as? Double)!, visible:(snapshotValue["visible"] as? String)!, imageURL: (snapshotValue["imageURL"] as? String)!)
                        self.diaryDisplayList.append(diaryGet)
                    }
                }
                
            }
            self.diaryTableView.reloadData()
        })
    }

    func setProfileImage(userName:String){
        let email = userName
        let userRef = FIRDatabase.database().reference(withPath: "user")
        userRef.observe(.value, with: {snapshot in
            for child in snapshot.children{
                let childsnap = child as! FIRDataSnapshot
                if let snapshotValue = childsnap.value as? NSDictionary, let snapVal = snapshotValue["email"] as? String {
                    if(snapVal == email){
                        if let profileImageUrl = snapshotValue["profileImgURL"] as? String {
                            let url = NSURL(string: profileImageUrl)
                            print("urll",url)
                            self.activityIndicator()
                            self.myIndicator.startAnimating()
                            URLSession.shared.dataTask(with: url! as URL, completionHandler:{(data, response, error) in
                                
                                if error != nil{
                                    print(error!)
                                    return
                                }
                                DispatchQueue.main.sync(execute: {
                                    self.myIndicator.stopAnimating()
                                    self.myIndicator.hidesWhenStopped = true
                                    print(data!)
                                    self.profileImage.image = UIImage(data: data!)
                                })
                            }).resume()
                        }
                    }
                }
            }
        })
    }
    
    func activityIndicator(){
        myIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        myIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        myIndicator.center = profileImage.center
        myIndicator.backgroundColor = UIColor.white
        self.view.addSubview(myIndicator)
        myIndicator.bringSubview(toFront: self.view)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // set up displayTableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =  UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        if(tableView == self.diaryTableView){
            cell.textLabel!.text = diaryDisplayList[indexPath.row].date+" - "+diaryDisplayList[indexPath.row].title
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == self.diaryTableView){
            
            let detailedVC = DiaryDetailViewController(nibName: "DiaryDetailViewController", bundle: nil)
            print("course", diaryDisplayList[indexPath.row])
            detailedVC.diariInfo = diaryDisplayList[indexPath.row]
            navigationController?.pushViewController(detailedVC, animated: true)
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            return diaryDisplayList.count
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0;//Choose your custom row height
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
