//
//  AddDiaryViewController.swift
//  wasocial
//
//  Created by 草我 on 2017/4/9.
//  Copyright © 2017年 陈逸山. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import FirebaseDatabase


class AddDiaryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    var refCourse = FIRDatabase.database().reference(withPath: "0/data")
    var refDiary = FIRDatabase.database().reference(withPath: "diary")
    var refRate = FIRDatabase.database().reference(withPath: "rate")
    var ref1: FIRDatabaseReference?
    var myIndicator = UIActivityIndicatorView()
    var databaseHandle:FIRDatabaseHandle?
    
    @IBOutlet weak var visibleLabel: UILabel!
    @IBOutlet weak var visibleSwitchButton: UISwitch!
    @IBOutlet weak var emotionScoreLabel: UILabel!
    @IBOutlet weak var sadnessView: DisplayView!
    @IBOutlet weak var neutralView: DisplayView!
    @IBOutlet weak var angerView: DisplayView!
    @IBOutlet weak var happinessView: DisplayView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var surpriseView: DisplayView!
    @IBOutlet weak var fearView: DisplayView!
    @IBOutlet weak var contentText: UITextView!
    
    var sentimentScore:Double = -1.0
    var keyword:String = "not--set"
    var imageEmotionScore = -1.0
    var totalEmotionScore = -1.0
    
    @IBOutlet weak var imageView: UIImageView!
    var user: User!
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref1 = FIRDatabase.database().reference()
        sadnessView.color = UIColor.blue
        neutralView.color = UIColor.brown
        angerView.color = UIColor.red
        happinessView.color = UIColor.yellow
        surpriseView.color = UIColor.cyan
        fearView.color = UIColor.black
        let tapgesture = UITapGestureRecognizer(target: self,action:"ImageTapped")
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapgesture)

        let defaults = UserDefaults.standard
        let email = defaults.string(forKey: "userName")
        //user = User(realname: "0", grade: email!)

        self.hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.
        self.keyword = "not--set"
        self.sentimentScore = -1.0
        self.imageEmotionScore = -1.0
        self.totalEmotionScore = 0.0
    }
    
    func ImageTapped(){
        let myPicker = UIImagePickerController()
        myPicker.delegate = self
        myPicker.sourceType = .camera
        myPicker.allowsEditing = true
        present(myPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        sendImageRequest()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func submitButton(_ sender: Any) {

        if((titleText.text?.isEmpty)! || contentText.text.isEmpty){
            var myAlert = UIAlertController(title: "Alert", message: "All fields are required!", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            
            myAlert.addAction(okAction)
            self.present(myAlert, animated: true, completion: nil)
        } else {
            var myAlert = UIAlertController(title: "Success", message: "Add diary successfully!", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            
            myAlert.addAction(okAction)
            
            let title: String = titleText.text!
            let content: String = contentText.text!

            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateResult = formatter.string(from: date)

            let defaults = UserDefaults.standard
            let realname = defaults.string(forKey: "realname")
            let username = defaults.string(forKey: "userName")
            
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child(imageName)
            if let uploadData = UIImagePNGRepresentation(self.imageView.image!){
                storageRef.put(uploadData, metadata: nil, completion:
                    {(metadata, error) in
                        if error != nil{
                            print(error)
                            return
                        }
                        if let profileImgURL = metadata?.downloadURL()?.absoluteString{
                        
                            let diaryKey = NSUUID().uuidString
                            let diary = Diary(date:dateResult, title: title, user: username!, content: content,mykey: diaryKey, emotion: self.totalEmotionScore,  visible: self.visibleLabel.text!, imageURL: profileImgURL);
                            let diaryRef = self.refDiary.child(diaryKey)
                            diaryRef.setValue(diary.toAnyObject())
                            self.present(myAlert, animated: true, completion: nil)
                            self.navigationController?.popViewController(animated: true)
                        }
                })
            }
            

            


        }
        
    }
    
    @IBAction func visibleSwitch(_ sender: Any) {
        if(visibleSwitchButton.isOn){
            visibleLabel.text = "Public"
        }else{
            visibleLabel.text = "Private"
        }
    }
    
    
//    @IBAction func cameraButton(_ sender: Any) {
//        let picker = UIImagePickerController()
//        picker.delegate = self
//        picker.sourceType = .camera
//        present(picker, animated: true, completion: nil)
//    }

    @IBAction func saveButton(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(AddDiaryViewController.image(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "image has been saved to your photos." , preferredStyle: .alert
            )
            ac.addAction(UIAlertAction(title:"OK", style: .default, handler:nil))
            present(ac, animated:true, completion:nil)
        } else{
            let ac = UIAlertController(title:"Save error", message: error?.localizedDescription,preferredStyle: .alert)
            ac.addAction(UIAlertAction(title:"OK", style: .default, handler:nil))
            present(ac, animated:true, completion:nil)
        }
    }
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
//        sendImageRequest()
//        dismiss(animated: true, completion: nil)
//    }
    
    public func sendImageRequest() {
        let head: HTTPHeaders = [
            "Ocp-Apim-Subscription-Key": "58dd2b322d2b4d74a8be5555716a3bc8",
            "Content-Type": "application/octet-stream"
        ]
        
        let imageData = UIImageJPEGRepresentation(imageView.image!, 0.5)

        let request = Alamofire.upload(imageData!, to: "https://westus.api.cognitive.microsoft.com/emotion/v1.0/recognize", method: .post, headers: head)
        
        print("\(request)")
        
        request.responseJSON { (response) in
            if let JSON = response.result.value {
                let result = JSON as! [[String:Any]]
                if result.count < 1 {
                    let ac = UIAlertController(title: "Error!", message: "Emotion recoginition failed." , preferredStyle: .alert
                    )
                    ac.addAction(UIAlertAction(title:"OK", style: .default, handler:nil))
                    self.present(ac, animated:true, completion:nil)
                }else{
                    let scores = result[0]["scores"] as! [String:Any]
                    if scores.count < 1 {
                        let ac = UIAlertController(title: "Error!", message: "Emotion recoginition failed." , preferredStyle: .alert
                        )
                        ac.addAction(UIAlertAction(title:"OK", style: .default, handler:nil))
                        self.present(ac, animated:true, completion:nil)
                    }else{
                        print("scores: \(scores)")
                        //                print("anger: \(scores["anger"] as! Double)")
                        let anger = scores["anger"] as! Double
                        let fear = scores["fear"] as! Double
                        let surprise = scores["surprise"] as! Double
                        let happiness = scores["happiness"] as! Double
                        let neutral = scores["neutral"] as! Double
                        let sadness = scores["sadness"] as! Double
                        self.angerView.animateValue(to: CGFloat(anger))
                        self.fearView.animateValue(to: CGFloat(fear))
                        self.surpriseView.animateValue(to: CGFloat(surprise))
                        self.happinessView.animateValue(to: CGFloat(happiness))
                        self.neutralView.animateValue(to: CGFloat(neutral))
                        self.sadnessView.animateValue(to: CGFloat(sadness))
                        self.imageEmotionScore = max(happiness + 0.5*neutral - sadness - anger, 0)
                        if(self.sentimentScore < 0){
                            self.totalEmotionScore = (self.imageEmotionScore)
                            let resultString = String(format: "Emotion Score:   %.3f", self.totalEmotionScore)
                            self.emotionScoreLabel.text = resultString
                        }else{
                            self.totalEmotionScore = (self.imageEmotionScore+self.sentimentScore)/2.0
                            let resultString = String(format: "Emotion Score:   %.3f", self.totalEmotionScore)
                            self.emotionScoreLabel.text = resultString
                        }
                    }

                }

            }
        }
    }
    
    @IBAction func analyseButton(_ sender: Any){
        if(contentText.text==""){
            let ac = UIAlertController(title: "Fail!", message: "Content cannot be empty." , preferredStyle: .alert
            )
            ac.addAction(UIAlertAction(title:"OK", style: .default, handler:nil))
            self.present(ac, animated:true, completion:nil)
            return
        }
        activityIndicator()
        self.myIndicator.startAnimating()
        self.readKeyword()
        self.readSentiment()
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
            self.myIndicator.stopAnimating()
            self.myIndicator.hidesWhenStopped = true
            if self.sentimentScore < 0{
                let ac = UIAlertController(title: "Fail!", message: "Text analyse Failed.)" , preferredStyle: .alert
                )
                ac.addAction(UIAlertAction(title:"OK", style: .default, handler:nil))
                self.present(ac, animated:true, completion:nil)
            }else{
                let ac = UIAlertController(title: "Success!", message: "Text analyse succeed. \n [\(self.keyword)] : \(self.sentimentScore)" , preferredStyle: .alert
                )
                ac.addAction(UIAlertAction(title:"OK", style: .default, handler:nil))
                self.present(ac, animated:true, completion:nil)
            }
            if(self.imageEmotionScore < 0){
                self.totalEmotionScore = self.sentimentScore
                let result = String(format: "Emotion Score:   %.3f", self.totalEmotionScore)
                self.emotionScoreLabel.text = result
            }else{
                self.totalEmotionScore = (self.imageEmotionScore+self.sentimentScore)/2.0
                let result = String(format: "Emotion Score:   %.3f", self.totalEmotionScore)
                self.emotionScoreLabel.text = result
            }
            if(self.isValidCourseCode(testStr: self.keyword)){
                let formatCourseCode = self.keyword.substring(to: 3).uppercased()+" "+self.keyword.substring(from: 3)
                self.updateCourseRate(courseCodeObj: formatCourseCode, courseRate: self.sentimentScore)
            }
        }
    }
    
    func activityIndicator(){
        myIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        myIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        myIndicator.center = contentText.center
        myIndicator.backgroundColor = UIColor.white
        self.view.addSubview(myIndicator)
        myIndicator.bringSubview(toFront: self.view)
    }
    
    public func readKeyword(){
        var res:String = ""
        let head: HTTPHeaders = [
            "Ocp-Apim-Subscription-Key": "79988c1ac0c8451a83063b8bca9f98f4",
            "Content-Type": "application/json"
        ]
        
        let paraKey:[String:Any] = [
            "documents" : [[
                    "language": "en",
                    "id": "string",
                    "text": contentText.text as String
            ]]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: paraKey, options: []){
            
            let urltest:URL = URL(string: "https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/keyPhrases")!
            var request = URLRequest(url: urltest)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("79988c1ac0c8451a83063b8bca9f98f4", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request) {
                (data, response, error) in
                //                print(request)
                
                let json = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String:[[String:Any]]]
                if json.count < 1 {
                    let ac = UIAlertController(title: "Error!", message: "Emotion recoginition failed." , preferredStyle: .alert
                    )
                    ac.addAction(UIAlertAction(title:"OK", style: .default, handler:nil))
                    self.present(ac, animated:true, completion:nil)
                }else{
                    
                    
                    if (json["documents"]?.count)! < 1 {
                        let ac = UIAlertController(title: "Error!", message: "Emotion recoginition failed." , preferredStyle: .alert
                        )
                        ac.addAction(UIAlertAction(title:"OK", style: .default, handler:nil))
                        self.present(ac, animated:true, completion:nil)
                    }else{
                        let keyPhrase = json["documents"]?[0]["keyPhrases"].unsafelyUnwrapped as! [String]
                        print("Keyword: \(keyPhrase[0])")
                        self.keyword = keyPhrase[0]
                    }
                    
                }
                //                if error == nil,let usableData = data {
                //                    print(usableData) //JSONSerialization
                //                }
            }
            task.resume()
        }
    }
    
    public func readSentiment(){
        var res:Double = 0.0
        let head: HTTPHeaders = [
            "Ocp-Apim-Subscription-Key": "79988c1ac0c8451a83063b8bca9f98f4",
            "Content-Type": "application/json"
        ]
        
        let paraKey:[String:Any] = [
            "documents" : [[
                "language": "en",
                "id": "string",
                "text": contentText.text as String
                ]]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: paraKey, options: []){
            let urltest:URL = URL(string: "https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/sentiment")!
            var request = URLRequest(url: urltest)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("79988c1ac0c8451a83063b8bca9f98f4", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request) {
                (data, response, error) in
                //                print(request)
                
                let json = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String:[[String:Any]]]
                if json.count < 1 {
                    let ac = UIAlertController(title: "Error!", message: "Emotion recoginition failed." , preferredStyle: .alert
                    )
                    ac.addAction(UIAlertAction(title:"OK", style: .default, handler:nil))
                    self.present(ac, animated:true, completion:nil)
                }else{
                    
                    
                    if (json["documents"]?.count)! < 1 {
                        let ac = UIAlertController(title: "Error!", message: "Emotion recoginition failed." , preferredStyle: .alert
                        )
                        ac.addAction(UIAlertAction(title:"OK", style: .default, handler:nil))
                        self.present(ac, animated:true, completion:nil)
                    }else{
                        let score = json["documents"]?[0]["score"].unsafelyUnwrapped as! Double
                        print("score: \(score)")
                        self.sentimentScore = score
                    }
                    
                }
            }
            task.resume()
        }
    }
    
    func isValidCourseCode(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z]{3}[0-9]{3}[A-Z]{0,1}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        print("test str: \(testStr)")
        return emailTest.evaluate(with: testStr)
    }
    
    func updateCourseRate(courseCodeObj:String, courseRate:Double){
        var countValue:Double = 0.0
        var totalValue:Double = 0.0
        var courseName:String = ""
        var courseCode:String = ""
        var childSnapKey:String = "not found"
        refCourse.observe(.value, with: { snapshot in
            for child in snapshot.children {
                let childsnap = child as! FIRDataSnapshot
                if let snapshotValue = childsnap.value as? NSDictionary, let snapVal = snapshotValue["code"] as? String {
                    if snapVal.range(of:courseCodeObj) != nil{
                        countValue = snapshotValue["count"] as! Double
                        totalValue = snapshotValue["total"] as! Double
                        courseName = snapshotValue["course"] as! String
                        courseCode = snapshotValue["code"] as! String
                        countValue = countValue + 1
                        totalValue = totalValue + self.sentimentScore
                        childSnapKey = childsnap.key
                        print("key==>",childsnap.key)
                        self.refCourse.removeAllObservers()
                        self.refCourse.child(childSnapKey).setValue(["code":courseCode,"course":courseName,"count":countValue,"total":totalValue,"average":totalValue/countValue])
                        self.refRate.childByAutoId().setValue(["courseCode": courseCode,
                            "user": UserDefaults.standard.string(forKey: "userName"),
                            "rate": courseRate, "comment": self.contentText.text])
                        break
                    }
                }
            }
        })
    }
    
    
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}
