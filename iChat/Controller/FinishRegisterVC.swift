//
//  FinishRegisterVC.swift
//  iChat
//
//  Created by zeyad on 10/1/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit
import ProgressHUD

class FinishRegisterVC: UIViewController {
    
    @IBOutlet weak var firtNameTxtField: UITextField!
    @IBOutlet weak var lastNameTxtField: UITextField!
    @IBOutlet weak var countryTxtField: UITextField!
    @IBOutlet weak var cityTxtField: UITextField!
    @IBOutlet weak var phoneNumberTxtField: UITextField!
    @IBOutlet weak var avaterImage: UIImageView!

    var email: String!
    var password: String!
    var avatarImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    //MARK: IBActions
    
    @IBAction func doneBtnPressed(_sender: Any){
        dismissKeyboard()
        if firtNameTxtField.text != "" && lastNameTxtField.text != "" && countryTxtField.text != "" && cityTxtField.text != "" && phoneNumberTxtField.text != "" {
            ProgressHUD.show("Registering...")
            FUser.registerUserWith(email: email, password: password, firstName:firtNameTxtField.text! , lastName: lastNameTxtField.text!) { (error) in
                if error != nil {
                    ProgressHUD.showError(error?.localizedDescription)
                    return
                }
                
                self.completeRegisterUser()
                }
            
        }else {
            ProgressHUD.showError("All fields are required!")
        }
    }
    
    
    
    @IBAction func cancelBtnPressed(_sender: Any){
        dismissKeyboard()
        clearTextField()
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Helper Func
    
    func completeRegisterUser(){
        let fullName = firtNameTxtField.text! + " " + lastNameTxtField.text!
        var tempDict:Dictionary = [
             kFIRSTNAME:firtNameTxtField.text! ,
             kLASTNAME: lastNameTxtField.text! ,
             kFULLNAME: fullName,
             kCOUNTRY: countryTxtField.text! ,
             kCITY: cityTxtField.text!,
             kPHONE: phoneNumberTxtField.text!
        ] as [String:Any]
        
        if avatarImage == nil {
            imageFromInitials(firstName: firtNameTxtField.text!, lastName: lastNameTxtField.text!) { (avatarImage) in
                
                let avatarJpeg = avatarImage.jpegData(compressionQuality: 0.7)
                let avatarData = avatarJpeg!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue:0))
                tempDict[kAVATAR] = avatarData
                
                self.finishRegistering(withValues: tempDict)
            }
        }else{
            let avatarJpeg = avatarImage!.jpegData(compressionQuality: 0.7)
            let avatarData = avatarJpeg!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue:0))
            tempDict[kAVATAR] = avatarData
            self.finishRegistering(withValues: tempDict)
        }
    }
    
    
    
    func finishRegistering(withValues: [String:Any]){
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    ProgressHUD.showError(error?.localizedDescription)
                }
                return
            }
           
            self.gotoApp()
            
            
        }
    }
    
    
    func gotoApp(){
        //ProgressHUD.dismiss()
        self.clearTextField()
        self.dismissKeyboard()
        if #available(iOS 13.0, *) {
            let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "AppHome") as! UITabBarController
            self.present(mainView, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    func clearTextField()  {
        firtNameTxtField.text = ""
        lastNameTxtField.text = ""
        countryTxtField.text = ""
        cityTxtField.text = ""
        phoneNumberTxtField.text = ""
    }
    


}
