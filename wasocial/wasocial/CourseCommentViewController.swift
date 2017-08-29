//
//  CourseCommentViewController.swift
//  wasocial
//
//  Created by 陆倚颖 on 4/21/17.
//  Copyright © 2017 陈逸山. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class CourseCommentViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var courseCode: UILabel!
    var refCourse = FIRDatabase.database().reference(withPath: "0/data")
   
    @IBOutlet weak var courseName: UITextView!
    @IBOutlet weak var avgScoreLabel: UILabel!
    
    @IBOutlet weak var commentTableView: UITableView!
    var courseNameLabel: String?
    var courseCodeLabel: String?
    var rateLabel: Double?
    
    var rateRef: FIRDatabaseReference!
    var commentList: [String]=[]
    var rateList: [Double]=[]
    
    override func viewWillAppear(_ animated: Bool) {
        commentTableView.dataSource = self
        commentTableView.delegate = self
        courseName.text = courseNameLabel
        courseCode.text = courseCodeLabel
        //        rate.text = String(describing: rateLabel)
        retriveComment()
        avgScoreLabel.text = String(format: "Rate Score:    %.3f", rateLabel!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTableView.dataSource = self
        commentTableView.delegate = self
        courseName.text = courseNameLabel
        courseCode.text = courseCodeLabel
//        rate.text = String(describing: rateLabel)
        retriveComment()
        avgScoreLabel.text = String(format: "Rate Score:    %.3f", rateLabel!)
        getCourseRate()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func retriveComment(){
        let rateRef = FIRDatabase.database().reference(withPath: "rate")
        rateRef.observe(.value, with: { snapshot in
            self.commentList.removeAll()
            self.rateList.removeAll()
            self.getCourseRate()
            for child in snapshot.children {
                let childsnap = child as! FIRDataSnapshot
                if let snapshotValue = childsnap.value as? NSDictionary, let snapVal = snapshotValue["courseCode"] as? String {
                    if(snapVal == self.courseCodeLabel){
                    self.commentList.append((snapshotValue["comment"] as? String)!)
                    self.rateList.append((snapshotValue["rate"] as? Double)!)
                    
                    }
                    
                }
            }
            self.commentTableView.reloadData()
            })
    }
    // set up displayTableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell =  UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        if(tableView == self.commentTableView){
            if(rateList[indexPath.row] < 0.5){
                cell.imageView?.image = UIImage(named: "thumbDown.png")
            }else{
                cell.imageView?.image = UIImage(named: "thumbUp.png")
            }
            cell.textLabel!.text = commentList[indexPath.row]
            let resultString = String(format: "Rate Score:    %.3f", rateList[indexPath.row])
            cell.detailTextLabel!.text = resultString
            
        }
        
        return cell
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.commentTableView){
            return commentList.count
        }
        else{
            return 1
        }
        
    }
    
    func getCourseRate(){
        refCourse.observe(.value, with: { snapshot in
            for child in snapshot.children {
                let childsnap = child as! FIRDataSnapshot
                if let snapshotValue = childsnap.value as? NSDictionary, let snapVal = snapshotValue["code"] as? String {
                    if snapVal.range(of:self.courseCodeLabel!) != nil{
                        print("key==>",childsnap.key)
                        self.avgScoreLabel.text = String(format: "Rate Score:    %.3f", snapshotValue["average"] as! Double!)
                        self.refCourse.removeAllObservers()
                        break
                    }
                }
            }
        })
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
