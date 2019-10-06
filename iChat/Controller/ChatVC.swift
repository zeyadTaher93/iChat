//
//  ChatVC.swift
//  iChat
//
//  Created by zeyad on 10/4/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit

class ChatVC: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    @IBAction func createChatBtnPressed(_ sender: Any) {
        let usersVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UsersVC") as! UsersTableView
        self.navigationController?.pushViewController(usersVC, animated: true)
        
        
    }

    

}
