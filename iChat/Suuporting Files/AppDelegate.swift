//
//  AppDelegate.swift
//  iChat
//
//  Created by zeyad on 9/30/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit
import Firebase
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
     var window: UIWindow?
    
     var authListener: AuthStateDidChangeListenerHandle?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        //Auto login
        authListener = Auth.auth().addStateDidChangeListener({ (auth, user) in
            Auth.auth().removeStateDidChangeListener(self.authListener!)
            
            if user != nil {
                if UserDefaults.standard.object(forKey: kCURRENTUSER) != nil {
                    DispatchQueue.main.async {
                        self.gotoApp()
                    }
                    
                }
            }
            
            
            
        })
        
        return true
    }
    
    
       func gotoApp(){
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
           if #available(iOS 13.0, *) {
               let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "AppHome") as! UITabBarController
            self.window?.rootViewController = mainView
           } else {
               // Fallback on earlier versions
           }
       }
    
}

