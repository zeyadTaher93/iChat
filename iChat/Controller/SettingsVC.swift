//
//  SettingsVC.swift
//  iChat
//
//  Created by zeyad on 10/2/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit

class SettingsVC: UITableViewController {

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true

    }
    
    
    //MARK: IBActions
    
    @IBAction func signoutBtnPressed(_ sender: Any){
        FUser.logOutCurrentUser { (success) in
            if success {
                self.gotoWelcomeView()
            }
        }
    }
    
    
    //MARK: Helper Func
    
    func gotoWelcomeView(){
        let welcomeView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WelcomeView") as! WelcomeVC
        present(welcomeView, animated: true, completion: nil)
    }
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

   

}
