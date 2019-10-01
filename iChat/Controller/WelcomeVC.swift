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
            
            if passwordTxtField.text == repeatPasswordTxtField.text {
                registerUser()
            }else {
                ProgressHUD.showError("Password Fields are not matched!")
            }
            
            
            
        }else{
            ProgressHUD.showError("The three fields are required!")
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
        dismissKeyboard()
        //ProgressHUD.dismiss()
        clearTextField()
        if #available(iOS 13.0, *) {
            let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "AppHome") as! UITabBarController
            self.present(mainView, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
}
