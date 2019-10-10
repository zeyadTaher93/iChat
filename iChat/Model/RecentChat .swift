//
//  RecentChat .swift
//  iChat
//
//  Created by zeyad on 10/7/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import Foundation

func createPrivateChat(user1: FUser , user2: FUser) -> String{
    let userID1 = user1.userId
    let userID2 = user2.userId

    var roomID = ""
    let value =  userID1.compare(userID2).rawValue
    if value < 0 {
        roomID = userID1 + userID2
    }else{
        roomID = userID2 + userID1
    }
    let members = [userID1 , userID2]
    
    
    createRecent(members: members, chatRoomID: roomID, withUserUserName: "", type: kPRIVATE, users: [user1 , user2], groupAvatar: nil)
    
    return roomID
}

func createRecent(members: [String] , chatRoomID: String , withUserUserName: String , type: String ,  users: [FUser]? , groupAvatar: String?){
    
    var tempMembers = members
    
    reference(.Recent).whereField(kRECENTID, isEqualTo: chatRoomID).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {return}
        
        if !snapshot.isEmpty {
            for recent in snapshot.documents {
                let currentRecent = recent.data() as NSDictionary
                if let currentUserID = currentRecent[kUSERID]{
                    if tempMembers.contains(currentUserID as! String ){
                        tempMembers.remove(at: tempMembers.firstIndex(of: currentUserID as! String)!)
                    }
                    
                }
            }
        }
        
        for userID in tempMembers {
            createRecentItem(userID: userID, members: members, chatRoomID: chatRoomID, withhUserUserName: withUserUserName, type: type, users: users, groupAvatar: groupAvatar)
        }
    }
}

func createRecentItem(userID: String , members: [String] , chatRoomID: String , withhUserUserName: String , type: String , users: [FUser]? , groupAvatar: String?){
    
    let localRefernce = reference(.Recent).document()
    let recentID = localRefernce.documentID
    let date = DateFormatter().string(from: Date())
    var recentItem:[String:Any]!
    
    if type == kPRIVATE {
        var withUser:FUser!
        
        if users != nil && users!.count > 0 {
               if userID == FUser.currentId() {
                withUser = users?.last
               }else{
                withUser = users?.first
            }
           }
        
        recentItem = [kRECENTID : recentID ,
                      kUSERID : userID ,
                      kCHATROOMID : chatRoomID ,
                      kMEMBERS : members ,
                      kMEMBERSTOPUSH : members ,
                      kWITHUSERFULLNAME : withUser.fullname ,
                      kWITHUSERUSERID : withUser.userId ,
                      kLASTMESSAGE : "" ,
                      kDATE : date ,
                      kCOUNTER : 0 ,
                      kTYPE : type ,
                      kAVATAR : withUser.avatar
                     ] as [String : Any]
         
        
    }else{
        
        if groupAvatar != nil {
            recentItem = [kRECENTID : recentID ,
                          kUSERID : userID ,
                          kCHATROOMID : chatRoomID ,
                          kMEMBERS : members ,
                          kMEMBERSTOPUSH : members ,
                          kWITHUSERFULLNAME : withhUserUserName ,
                          kLASTMESSAGE : "" ,
                          kDATE : date ,
                          kCOUNTER : 0 ,
                          kTYPE : type ,
                          kAVATAR : groupAvatar!
                ] as [String : Any]
    }
    
    }
   
    localRefernce.setData(recentItem)
    
}
