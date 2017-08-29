//
//  course.swift
//  wasocial
//
//  Created by 陈逸山 on 4/16/17.
//  Copyright © 2017 陈逸山. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct CourseInfo {
    let course:String
    let code:String
    let key: String
    let count:Double
    let total:Double
    let average:Double
    let ref: FIRDatabaseReference?
    
    init(course: String,code: String, count: Double, total: Double, average: Double, key: String = ""){
        self.key = key
        self.course = course
        self.code = code
        self.count = count
        self.total = total
        self.average = average
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot){
        key = snapshot.key
        let snapshotvalue = snapshot.value as! [String: AnyObject]
        course = snapshotvalue["course"] as! String
        total = snapshotvalue["total"] as! Double
        count = snapshotvalue["count"] as! Double
        average = snapshotvalue["average"] as! Double
        code = snapshotvalue["code"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any{
        return[
            "course": course,
            "code": code,
            "average": average,
            "total": total,
            "count": count
        ]
    }
    
}
