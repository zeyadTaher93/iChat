//
//  UserCell.swift
//  iChat
//
//  Created by zeyad on 10/3/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit
protocol UserCellDelegate {
    func avatarImageTapped(indexpath: IndexPath)
}
class UserCell: UITableViewCell {

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var index: IndexPath!
    let tapGesture = UITapGestureRecognizer()
    var delegate: UserCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tapGesture.addTarget(self, action: #selector(avatarTap))
        avatarImage.isUserInteractionEnabled = true
        avatarImage.addGestureRecognizer(tapGesture)
    }
    @objc func avatarTap(){
        delegate?.avatarImageTapped(indexpath: index)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell (fuser: FUser , index: IndexPath){
        self.index = index
        nameLabel.text = fuser.fullname
        if fuser.avatar != "" {
            imageFromData(pictureData: fuser.avatar) { (avatarImage) in
                self.avatarImage.image = avatarImage?.circleMasked
            }
        }
    }

}
