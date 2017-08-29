//
//  UserListViewController.swift
//  wasocial
//
//  Created by 陆倚颖 on 4/21/17.
//  Copyright © 2017 陈逸山. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class UserListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    var friendDisplayList: [User]=[]
    var searchActivated: Bool = false
    let cellId = "cellId"



    
    @IBOutlet weak var userList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userList.dataSource = self
        userList.delegate = self
        userList.register(UserCell.self, forCellReuseIdentifier: cellId)

        retriveFriendList()
        hideKeyboardWhenTappedAround()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    // set up displayTableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        
        let cell =  tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = friendDisplayList[indexPath.row]
        cell.textLabel!.text = user.realname
        
        let profileImageUrl = user.profileImgURL
            let url = NSURL(string: profileImageUrl)
            URLSession.shared.dataTask(with: url! as URL, completionHandler:{(data, response, error) in
                
                if error != nil{
                    print(error!)
                    return
                }
                DispatchQueue.main.sync(execute: {
                    cell.profileimageView.image = UIImage(data: data!)
                })
                
            }).resume()

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
            print("friend",friendDisplayList)
            detailedVC.userIn = friendDisplayList[indexPath.row]
            navigationController?.pushViewController(detailedVC, animated: true)

    }
    
    
    func retriveFriendList(){
        let userRef = FIRDatabase.database().reference(withPath: "user")
        
        userRef.observe(.value, with: { snapshot in
            var friendsList : [User] = []
            //self.friendDisplayList.removeAll()
            for child in snapshot.children{
                let friend = User(snapshot: child as! FIRDataSnapshot)
                friendsList.append(friend)
                }
            self.friendDisplayList = friendsList
            self.userList.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60;//Choose your custom row height
    }
}
    
class UserCell: UITableViewCell {
    
    override func layoutSubviews(){
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 56,y: textLabel!.frame.origin.y, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        
    }
    
    let profileimageView: UIImageView = {
        let imageView = UIImageView()
       // imageView.image = UIImage(named: "profile")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileimageView)
        
        //ios9 constraint anchors
        profileimageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileimageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileimageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileimageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(code:) has not been implemented")
    }
}
    
    



