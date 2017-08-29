//
//  SelectCourseViewController.swift
//  wasocial
//
//  Created by 陆倚颖 on 4/15/17.
//  Copyright © 2017 陈逸山. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
class SelectCourseViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate{
    var ref: FIRDatabaseReference!
    
    

    @IBOutlet weak var displayTableView: UITableView!
    @IBOutlet weak var selectedTableView: UITableView!
    var displayList: [String]=[]
    var topCourses: [CourseInfo] = []
    var courseCodeList: [String] = []
    var averageList: [Double] = []
    
    @IBOutlet weak var addCourseText: UITextField!
    
    func getTopFiveCourse(){
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference(withPath: "0/data")
        let query = ref.queryOrdered(byChild: "average").queryLimited(toLast: 5)
        query.observe(.value, with: {snapshot in
            var courses : [CourseInfo] = []
            for child in snapshot.children{
                //let childsnap = child as! FIRDataSnapshot
                let course = CourseInfo(snapshot: child as! FIRDataSnapshot)
                courses.append(course)
            }
            self.topCourses = courses
            self.selectedTableView.reloadData()
        })
    }

    
    @IBOutlet weak var searchBar: UISearchBar!
    var searchActivated: Bool = false
    override func viewDidLoad() {
        
        super.viewDidLoad()
        selectedTableView.dataSource = self
        selectedTableView.delegate = self
        displayTableView.dataSource = self
        displayTableView.delegate = self
        fetchDataForTableView()
        getTopFiveCourse()
        self.hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getTopFiveCourse()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func fetchDataForTableView() {

        let ref = FIRDatabase.database().reference(withPath: "0/data")
        
        ref.observe(.value, with: { snapshot in
            self.displayList.removeAll()
            self.courseCodeList.removeAll()
            self.averageList.removeAll()
            for child in snapshot.children {
                let childsnap = child as! FIRDataSnapshot
                if let snapshotValue = childsnap.value as? NSDictionary, let snapVal = snapshotValue["course"] as? String {
                    self.displayList.append(snapVal)
                    self.courseCodeList.append((snapshotValue["code"] as? String)!)
                    self.averageList.append((snapshotValue["average"] as? Double)!)
                    
                }
            }
            let searchContent = self.searchBar.text!
            
            if(!searchContent.isEmpty){
                var searchList: [String]=[]
                var searchCourseCode: [String]=[]
                var searchRate: [Double]=[]
                for course in self.displayList{
                    
                    if(course.lowercased().range(of:searchContent.lowercased()) != nil){
                        let index = self.displayList.index(of: course)!
                        searchList.append(course)
                        searchCourseCode.append(self.courseCodeList[index])
                        searchRate.append(self.averageList[index])
                    }
                    
                }
                self.displayList = searchList
                self.courseCodeList = searchCourseCode
                self.averageList = searchRate
            }
            self.getTopFiveCourse()
            self.displayTableView.reloadData()
        })
        
    }

    //search bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActivated = true
        
        
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActivated = true
        self.fetchDataForTableView()
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActivated = false
       
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActivated = true
        
        let searchContent = searchBar.text!
        if (!searchContent.isEmpty && searchActivated == true){
            DispatchQueue.global(qos: .userInitiated).async {
                self.displayList.removeAll()
                self.fetchDataForTableView()
                DispatchQueue.main.async {
                    self.displayTableView.reloadData()
                }
            }
        }
    }

    // set up displayTableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =  UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        if(tableView == self.displayTableView){
            cell.textLabel!.text = displayList[indexPath.row]
            cell.detailTextLabel!.text = courseCodeList[indexPath.row]
        }
        else if(tableView == self.selectedTableView){
            cell.textLabel!.text = topCourses[indexPath.row].course
            cell.detailTextLabel!.text = topCourses[indexPath.row].code
            
        }
        return cell
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.displayTableView){
            return displayList.count
        }
        else{
            return topCourses.count
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == self.displayTableView){
        
            let detailedVC = CourseCommentViewController(nibName: "CourseCommentViewController", bundle: nil)
            //print("course", displayList[indexPath.row])
            detailedVC.courseNameLabel = displayList[indexPath.row]
            detailedVC.courseCodeLabel = courseCodeList[indexPath.row]
            detailedVC.rateLabel = averageList[indexPath.row]
            navigationController?.pushViewController(detailedVC, animated: true)
        }
        else if(tableView == self.selectedTableView){
            
            let detailedVC = CourseCommentViewController(nibName: "CourseCommentViewController", bundle: nil)
            //print("course", displayList[indexPath.row])
            detailedVC.courseNameLabel = topCourses[indexPath.row].course
            detailedVC.courseCodeLabel = topCourses[indexPath.row].code
            detailedVC.rateLabel = topCourses[indexPath.row].average
            navigationController?.pushViewController(detailedVC, animated: true)

        }
        
    }


}
