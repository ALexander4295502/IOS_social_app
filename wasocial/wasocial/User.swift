//
//  User.swift
//  wasocial
//
//  Created by 陈逸山 on 4/15/17.
//  Copyright © 2017 陈逸山. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct User {
    let key: String
    let realname: String
    let grade: String
    let profileImgURL: String
    let email: String
  
    let ref: FIRDatabaseReference?
    
    init(realname: String, grade: String, email:String, profileImgURL: String, key:String = "",friend:[String]=[]){
        self.key = key
        self.realname = realname
        self.grade = grade
        self.email = email
        self.profileImgURL = profileImgURL
        
        self.ref = nil
        
    }
    
    init(snapshot: FIRDataSnapshot){
        key = snapshot.key
        let snapshotvalue = snapshot.value as! [String: AnyObject]
        realname = snapshotvalue["realname"] as! String
        grade = snapshotvalue["grade"] as! String
        email = snapshotvalue["email"] as! String
        profileImgURL = snapshotvalue["profileImgURL"] as! String
        
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any{
        return[
            "realname": realname,
            "grade": grade,
            "email": email,
            "profileImgURL":profileImgURL,
        ]
    }
}
