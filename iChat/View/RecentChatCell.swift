//
//  RecentChatCell.swift
//  iChat
//
//  Created by zeyad on 10/8/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit
protocol RecentChatCellDelegate {
    func avatarImageTapped(indexpath: IndexPath)
}
class RecentChatCell: UITableViewCell {

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var lastMessageLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var unreadMessageCountLbl: UILabel!
    @IBOutlet weak var unreadMessageCountBackground: UIView!
    
    
    
    
    var indexpath: IndexPath!
    let tapGesture = UITapGestureRecognizer()
    var delegate: RecentChatCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        unreadMessageCountBackground.layer.cornerRadius = unreadMessageCountBackground.frame.width / 2
        tapGesture.addTarget(self, action: #selector(handleTap))
        avatarImage.isUserInteractionEnabled = true
        avatarImage.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(){
        delegate?.avatarImageTapped(indexpath: indexpath)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    //configur the cell
    
    func configureCell(recentItem: NSDictionary , indexpath: IndexPath){
        
        self.indexpath = indexpath
        
        fullNameLbl.text = recentItem[kWITHUSERFULLNAME] as? String
        lastMessageLbl.text = recentItem[kLASTMESSAGE] as? String
        //unreadMessageCountLbl.text = recentItem[kCOUNTER] as? String
        
        if let avatarString = recentItem[kAVATAR] {
            imageFromData(pictureData: avatarString as! String) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImage.image = avatarImage?.circleMasked
                }
            }
        }
        
        if recentItem[kCOUNTER] as? Int != 0 {
            unreadMessageCountLbl.text = "\(recentItem[kCOUNTER] as! Int)"
            unreadMessageCountLbl.isHidden = false
            unreadMessageCountBackground.isHidden = false
        }else{
            unreadMessageCountLbl.isHidden = false
            unreadMessageCountBackground.isHidden = false
        }

        var date:Date?
        
        if let created = recentItem[kDATE] as? String {
            
            if created.count != 14 {
                date = Date()
            }else {
                date = dateFormatter().date(from: created)
            }
            
            
        }else {
            date = Date()
        }
        
        dateLbl.text = timeElapsed(date: date!)
        
    }
    
    
}
