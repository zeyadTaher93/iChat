//
//  WelcomeVC.swift
//  iChat
//
//  Created by zeyad on 9/30/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit
import ProgressHUD

class WelcomeVC: UIViewController {

    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var repeatPasswordTxtField: UITextField!
    
     override func viewDidLoad() {
         super.viewDidLoad()
     }
    
    
     
     //MARK: IBActions
     
     @IBAction func loginBtnPressed(_ sender: Any){
         dismissKeyboard()
        if emailTxtField.text != "" && passwordTxtField.text != "" {
            ProgressHUD.show("Logging...")
            loginUser()
        }else{
            ProgressHUD.showError("Email and Password are required!")
        }
     }
    
    
     @IBAction func registerBtnPressed(_ sender: Any){
         dismissKeyboard()
        if emailTxtField.text != "" && passwordTxtField.text != "" && repeatPasswordTxtField.text != ""{
            
            if passwordTxtField.text == repeatPasswordTxtField.text && passwordTxtField.text!.count >= 6 {
                registerUser()
            }else {
                passwordTxtField.text!.count >= 6 ? ProgressHUD.showError("Password Fields are not matched!") : ProgressHUD.showError("Password is at least 6 character!")
                
            }
            
        }else{
            ProgressHUD.showError("ALl fields are required!")
        }
     }
    
    
     @IBAction func backGroundTapped(_ sender: Any){
         dismissKeyboard()
     }
    
    
    
    
    
    

    //MARK: Helper Func
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func clearTextField()  {
        emailTxtField.text = ""
        passwordTxtField.text = ""
        repeatPasswordTxtField.text = ""
    }
    
    
    //MARK: Auth func
    
    func loginUser() {
        FUser.loginUserWith(email: emailTxtField.text!, password: passwordTxtField.text!) { (error) in
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            self.gotoApp()
        }
    }
    
    func registerUser(){
        performSegue(withIdentifier: "ToFinishRegistrationVC", sender: self)
        clearTextField()
        dismissKeyboard()
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToFinishRegistrationVC" {
            let vc = segue.destination as! FinishRegisterVC
            vc.email = emailTxtField.text!
            vc.password = passwordTxtField.text!
        }
        
    }
    
    func gotoApp(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
        dismissKeyboard()
        ProgressHUD.dismiss()
        clearTextField()
        
            let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AppHome") as! UITabBarController
//            self.present(mainView, animated: true, completion: nil)
        self.navigationController?.pushViewController(mainView, animated: true)
        
    }
    
}
