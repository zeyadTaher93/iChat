//
//  Message.swift
//  iChat
//
//  Created by zeyad on 10/12/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import Foundation
class OutgoingMessage {
    
    
    var messageDictionary:NSMutableDictionary
    //Text messsage initalizer
    init(message: String , senderId: String , senderName: String , date:Date  , status: String , type: String) {
        
        messageDictionary = NSMutableDictionary(objects: [message , senderId , senderName , dateFormatter().string(from: date), status , type], forKeys: [kMESSAGE as NSCopying , kSENDERID as NSCopying , kSENDERNAME as NSCopying , kDATE as NSCopying , kSTATUS as NSCopying , kTYPE as NSCopying])
    }
    
    //Picture message initalizer
    init(message: String ,pictureLink: String, senderId: String , senderName: String , date:Date  , status: String , type: String) {
           
           messageDictionary = NSMutableDictionary(objects: [message ,pictureLink, senderId , senderName , dateFormatter().string(from: date), status , type], forKeys: [kMESSAGE as NSCopying ,kPICTURE as NSCopying ,  kSENDERID as NSCopying , kSENDERNAME as NSCopying , kDATE as NSCopying , kSTATUS as NSCopying , kTYPE as NSCopying])
       }
    
    
    //send Message
    
    func sendMessages(chatRoomID: String, messageDictionary: NSMutableDictionary , membersID: [String] , memberstoPush: [String]){
        let messageID = UUID().uuidString
        messageDictionary[kMESSAGEID] = messageID
        
        for userID in membersID {
            reference(.Message).document(userID).collection(chatRoomID).document(messageID).setData(messageDictionary as! [String : Any])
        }
        //update Recent
        
        //send push notification
    }
    
    
    
}
