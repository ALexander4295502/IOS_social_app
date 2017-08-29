//
//  Diary.swift
//  wasocial
//
//  Created by 陈逸山 on 4/15/17.
//  Copyright © 2017 陈逸山. All rights reserved.
//

import Foundation
import FirebaseDatabase


struct Diary{
    let key: String
    let mykey: String
    let title: String
    let content:String
    let user: String
    let date: String
    let emotion: Double
    let imageURL: String
    let ref: FIRDatabaseReference?
    let visible: String
    
    init(date: String,title: String, user: String, content: String, key:String = "", mykey:String, emotion: Double, visible:String, imageURL: String){
        self.key = key
        self.title = title
        self.content = content
        self.user = user
        self.emotion = emotion
        self.date = date
        self.visible = visible
        self.imageURL = imageURL
        self.mykey = mykey
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot){
        key = snapshot.key
        let snapshotvalue = snapshot.value as! [String: AnyObject]
        title = snapshotvalue["title"] as! String
        content = snapshotvalue["content"] as! String
        user = snapshotvalue["user"] as! String
        emotion = snapshotvalue["emotion"] as! Double
        date = snapshotvalue["date"] as! String
        visible = snapshotvalue["visible"] as! String
        imageURL = snapshotvalue["imageURL"] as! String
        mykey = snapshotvalue["mykey"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return[
            "title": title,
            "content": content,
            "user" : user,
            "emotion" : emotion,
            "date": date,
            "visible": visible,
            "imageURL": imageURL,
            "mykey": mykey
        ]
    }
    
    
    
}
