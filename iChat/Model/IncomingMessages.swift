//
//  IncomingMessages.swift
//  iChat
//
//  Created by zeyad on 10/13/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import Foundation
import MessageKit

class IncomingMessage{
    
    static let instance = IncomingMessage()
    
    var text: String?
    var messageID: String?
    var senderName: String?
    var senderID: String?
    var date: Date?

    
    
    init() {

    }
  
    init(text: String , messageId: String , senderName: String , senderId: String , date: Date) {
        self.text = text
        self.messageID = messageId
        self.senderID = senderId
        self.senderName = senderName
        self.date = date
    }
    init(messageID: String , senderName: String , date: Date , image: UIImage) {
        //let mediaItem = ImageMediaItem(image: image)
        self.messageID = messageID
        self.senderName = senderName
        self.date = date
        self.image = image
        
    }
   
    
    
    func createMessage(messageDic: NSDictionary , chatRoomID: String) -> IncomingMessage? {
        var message: IncomingMessage?
        let type = messageDic[kTYPE] as! String
        
        switch type {
        case kTEXT:
             message = creatTextMessage(message: messageDic, chatRoomID: chatRoomID)
        case kPICTURE:
            message = createImageMessage(message: messageDic)
        case kVIDEO:
            print("mesage type")
        case kLOCATION:
            print("mesage type")
        default:
            print("unkown message")
        }
        
        if message != nil {
            return message!
        }
        return IncomingMessage(text: "", messageId: "", senderName: "", senderId: "", date: Date())
        
    }
    
    func creatTextMessage(message: NSDictionary , chatRoomID: String) -> IncomingMessage{
           let senderName = message[kSENDERNAME] as! String
           let senderId = message[kSENDERID] as! String
           var date: Date!
           let text = message[kMESSAGE] as! String

           if let created = message[kDATE] {
               if (created as! String).count != 14 {
                   date = Date()
               }else {
                   date = dateFormatter().date(from: created as! String)
               }
           }else {
                date = Date()
           }


        return IncomingMessage(text: text, messageId:message[kMESSAGEID] as! String , senderName: senderName, senderId: senderId, date: date)
        
       }
    
    //MEdia Item functions
    
     struct ImageMediaItem: MediaItem {

        var url: URL?
        var image: UIImage?
        var placeholderImage: UIImage
        var size: CGSize

        init(image: UIImage) {
            self.image = image
            self.size = CGSize(width: 240, height: 240)
            self.placeholderImage = UIImage()
        }

    }
    
    
    
    
  
    var image:UIImage?
    func createImageMessage(message: NSDictionary) -> IncomingMessage {
        let senderName = message[kSENDERNAME] as! String
        //let senderId = message[kSENDERID] as! String
        var date: Date!
        if let created = message[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            }else {
                date = dateFormatter().date(from: created as! String)
            }
        }else {
             date = Date()
        }
    
        downloadImage(imageUrl: message[kPICTURE] as! String) { (image) in
            if image != nil {
                self.image = image
            }
        }
        
        return IncomingMessage(messageID: message[kMESSAGEID] as! String, senderName: senderName, date: date, image: self.image as! UIImage)
    }
    
//    func returnOutgoingMessageStatus(senderID: String)-> Bool {
//        return senderID == FUser.currentId()
//    }
    
    
    
    
    
}
extension IncomingMessage: MessageType {
    var sender: SenderType {
        return Sender(id: senderID!, displayName: senderName!)
    }
    
    var messageId: String {
        return messageID!
    }
    
    var sentDate: Date {
        return date!
    }
    
    var kind: MessageKind {
        return .text(text!)
       // return .photo(self.image)
    }
    
    
}

    
      

    
 
