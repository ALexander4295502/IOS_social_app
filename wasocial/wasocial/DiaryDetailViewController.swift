//
//  DiaryDetailViewController.swift
//  wasocial
//
//  Created by 草我 on 2017/4/21.
//  Copyright © 2017年 陈逸山. All rights reserved.
//

import UIKit

class DiaryDetailViewController: UIViewController {

    
    @IBOutlet weak var titleLabel: UITextView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var emotionLabel: UILabel!
    @IBOutlet weak var diaryImage: UIImageView!
    @IBOutlet weak var contentLabel: UITextView!
    
    var diariInfo:Diary?
    var myIndicator = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        diaryImage.transform = diaryImage.transform.rotated(by: CGFloat(M_PI_2))
        titleLabel.text = diariInfo?.title
        userLabel.text = diariInfo?.user
        contentLabel.text = diariInfo?.content
        let resultString = String(format: "Emotion Score:   %.3f", (diariInfo?.emotion)!)
        emotionLabel.text = resultString
        let imageURL = URL(string: (diariInfo?.imageURL)!)
        activityIndicator()
        self.myIndicator.startAnimating()
        URLSession.shared.dataTask(with: imageURL! as URL, completionHandler:{(data, response, error) in
            
            if error != nil{
                print(error!)
                return
            }
            DispatchQueue.main.sync(execute: {
                self.myIndicator.stopAnimating()
                self.myIndicator.hidesWhenStopped = true
                self.diaryImage.image = UIImage(data: data!)
                self.diaryImage.contentMode = .scaleAspectFill
            })
        }).resume()
        // Do any additional setup after loading the view.
    }
    
    
    func activityIndicator(){
        myIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        myIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        myIndicator.center = diaryImage.center
        myIndicator.backgroundColor = UIColor.white
        self.view.addSubview(myIndicator)
        myIndicator.bringSubview(toFront: self.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
