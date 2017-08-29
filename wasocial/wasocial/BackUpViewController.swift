//
//  BackUpViewController.swift
//  wasocial
//
//  Created by 陆倚颖 on 4/23/17.
//  Copyright © 2017 陈逸山. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class BackUpViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    var friendDisplayList: [User]=[]
    var searchActivated: Bool = false
    
    
    @IBOutlet weak var searchContent: UISearchBar!
    @IBOutlet weak var userList: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        userList.dataSource = self
        userList.delegate = self
        retriveFriendList()
        hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // set up displayTableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell =  UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.textLabel!.text = friendDisplayList[indexPath.row].realname
        
        return cell
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return friendDisplayList.count
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailedVC = FriendViewController(nibName: "FriendViewController", bundle: nil)
        
        detailedVC.userIn = friendDisplayList[indexPath.row]
        navigationController?.pushViewController(detailedVC, animated: true)
        
    }
    
    
    func retriveFriendList(){
        friendDisplayList.removeAll()
        let userRef = FIRDatabase.database().reference(withPath: "user")
        
        userRef.observe(.value, with: { snapshot in
            for child in snapshot.children {
                let childsnap = child as! FIRDataSnapshot
                if let snapshotValue = childsnap.value as? NSDictionary, let snapVal = snapshotValue["email"] as? String {
                    let userGet = User(realname:(snapshotValue["realname"] as? String)!, grade: (snapshotValue["grade"] as? String)!, email: (snapshotValue["email"] as? String)!, profileImgURL: (snapshotValue["profileImgURL"] as? String)!)
                    self.friendDisplayList.append(userGet)
                }
            }
            let searchContent = self.searchContent.text!
            
            if(!searchContent.isEmpty){
                var searchList: [User]=[]
                for user in self.friendDisplayList{
                    
                    if(user.realname.lowercased().range(of:searchContent.lowercased()) != nil){
                        searchList.append(user)
                    }
                    
                }
                self.friendDisplayList = searchList
            }
            
            self.userList.reloadData()
            
        })
        
        
    }
    
    //search bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActivated = true
        
        
        
        
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActivated = true
        self.retriveFriendList()
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActivated = false
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActivated = true
        
        let searchContent = searchBar.text!
        if (!searchContent.isEmpty && searchActivated == true){
            self.friendDisplayList.removeAll()
            self.retriveFriendList()
            
            
        }
        
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
