//
//  courseRate.swift
//  wasocial
//
//  Created by 草我 on 2017/4/21.
//  Copyright © 2017年 陈逸山. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct courseRate{
    let key: String
    let user: String
    let courseCode: String
    let rate: Double
    let comment: String
    let ref: FIRDatabaseReference?
    
    init(courseCode: String,rate: Double, user: String,key: String = "", comment:String){
        self.key = key
        self.courseCode = courseCode
        self.rate = rate
        self.user = user
        self.comment = comment
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot){
        key = snapshot.key
        let snapshotvalue = snapshot.value as! [String: AnyObject]
        courseCode = snapshotvalue["courseCode"] as! String
        rate = snapshotvalue["rate"] as! Double
        user = snapshotvalue["user"] as! String
        comment = snapshotvalue["comment"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any{
        return[
            "courseCode": courseCode,
            "user": user,
            "rate": rate,
            "comment": comment
        ]
    }
    
}
