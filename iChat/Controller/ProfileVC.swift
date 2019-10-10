//
//  ProfileVC.swift
//  iChat
//
//  Created by zeyad on 10/5/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit

class ProfileVC: UITableViewController {

    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var blockBtn: UIButton!
    var user: FUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.tableFooterView = UIView()
    }
    
    
    //MARK: IBACTIONS
    
    @IBAction func callBtnPressed(_ sender: Any) {
    }
    
    @IBAction func messageBtnPressed(_ sender: Any) {
    }
    @IBAction func blockBtnPressed(_ sender: Any) {
        
        var blockedUsers = FUser.currentUser()?.blockedUsers
        
        if (blockedUsers!.contains(user!.userId)){
            
            blockedUsers!.remove(at: (blockedUsers?.firstIndex(of: user!.userId))!)
            
        }else{
            blockedUsers!.append(user!.userId)
        }
        
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID:blockedUsers!]) { (error) in
            if error != nil {
                print(error!.localizedDescription + "check blockBtnPressed")
            }else{
                self.updateBlockStatus()
            }
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else{
            return 30
        }
    }
    //MARK: setup UI
    
  
    func setupUI(){
        if user != nil {
            fullNameLbl.text = user!.fullname
            phoneNumberLbl.text = user!.phoneNumber
            imageFromData(pictureData: user!.avatar) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImg.image = avatarImage?.circleMasked
                }
            }
            updateBlockStatus()
            
        }
    }
    
    func updateBlockStatus(){
        if user?.userId != FUser.currentId() {
            callBtn.isHidden = false
            messageBtn.isHidden = false
            blockBtn.isHidden = false
        }else{
            callBtn.isHidden = true
            messageBtn.isHidden = true
            blockBtn.isHidden = true
        }
        if (FUser.currentUser()?.blockedUsers.contains(user!.userId))!{
            blockBtn.setTitle("UnBlock User", for: .normal)
        }else{
            blockBtn.setTitle("Block User", for: .normal)
        }
        
    }
    
    

}
