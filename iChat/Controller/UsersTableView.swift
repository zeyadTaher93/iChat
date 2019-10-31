//
//  UsersTableView.swift
//  iChat
//
//  Created by zeyad on 10/4/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
class UsersTableView: UITableViewController , UISearchResultsUpdating , UserCellDelegate{


    @IBOutlet weak var segmentView: UISegmentedControl!
    @IBOutlet weak var hedearView: UIView!
    
    var allUsers:[FUser] = []
    var filteredUsers:[FUser] = []
    var allusersGrouped = NSDictionary() as! [String : [FUser]]
    var sectionTitleList:[String] = []
    
    let searchBar = UISearchController(searchResultsController: nil)
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUsers(filter: kCITY)
        self.title = "Users"
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        navigationItem.searchController = searchBar
        searchBar.searchResultsUpdater  = self
        searchBar.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchBar.isActive && searchBar.searchBar.text != "" {
            return 1
        }else{
            return allusersGrouped.count
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.isActive && searchBar.searchBar.text != "" {
            return filteredUsers.count
        }else{
            
            let sectionTitle = self.sectionTitleList[section]
            let users = self.allusersGrouped[sectionTitle]
            
            return users!.count
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        var user: FUser
        
        
        
        if searchBar.isActive && searchBar.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        }else{
            
            let sectionTitle = self.sectionTitleList[indexPath.section]
            user = self.allusersGrouped[sectionTitle]![indexPath.row]
        }
            
        cell.configureCell(fuser:user, index: indexPath)
        cell.delegate = self
        return cell
    }
    func avatarImageTapped(indexpath: IndexPath) {
           let view = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ToProfileVC") as! ProfileVC
           if searchBar.isActive && searchBar.searchBar.text != "" {
               view.user = filteredUsers[indexpath.row]
           
              }else{
               
               let sectionTitle = sectionTitleList[indexpath.section]
               let users = allusersGrouped[sectionTitle]
               view.user = users![indexpath.row]
               
              }
           
           self.navigationController?.pushViewController(view, animated: true)
           
       }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchBar.isActive && searchBar.searchBar.text != "" {
           return ""
        }else{
            
           return sectionTitleList[section]
        }
    }
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchBar.isActive && searchBar.searchBar.text != "" {
                  return nil
            
               }else{
                   
                  return sectionTitleList
               }
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var user: FUser
        
        if searchBar.isActive && searchBar.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        }else{
            
            let sectionTitle = self.sectionTitleList[indexPath.section]
            user = self.allusersGrouped[sectionTitle]![indexPath.row]
        }
        
        let chattingVC = ChattingVC()
        chattingVC.hidesBottomBarWhenPushed = true
        //chattingVC.title = user.fullname
        chattingVC.membersID =  [FUser.currentId(), user.userId]
        chattingVC.membetsToPush = [FUser.currentId(), user.userId]
        chattingVC.chatRoomID = createPrivateChat(user1: FUser.currentUser()!, user2: user)
        chattingVC.isGroup = false
        self.navigationController?.pushViewController(chattingVC, animated: true)
        
    }
    
    
    
    @IBAction func segmentControllerpressed(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            loadUsers(filter: kCITY)
            
            
        case 1:
            loadUsers(filter: kCOUNTRY)
           
        case 2:
            loadUsers(filter: "")
           

        default: break
            
        }
        
    }
    
    
    //load users
    
    func loadUsers(filter: String){
        ProgressHUD.show()
        
        
        let quary:Query
        
        switch filter {
        case kCITY:
            quary = reference(.User).whereField(kCITY, isEqualTo: FUser.currentUser()!.city).order(by: kFIRSTNAME, descending: false)
        case kCOUNTRY:
            quary = reference(.User).whereField(kCOUNTRY, isEqualTo: FUser.currentUser()!.country).order(by: kFIRSTNAME, descending: false)
        default:
            quary = reference(.User).order(by: kFIRSTNAME, descending: false)
        }
        
        
        quary.getDocuments { (snapshot, error) in
            
            self.allUsers = []
            self.allusersGrouped = [:]
            self.sectionTitleList = []
            
            if error != nil {
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
                self.tableView.reloadData()
                return
            }
            guard let snapshot = snapshot else{
                ProgressHUD.dismiss()
                return
            }
            
            if !snapshot.isEmpty {
                
                for userDic in snapshot.documents {
                    let userDict = userDic.data() as NSDictionary
                    let fuser = FUser(_dictionary: userDict)
                    if fuser.userId != FUser.currentId() {
                        self.allUsers.append(fuser)
                        print(self.allUsers)
                    }
                    
                }
                self.splitUsersintoSections()
                self.tableView.reloadData()
            }
            
            self.tableView.reloadData()
            ProgressHUD.dismiss()
        }
        
       
        
    }
   
    
    //MARK: search result
    
    func filterResultsfor(searchText: String , scope: String = "All"){
        filteredUsers = allUsers.filter({ (user) -> Bool in
            return user.firstname.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterResultsfor(searchText: searchController.searchBar.text!)
    }
    
    fileprivate func splitUsersintoSections(){
        
        var sectionTitle = ""
        
        for i in 0..<self.allUsers.count {
            let currentUser = allUsers[i]
            let firstChar = "\(currentUser.firstname.first!)"
            
            if firstChar != sectionTitle {
                sectionTitle = firstChar
                
                self.allusersGrouped[sectionTitle] = []
                sectionTitleList.append(sectionTitle)
                
            }
            
            self.allusersGrouped[sectionTitle]?.append(currentUser)
            
        }
        
        
        
    }
    

}
