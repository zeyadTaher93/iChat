//
//  ChatVC.swift
//  iChat
//
//  Created by zeyad on 10/4/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ChatVC: UIViewController , UITableViewDelegate , UITableViewDataSource , RecentChatCellDelegate, UISearchResultsUpdating {
   
    var recentChat : [NSDictionary] = []
    var filteredREcent: [NSDictionary] = []
    var recentListener: ListenerRegistration!
    
   
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let searchBar = UISearchController(searchResultsController: nil)
    override func viewWillAppear(_ animated: Bool) {
        loadRecent()
        tableView.tableFooterView = UIView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchBar
        navigationItem.hidesSearchBarWhenScrolling = true
        searchBar.searchResultsUpdater  = self
        //searchBar.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        setTableViewWithHeader()
    }
  
    
    @IBAction func createChatBtnPressed(_ sender: Any) {
        let usersVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UsersVC") as! UsersTableView
        self.navigationController?.pushViewController(usersVC, animated: true)
        
        
    }
    
    //MARK: TableView Data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.isActive && searchBar.searchBar.text != "" {
            return filteredREcent.count
        }else {
            return recentChat.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "RecentChatCell", for: indexPath) as! RecentChatCell
        cell.delegate = self
        var recentDic: NSDictionary!
        if searchBar.isActive && searchBar.searchBar.text != "" {
            recentDic = filteredREcent[indexPath.row]
              }else {
                  recentDic = recentChat[indexPath.row]
              }
        
        
        cell.configureCell(recentItem: recentDic, indexpath: indexPath)
        
        return cell
    }
    
    //MARK: Tableview Delegate
      
      func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
          return true
      }
      
      func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
          var tempRecent: NSDictionary!
                  
                  if searchBar.isActive && searchBar.searchBar.text != "" {
                      tempRecent = filteredREcent[indexPath.row]
                  }else {
                      tempRecent = recentChat[indexPath.row]
                  }
        
        var mute = false
        var muteTitle = "UnMute"

        if (tempRecent[kMEMBERSTOPUSH] as! [String]).contains(FUser.currentId()) {
             mute = true
             muteTitle = "Mute"
        }
        
        let deletationAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexpath) in
            self.recentChat.remove(at: indexpath.row)
            self.deleteRecent(recentChatDic: tempRecent)
            tableView.reloadData()
        }
        let muteAction = UITableViewRowAction(style: .default, title: muteTitle) { (action, indexpath) in
            print("mute user at \(indexpath)")
        }
        muteAction.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        return [muteAction , deletationAction]
      }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            var recent: NSDictionary!
            
            if searchBar.isActive && searchBar.searchBar.text != "" {
                recent = filteredREcent[indexPath.row]
            }else {
                recent = recentChat[indexPath.row]
            }
        
        restartRecentChat(recentChat: recent)
        let chattingVC = ChattingVC()
        chattingVC.hidesBottomBarWhenPushed = true
        //chattingVC.title = (recent[kWITHUSERFULLNAME] as! String)
        chattingVC.chatRoomID = (recent[kCHATROOMID] as! String)
        chattingVC.membersID = (recent[kMEMBERS] as! [String])
        chattingVC.membetsToPush = (recent[kMEMBERSTOPUSH] as! [String])
        chattingVC.isGroup = (recent[kTYPE] as! String) == kGROUP
        self.navigationController?.pushViewController(chattingVC, animated: true)
        
    }

    //load recent chat
    
    func loadRecent(){
        
        recentListener = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snpshot, error) in
            guard let snapshot = snpshot else {return}
            self.recentChat = []
            
            let sorted = (dictionaryFromSnapshots(snapshots: snapshot.documents) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)] ) as! [NSDictionary]
            
            for recent in sorted {
                if recent[kLASTMESSAGE] as! String != "" && recent[kRECENTID] != nil && recent[kCHATROOMID] != nil {
                    self.recentChat.append(recent)
                    
                }
            }
            
            
        self.tableView.reloadData()
            
        })
        
        
        
        
    }
    
    func setTableViewWithHeader(){
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 45))
        let buttonView = UIView(frame: CGRect(x: 0, y: 5, width: tableView.frame.size.width, height: 35))
        let button = UIButton(frame: CGRect(x:  tableView.frame.size.width - 135, y: 10, width: 100, height: 20))
        button.addTarget(self, action: #selector(groupBtnPressed), for: .touchUpInside)
        button.setTitle("New group", for: .normal)
        let titleColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        button.setTitleColor(titleColor, for: .normal)
        button.contentMode = .scaleAspectFit
        buttonView.addSubview(button)
        headerView.addSubview(buttonView)
       
        tableView.tableHeaderView = headerView
        
    }
    
    @objc func groupBtnPressed() {
        print("hello")
    }
    //MARK: recent chat delegate
    
    func avatarImageTapped(indexpath: IndexPath) {
       var recentDic: NSDictionary!
        
        if searchBar.isActive && searchBar.searchBar.text != "" {
            recentDic = filteredREcent[indexpath.row]
              }else {
                  recentDic = recentChat[indexpath.row]
              }
        
        if recentDic[kTYPE] as! String == kPRIVATE {
            reference(.User).document(recentDic[kWITHUSERUSERID] as! String).getDocument { (snapshot, error) in
                guard let snapshot = snapshot else {return}
                if snapshot.exists {
                    let userDict = snapshot.data()! as NSDictionary
                    let tempFUser = FUser(_dictionary: userDict)
                    self.showProfileUser(user: tempFUser)
                }
                
                
            }
        }
        
        
       }
    
    func showProfileUser(user: FUser) {
        let profile = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ToProfileVC") as? ProfileVC
        self.navigationController?.pushViewController(profile!, animated: true)
    }
    
    //MARK: search result
    
    func filterResultsfor(searchText: String , scope: String = "All"){
           filteredREcent = recentChat.filter({ (recent) -> Bool in
            return (recent[kWITHUSERFULLNAME] as! String).lowercased().contains(searchText.lowercased())
           })
           
           tableView.reloadData()
       }
       
       func updateSearchResults(for searchController: UISearchController) {
        filterResultsfor(searchText: searchController.searchBar.text!)
       }
    
    //Delete Function
    
    func deleteRecent(recentChatDic: NSDictionary){
        if let recentChatId = recentChatDic[kRECENTID] as? String {
            reference(.Recent).document(recentChatId).delete()
        }
    }
    
    //restart recent Chat
    
    func restartRecentChat(recentChat: NSDictionary){
        if recentChat[kTYPE] as! String == kPRIVATE {
            
            createRecent(members: recentChat[kMEMBERSTOPUSH] as! [String], chatRoomID: recentChat[kCHATROOMID]as! String, withUserUserName: FUser.currentUser()!.firstname, type: kPRIVATE, users: [FUser.currentUser()!], groupAvatar: nil)
            
            
        }else {
            createRecent(members: recentChat[kMEMBERSTOPUSH] as! [String], chatRoomID: recentChat[kCHATROOMID]as! String, withUserUserName: recentChat[kWITHUSERFULLNAME]as! String, type: kGROUP, users: nil, groupAvatar: recentChat[kAVATAR] as? String)
        }
        
        
    }
}
