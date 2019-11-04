//
//  ChattingVC.swift
//  iChat
//
//  Created by zeyad on 10/11/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit
import MessageKit
import ProgressHUD
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseFirestore
import InputBarAccessoryView

class ChattingVC:  MessagesViewController   {
    
    static let shared = ChattingVC()
    
    var chatRoomID: String!
    var membersID: [String]!
    var membetsToPush: [String]!
    var titleName: String!
    var sentSoundEffect: AVAudioPlayer?
    var types = [kTEXT , kAUDIO , kVIDEO , kLOCATION , kPICTURE]
    var isGroup: Bool?
    var group: NSDictionary?
    var withUsers:[FUser] = []
    
    var newChatListener: ListenerRegistration?
    var updateStatusListener: ListenerRegistration?
    var typingListener: ListenerRegistration?
    
    var maxMessagesCount = 0
    var MinMessagescount = 0
    var loadOld = false
    var loadedMessageCount = 0
    
    var messages : [IncomingMessage]  = []
    var objectMessages: [NSDictionary] = []
    var loadedMessages: [NSDictionary] = []
    var allPictureMessages: [String] = []
    
    var initialLoadComplete = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMessages()
        navigationItem.largeTitleDisplayMode = .never
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Back"), style: .plain, target: self, action: #selector(self.backButton))
        self.messageInputBar.sendButton.image = #imageLiteral(resourceName: "mic")
        self.messageInputBar.sendButton.setTitle("", for: .normal)
        let image = #imageLiteral(resourceName: "kisspng-email-attachment-computer-icons-text-messaging-email-attachment-png-download-icons-5ab0bdb91a86a6.6387878415215323451087")
        let button = InputBarButtonItem(frame: CGRect(origin: .zero, size: CGSize(width: image.size.width, height: image.size.height)))
        button.image = image
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.leftStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        messageInputBar.leftStackView.isLayoutMarginsRelativeArrangement = true
        messageInputBar.inputTextView.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        button.addTarget(self, action: #selector(attachmentButnPressed), for: .touchUpInside)
        setHeader()
      }
  
    //play send sound
    func playSendSound(){
        let path = Bundle.main.path(forResource: "beyond-doubt.mp3", ofType: nil)!
        let url = URL(fileURLWithPath: path)

        do {
            //create your audioPlayer in your parent class as a property
            sentSoundEffect = try AVAudioPlayer(contentsOf: url)
            sentSoundEffect!.play()
        } catch {
            print("couldn't load the file")
        }
    }
    //play recieve Sound
    func playRecieveSound(){
        let path = Bundle.main.path(forResource: "beyond-doubt-2.mp3", ofType: nil)!
        let url = URL(fileURLWithPath: path)

        do {
            //create your audioPlayer in your parent class as a property
            sentSoundEffect = try AVAudioPlayer(contentsOf: url)
            sentSoundEffect!.play()
        } catch {
            print("couldn't load the file")
        }
    }

    //custom Header View
    
    let headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        return view
    }()
    let avatarBtn: UIButton = {
       let avatar = UIButton(frame: CGRect(x: 0, y: 10, width: 25, height: 25))
        return avatar
    }()
    let titleLbl: UILabel = {
       let title = UILabel(frame: CGRect(x: 30, y: 10, width: 140, height: 15))
        title.font = UIFont(name: title.font.fontName, size: 14)
        title.textAlignment = .left
        return title
    }()
    let subTitleLbl: UILabel = {
        let subtitle = UILabel(frame: CGRect(x: 30, y: 25, width: 140, height: 15))
        subtitle.font = UIFont(name: subtitle.font.fontName, size: 10)
        subtitle.textAlignment = .left
        return subtitle
    }()
    
    //MARK: set the Header view
    
    func setHeader(){
        headerView.addSubview(avatarBtn)
        headerView.addSubview(titleLbl)
        headerView.addSubview(subTitleLbl)
        
        let infoBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "info"), style: .plain, target: self, action: #selector(self.infoBtnPressed))
        navigationItem.rightBarButtonItem = infoBtn
        
        let leftBarBtn = UIBarButtonItem(customView: headerView)
        navigationItem.leftBarButtonItems?.append(leftBarBtn)
        
        getUsersFromFirestore(withIds: self.membersID) { (withUsers) in
            self.withUsers = withUsers
            if self.isGroup! {
                self.setUIForSingleChat()
            }
        }
        
        
        if isGroup!{
            avatarBtn.addTarget(self, action: #selector(self.showGroupInfo), for: .touchUpInside)
        }else{
            avatarBtn.addTarget(self, action: #selector(self.showProfile), for: .touchUpInside)
        }
    }
    
    func setUIForSingleChat(){
        let withuser = withUsers.first
        imageFromData(pictureData: withuser!.avatar) { (image) in
            if image != nil {
                avatarBtn.setImage(image?.circleMasked, for: .normal)
            }
            
            titleLbl.text = withuser?.fullname
            if withuser!.isOnline {
                subTitleLbl.text = "Online"
            }else{
                subTitleLbl.text = "Offline"
            }
        }
    }
    
    @objc func infoBtnPressed(){
        
    }
    @objc func showGroupInfo(){
        
    }
    @objc func showProfile(){
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ToProfileVC") as! ProfileVC
        profileVC.user = withUsers.first
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
    

  //back Btn
    
    @objc func backButton(){
        self.navigationController?.popViewController(animated: true)
    }
    
  //MARK: attatch button
    
    @objc func attachmentButnPressed(){
        let cameraInstance = CameraHandler(delegate_: self)
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)

        
        
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            //CameraHandler.shared.camera(vc: self)
        }
        
        
        
        let PhotoLibrary = UIAlertAction(title: "Photo library", style: .default) { (action) in
            
            cameraInstance.photoLibrary(vc: self)
            
              }
        
        
        
        
        let videoLibrary = UIAlertAction(title: "Video Library", style: .default) { (action) in
                  print("Video library")
              }
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (action) in
            print("share Location")
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
           
        }
            
            
        camera.setValue(UIImage(named: "camera"), forKey: "image")
        PhotoLibrary.setValue(UIImage(named: "picture"), forKey: "image")
        videoLibrary.setValue(UIImage(named: "video"), forKey: "image")
        shareLocation.setValue(UIImage(named: "location"), forKey: "image")
        cancel.setValue(UIImage(named: "cancel"), forKey: "image")
        

        alert.addAction(camera)
        alert.addAction(PhotoLibrary)
        alert.addAction(videoLibrary)
        alert.addAction(shareLocation)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    
    
    //update send button
    
    func updatesendButton(isSend: Bool){
        if !isSend {
            messageInputBar.sendButton.setImage(UIImage(named: "mic"), for: .normal)
        }else{
            messageInputBar.sendButton.setImage(UIImage(named: "send"), for: .normal)
        }
    }
    
    //send message function
    
    func sendMessage(text:String? , date: Date , picture:UIImage? , location: String? , video: NSURL? , audio: String?){
        var outgoingMessage: OutgoingMessage?
        if  let text = text {
            outgoingMessage = OutgoingMessage(message: text, senderId: FUser.currentId(), senderName: FUser.currentUser()!.firstname, date: date, status: kDELIVERED, type: kTEXT)
            playSendSound()
            outgoingMessage?.sendMessages(chatRoomID: self.chatRoomID, messageDictionary: outgoingMessage!.messageDictionary, membersID: self.membersID, memberstoPush: self.membetsToPush)
            messagesCollectionView.reloadData()
            messagesCollectionView.scrollToBottom()
        }
        
        if let pic = picture {
            uploadImage(image: pic, chatRoomID:self.chatRoomID , view: self.view) { (downloadURL) in
                if downloadURL != nil {
                    let text = kPICTURE
                    outgoingMessage = OutgoingMessage(message: text, pictureLink: downloadURL!, senderId: FUser.currentId(), senderName: FUser.currentUser()!.firstname, date: date, status: kDELIVERED, type: kPICTURE)
                    self.playSendSound()
                    outgoingMessage?.sendMessages(chatRoomID:self.chatRoomID, messageDictionary: outgoingMessage!.messageDictionary, membersID: self.membersID, memberstoPush: self.membetsToPush)
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom()
                }else {
                    return
                }
            }
        }
        
        messageInputBar.inputTextView.text = ""
        //updateLastMessageInRecent(text: text!)
        
    }
    
    func updateLastMessageInRecent(text: String){
        for userID in membersID {
            reference(.Recent).document(userID).updateData([kLASTMESSAGE : text])

        }
        
    }



    // Load last 11 messages
    
    
    
    
    
    func loadMessages(){
        reference(.Message).document(FUser.currentId()).collection(chatRoomID).order(by: kDATE, descending: true).limit(to: 11).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else {
                self.initialLoadComplete = true
                return
            }
            let sorted = (dictionaryFromSnapshots(snapshots: snapshot.documents) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
            
            self.loadedMessages = self.removeBadMessages(allMessages: sorted)
            //insert messages
            self.insertMessage()
            self.initialLoadComplete = true
            print("this is old messages  \(self.loadedMessages.count)")
            self.loadOldMessagesInBackground()
            self.listenToNewChat()
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom()
           
        }
        
        
    }
    
    func listenToNewChat(){
        var lastDate = "0"
        if loadedMessages.count > 0 {
            lastDate = loadedMessages.last![kDATE] as! String
        }
        
        newChatListener = reference(.Message).document(FUser.currentId()).collection(chatRoomID).whereField(kDATE, isGreaterThan: lastDate).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else {return}
            if !snapshot.isEmpty {
                for diff in snapshot.documentChanges {
                    if diff.type == .added {
                        let item = diff.document.data() as NSDictionary
                        if let type = item[kTYPE]{
                            if self.types.contains(type as! String){
                                if type as! String == kPICTURE {
                                    //added top picture array
                                }
                                
                                if self.insertInitailMessages(messagesDic: item) {
                                    // play recieving sound
                                    self.playRecieveSound()
                                }
                                
                                self.messagesCollectionView.reloadData()
                                self.messagesCollectionView.scrollToBottom()
                            }
                        }
                    }
                }
            }
        })
    }
    
    func insertMessage(){
        maxMessagesCount = loadedMessages.count - loadedMessageCount
               MinMessagescount = maxMessagesCount - kNUMBEROFMESSAGES
               
               if MinMessagescount < 0 {
                   MinMessagescount = 0
               }
               
               for i in MinMessagescount ..< maxMessagesCount {
                   let messageDictionary = loadedMessages[i]
                insertInitailMessages(messagesDic: messageDictionary)
                   loadedMessageCount += 1
               }
               
               
    }
    
    func insertInitailMessages(messagesDic: NSDictionary)->Bool {
        
        if messagesDic[kSENDERID] as! String != FUser.currentId() {
            // update delivet status
        }
        
        let message = IncomingMessage.createMessage(messageDic: messagesDic, chatRoomID: self.chatRoomID)
        if message != nil {
            objectMessages.append(messagesDic)
            messages.append(message!)
        }
        
       return isIncoming(messageDictionary: messagesDic)
    }
    
    func loadOldMessagesInBackground(){
        
        if loadedMessages.count > 10 {
            let firstMessageDate = loadedMessages.first![kDATE] as? String
            
            reference(.Message).document(FUser.currentId()).collection(self.chatRoomID).whereField(kDATE, isLessThan: firstMessageDate!).getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else {return}
                
                let sorted = (dictionaryFromSnapshots(snapshots: snapshot.documents) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
                
                self.loadedMessages = self.removeBadMessages(allMessages: sorted) + self.loadedMessages
                print("this is old messages with the new \(self.loadedMessages.count)")
                
                //get the pictures messages
                
                self.maxMessagesCount = self.loadedMessages.count - self.loadedMessageCount - 1
                self.MinMessagescount = self.maxMessagesCount - kNUMBEROFMESSAGES
                self.loadOld = true
            }
            
        }
    }
    
    //load older Messages
    
    func loadOldMessages(maxNum: Int , minNum: Int){
        if loadOld {
            maxMessagesCount = minNum - 1
            MinMessagescount = maxMessagesCount - kNUMBEROFMESSAGES
        }
        if MinMessagescount < 0 {
            MinMessagescount = 0
        }
    
        for i in (MinMessagescount ... maxMessagesCount).reversed() {
            if i < loadedMessageCount {
                print("end of messages")
                loadOld = false
                return
            }
            let messageDic = loadedMessages[i]
            insertNewMessage(messageDic: messageDic)
            loadedMessageCount += 1
        }
        loadOld = true
    }
    
    func insertNewMessage(messageDic: NSDictionary){
        
        let incomingMessage = IncomingMessage.createMessage(messageDic: messageDic, chatRoomID: self.chatRoomID)
        objectMessages.insert(messageDic, at: 0)
        messages.insert(incomingMessage!, at: 0)
    }
    
    
    //MARK: helper
    func removeBadMessages(allMessages: [NSDictionary]) -> [NSDictionary]{
        var tempMessages = allMessages
        
        for message in tempMessages {
            if message[kTYPE] != nil {
                if !types.contains(message[kTYPE] as! String) {
                    tempMessages.remove(at: tempMessages.firstIndex(of: message)!)
                }
            }else {
                    tempMessages.remove(at: tempMessages.firstIndex(of: message)!)
            }
        }
        
        return tempMessages
    }
    
    func isIncoming(messageDictionary: NSDictionary) -> Bool {
         
         if FUser.currentId() == messageDictionary[kSENDERID] as! String {
             return false
         } else {
             return true
         }
         
     }
    

    
    }
extension ChattingVC : MessageInputBarDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if text == "" {
            messageInputBar.sendButton.isEnabled = true
            updatesendButton(isSend: false)
        }else{
            updatesendButton(isSend: true)
        }
    }
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if text == "" {
            updatesendButton(isSend: false)
        }else{
            sendMessage(text: text, date: Date(), picture: nil, location: nil, video: nil, audio: nil)
            updatesendButton(isSend: true)
            
        }
    }
}


extension ChattingVC: MessagesLayoutDelegate {

  func avatarSize(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> CGSize {

    return .zero
  }

  func footerViewSize(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> CGSize {

    return CGSize(width: 0, height: 8)
  }

  func heightForLocation(message: MessageType, at indexPath: IndexPath,
    with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return 0
  }
}
extension ChattingVC: MessagesDisplayDelegate {
  
  func backgroundColor(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> UIColor {
    
    return isFromCurrentSender(message: message) ? #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)  : #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
  }

  func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> Bool {

    return true
  }


  func messageStyle(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

    let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft

    // 3
    return .bubbleTail(corner, .curved)
  }
}


extension ChattingVC : MessagesDataSource {
    func currentSender() -> SenderType {
        return Sender(senderId: FUser.currentId(), displayName: (FUser.currentUser()!.firstname))
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
       return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
        
    }
   
    func cellTopLabelAttributedText(for message: MessageType,
                                    at indexPath: IndexPath) -> NSAttributedString? {
        let date =  message.sentDate
        let formatter = DateFormatter()
        let dateformat = "yyyy-MM-dd / hh:mm a"
        formatter.dateFormat = dateformat
        let stringDate = formatter.string(from: date)
        return NSAttributedString(
            string: stringDate,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor(white: 0.3, alpha: 1)
            ]
        )

    }
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 8
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let _message = objectMessages[indexPath.row]
        var status: NSAttributedString = NSAttributedString(string: "")
        let attributedStringcolor = [NSAttributedString.Key.foregroundColor : UIColor.darkGray]
        switch _message[kSTATUS] as! String {
        case kDELIVERED:
            if isFromCurrentSender(message: message){
                status = NSAttributedString(string: kDELIVERED)
            }
        case kREAD:
            if isFromCurrentSender(message: message){
                let statuText = "Read" + " " + readTimeFrom(dateString: _message[kREADDATE] as! String)
                status = NSAttributedString(string: statuText, attributes: attributedStringcolor)
            }
        default:
            if isFromCurrentSender(message: message){
                status = NSAttributedString(string: "✓")
            }
            
        }

        if indexPath.section == (messages.count - 1) {
            
            return status
            
        }else{
            
            return NSAttributedString(string: "")
        }
    }
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        let data = messages[indexPath.row]
        
        if data.sender.senderId == FUser.currentId(){
            return 13
        }else {
            
            return 0
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("invoked")
        
        if loadOld {
            self.loadOldMessages(maxNum: maxMessagesCount, minNum: MinMessagescount)
                   self.messagesCollectionView.reloadData()
        }
       
    }
}
    


//MARK: uiimage picker

extension ChattingVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.sendMessage(text: nil, date: Date(), picture: info[.originalImage] as? UIImage, location: nil, video: nil, audio: nil)
        self.dismiss(animated: true, completion: nil)
    }
}

